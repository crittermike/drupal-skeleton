# Skeleton Install Profile and Build Script

This script will manage setting up an environment as well as updating it. This includes:

1. Running drush make to download all of the necessary code
2. Installing (or re-installing) Drupal using the database of your choice.
3. Running any pending database updates.
4. Reverting all Features to their default state.

## Initial Setup

0. (Optional) Rename this from Skeleton to something else by doing a mass find/replace in filenames and file contents.
1. Copy resources/rebuild.config.example to resources/rebuild.config (this is set to be ignored by git).
2. Edit resources/rebuild.config and update the database info and site root.
3. Run rebuild.sh to start the process and follow the prompts.
4. Once complete, don't forget to a vhost that points to the Drupal root and add the URL to your hosts file.
5. Open up a browser and pull up the site!

## Developer Workflow

Once the site is installed, the install profile will be in /profiles/skeleton in the Drupal site root.
This is a git repo and this will be where you make all of your code edits.

Here are some specific tasks you will come across:

### Updating your dev site

When you want to update your dev site by pulling in the latest code, here's the process you'll follow.

1. Run ./resources/rebuild.sh
2. Follow the prompts.

### Adding a new custom module

1. Add the custom module to the profiles/skeleton/modules/custom/ directory.
2. Edit profiles/skeleton/modules/custom/skeleton_core/skeleton_core.install to enable the new module in an update hook for already built sites.
3. Edit profiles/skeleton/skeleton.info to list the new module as a dependency on the install profile for new installs.

### Adding a new contrib module

1. Download the contrib module using "drush dl <modulename> --destination=profiles/skeleton/modules/contrib"
2. Add the contrib module to the profiles/skeleton/skeleton.make file.
3. Edit profiles/skeleton/modules/custom/skeleton_core/skeleton_core.install to enable the new module in an update hook for already built sites.
4. Edit profiles/skeleton/skeleton.info to list the new module as a dependency on the install profile for new installs.
