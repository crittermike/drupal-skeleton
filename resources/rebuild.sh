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

# Start our rebuilding
clear

cat <<EOF

*** IMPORTANT ***

The following values were read from rebuild.config in your resources directory.
Please make sure they are correct before proceeding:

  DB_NAME = $DB_NAME
  DB_USER = $DB_USER
  DB_PASS = $DB_PASS
  DRUPAL_ROOT = $DRUPAL_ROOT

EOF

if ! prompt_yes_no "Are sure these values are correct?" ; then
    exit 1
fi

cat <<EOF

The following operations will be done:

 1. Create a backup of $DRUPAL_ROOT at /tmp/drupal-rebuild-backup
 2. Rebuild the Drupal directory in $DRUPAL_ROOT
 3. Optionally re-install the install profile in $DRUPAL_ROOT
 4. Run any necessary Drupal database updates.
 5. Re-sync configuration from data store to active store.

If you have not already run "git pull" to fetch the latest code, you may want to stop this and do that now.

EOF

if ! prompt_yes_no "Are you sure you want to proceed?" ; then
    exit 1
fi

echo 'Rebuilding the site...'
echo 'Removing '$DRUPAL_ROOT' directory'
chmod a+w $DRUPAL_ROOT"/sites/default" 2>/dev/null
chmod a+w $DRUPAL_ROOT"/sites/default/files" 2>/dev/null

mv $DRUPAL_ROOT /tmp/drupal-rebuild-backup 2>/dev/null
rm -rf $DRUPAL_ROOT

echo 'Executing drush make'
drush make --prepare-install --working-copy ../skeleton.build $DRUPAL_ROOT -y
cp -rf /tmp/drupal-rebuild-backup/sites/default/* $DRUPAL_ROOT"/sites/default" 2>/dev/null
echo 'Finished executing drush make'

cd $DRUPAL_ROOT

if prompt_yes_no "Do you want to re-install the database?" ; then
    echo 'Re-installing site database'
    drush si skeleton --site-name="skeleton" --db-url="mysql://$DB_USER:$DB_PASS@localhost/$DB_NAME" -y
    echo 'Done re-installing site database'
fi

echo 'Running any necessary Drupal database updates'
drush updb
echo 'Done.'

echo 'Syncing configuration from data store to active store.'
drush config-sync
echo 'Done.'

echo 'Rebuild completed!'
