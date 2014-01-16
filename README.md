# Skeleton Install Profile and Build Script

This script will manage setting up an environment as well as updating it. This includes:

1. Running drush make to download all of the necessary code
2. Installing (or re-installing) Drupal using the database of your choice.
3. Running any pending database updates.
4. Syncing any updated configuration in from data store to active store.

## Usage

1. Copy resources/rebuild.config.example to resources/rebuild.config (this is set to be ignored by git).
2. Edit resources/rebuild.config and update the database info and site root.
3. Run rebuild.sh to start the process and follow the prompts.
4. Once complete, don't forget to a vhost that points to the Drupal root and add the URL to your hosts file.
5. Open up a browser and pull up the site!

## Developer Workflow

Once the site is installed, the install profile will be in /profiles/skeleton in the Drupal site root.
This is a git repo and this will be where you make all of your code edits.

Here are some specific tasks you will come across:

### Adding a new custom module

1. Add the custom module to the profiles/skeleton/modules/custom/ directory.
2. Edit profiles/skeleton/modules/custom/skeleton_core/skeleton_core.install to enable the new module in an update hook for already built sites.
3. Edit profiles/skeleton/skeleton.info to list the new module as a dependency on the install profile for new installs.

### Adding a new contrib module

1. Add the contrib module to the profiles/skeleton/skeleton.make file.
2. Edit profiles/skeleton/modules/custom/skeleton_core/skeleton_core.install to enable the new module in an update hook for already built sites.
3. Edit profiles/skeleton/skeleton.info to list the new module as a dependency on the install profile for new installs.

### Exporting new configuration changes into code

Typically, you’ll want to use the Tracking feature of Configuration Management (“CM”).

GUI (non-drush) approach:

1. Go to admin/config/system/configuration/notracking and choose which “thing” you want to start tracking GUI changes to. Note that it automatically selects dependencies.
2. Go make your changes in the GUI.
3. When you’re ready to export and commit the config, go to admin/config/system/configuration/tracking and click “Write Activestore to Datastore”
4. In your config directory (profiles/skeleton/config), commit the new changes and push them to the remote repo for others to get.

Drush approach:

1. Run “drush config-get-non-tracked” to get a list of all non-tracked components, and find which one you want to start tracking.
2. Run “drush config-start-tracking <component-name>” to start tracking it. It will automatically track dependencies as well.
3. Go make your changes in the GUI.
4. When you’re ready to export and commit the config, go to admin/config/system/configuration/tracking and click “Write Activestore to Datastore” (this unfortunately can’t be done in drush)
5. In your config directory (profiles/skeleton/config), commit the new changes and push them to the remote repo for others to get.

Typically, the non-drush approach is a bit quicker and easier, but the drush approach can be handy, especially if scripting.

### Importing someone else's configuration changes into your site

1. Run "git pull" in profiles/skeleton to pull in the new config's export code.
2. Run "drush config-sync" to sync the data store to the active store.

Note: this happens already in the rebuild.sh script.
