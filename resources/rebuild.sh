#! /bin/bash

# simple prompt
prompt_yes_no() {
  while true ; do
    printf "$* [Y/n] "
    read answer
    if [ -z "$answer" ] ; then
      return 0
    fi
    case $answer in
      [Yy]|[Yy][Ee][Ss])
        return 0
        ;;
      [Nn]|[Nn][Oo])
        return 1
        ;;
      *)
        echo "Please answer yes or no"
        ;;
    esac
 done
}

# Reading options from rebuild.config
FILENAME=rebuild.config
while read option
do
    export $option
done < $FILENAME
DRUSH="$DRUSH_PATH"

# Start our rebuilding
clear

cat <<EOF

*** IMPORTANT ***

The following values were read from rebuild.config in your resources directory.
Please make sure they are correct before proceeding:

  D5_DRUPAL_ROOT = $D5_DRUPAL_ROOT
  D7_DRUPAL_ROOT = $D7_DRUPAL_ROOT
  DRUSH_PATH = $DRUSH_PATH
  D7_DATABASE = $D7_DATABASE
  D5_DATABASE = $D5_DATABASE
  D5_GIT_REPO = $D5_GIT_REPO
  D7_GIT_REPO = $D7_GIT_REPO

EOF

if ! prompt_yes_no "Are sure these values are correct?" ; then
    exit 1
fi

cat <<EOF

The following operations will be done:

 1. Delete $D7_DRUPAL_ROOT
 2. Rebuild the Drupal directory in $D7_DRUPAL_ROOT
 3. Re-install the mysite install profile in $D7_DRUPAL_ROOT
 4. Optionally migrate files and content from the Drupal 5 database called
    $D5_DATABASE to the Drupal 7 database called $D7_DATABASE
 5. Optionally create symlinks from your git repo in $D7_GIT_REPO
    to the new site directory in $D7_DRUPAL_ROOT

EOF

if ! prompt_yes_no "Are you sure you want to proceed?" ; then
    exit 1
fi

echo 'Rebuilding MySite...'
echo 'Removing '$D7_DRUPAL_ROOT' directory...'
chmod a+w $D7_DRUPAL_ROOT"/sites/default"
chmod a+w $D7_DRUPAL_ROOT"/sites/default/files"
rm -rf $D7_DRUPAL_ROOT
echo 'Executing drush make'
$DRUSH make --prepare-install --force-complete $D7_GIT_REPO"/mysite.build" $D7_DRUPAL_ROOT -y
cd $D7_DRUPAL_ROOT
echo 'Re-installing site database'
$DRUSH si mysite --site-name="MySite" --db-url="mysql://root:root@localhost/$D7_DATABASE" -y
echo 'Finished rebuilding directory and re-installing site.'

# Symlinks

cat <<EOF

Would you like to have symlinks set up? The script will create symlinks as
follows:
  ln -s $D7_GIT_REPO/modules/custom $D7_DRUPAL_ROOT/profiles/mysite/modules/custom
  ln -s $D7_GIT_REPO/themes/mysite $D7_DRUPAL_ROOT/profiles/mysite/themes/mysitetheme

EOF

if ! prompt_yes_no 'Create symlinks?' ; then
    exit 1
fi

echo 'Creating symlinks'
cd $D7_DRUPAL_ROOT
rm -rf profiles/mysite/modules/custom
rm -rf profiles/mysite/themes/mysitetheme
ln -s $D7_GIT_REPO"/modules/custom" $D7_DRUPAL_ROOT"/profiles/mysite/modules/custom"
ln -s $D7_GIT_REPO"/themes/mysite" $D7_DRUPAL_ROOT"/profiles/mysite/themes/mysitetheme"
echo 'Done making symlinks.'

# Content migration
cat <<EOF

The script will run 'drush migrate-import --all', which will run all
content migration patterns. You must have the Drupal 5 site setup locally
for this to work properly.

EOF

if ! prompt_yes_no "Migrate content and files?" ; then
    exit 1
fi

echo 'Migrating database content...'
echo 'Updating Drupal 5 git repo...'
cd $D5_GIT_REPO
git checkout master
git pull
# TODO: Set this so it imports only if git pull brought us new content
echo 'Importing Drupal 5 database...'
mysql -uroot -proot $D5_DATABASE < $D5_GIT_REPO"/database/mysite-production.sql"

cd $D7_DRUPAL_ROOT

echo 'Setting date and timezone settings...'
$DRUSH vset date_first_day 1 -y
$DRUSH vset date_default_timezone 'America/New_York' -y
$DRUSH vset date_api_use_iso8601 0 -y
$DRUSH vset site_default_country 'US' -y
$DRUSH vset configurable_timezones 0 -y
$DRUSH vset user_default_timezone 0 -y
echo 'Done.'
# Run cron to make sure any initialization necessary in Drupal takes place before
# nodes are imported.
echo 'Running cron...'
$DRUSH cron

# Migrate isn't resolving dependencies correctly so we specify the migration order here manually
$DRUSH mi mysiteUser
$DRUSH mi mysiteTouts
$DRUSH mi mysiteEducationalProgramNode
$DRUSH mi mysiteNewsNode
$DRUSH mi mysitePageNode
$DRUSH mi mysiteProgramEventNode
$DRUSH mi mysiteStaffMemberNode
$DRUSH mi mysiteFinish

echo 'Done.'

# The Webform feature, which contains Webform nodes, is enabled after
# all other features so as to not interfere with node IDs that are preserved
# from the Drupal 5 site
echo 'Enabling our Webforms'
$DRUSH en mysite_webforms -y

# File migration

echo 'Copying files...'
mkdir $D7_DRUPAL_ROOT"/sites/default/files/files"
cp -Rp $D5_DRUPAL_ROOT"/files/"* $D7_DRUPAL_ROOT"/sites/default/files/files/"
echo 'Done.'
echo 'Copying images...'
mkdir $D7_DRUPAL_ROOT"/sites/default/files/images"
cp -Rp $D5_DRUPAL_ROOT"/images/"* $D7_DRUPAL_ROOT"/sites/default/files/images/"
echo 'Done.'
echo 'Finished content migration!'

echo 'Rebuild completed.'
