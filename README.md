# Drupal Skeleton Install Profile and Build Script

This script will manage setting up an environment as well as updating it. This includes:

1. Running drush make to download all of the necessary code
2. Installing (or re-installing) Drupal using the database of your choice.
3. Running any pending database updates.
4. Syncing any updated configuration in from data store to active store.

## Usage

0. If you'd like to rename this, do a massive find/replace on "sksleton" to something else in filenames and file contents.
1. Firt of all, cd into the resources directory.
2. Copy resources/rebuild.config.example to resources/rebuild.config (this is set to be ignored by git).
3. Edit resources/rebuild.config and update the database info and site root.
4. Run ./rebuild.sh to start the process and follow the prompts.

## Developer Workflow

Once the site is installed, the install profile will be in /profiles/skeleton in the Drupal site root.
This is a git repo and this will be where you make all of your code edits.

Here are some specific tasks you will come across:

### Adding a new custom module

### Adding a new contrib module

### Exporting new configuration changes into code

### Importing someone else's configuration changes into your site
