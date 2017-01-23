# Change Log

## 2.1.1
### Bugfixes:
* [Issue #3](https://bitbucket.org/erenhatirnaz/angel.co-startup-parser/issues/3#comment-33719502):
  `startup_id` and `location_id` can be same sometimes.
    * Added new controls to prevent data repetition.
### Notable changes:
* Fixed a typo in error message.
* Reordered Gemfile and forgotten Gemfile.lock updated.

## 2.1.0
### Bugfixes:
* [Issue #1](https://bitbucket.org/erenhatirnaz/angel.co-startup-parser/issues/1):
  Several properties mustn't contains whitespaces on both sides.
* [Issue #3](https://bitbucket.org/erenhatirnaz/angel.co-startup-parser/issues/3):
  `startup_id` and `location_id` can be same sometimes.
### Proposals:
* [Issue #2](https://bitbucket.org/erenhatirnaz/angel.co-startup-parser/issues/2):
  If get an error during database creation, this database directory have to be
  deleted.
* [Issue #4](https://bitbucket.org/erenhatirnaz/angel.co-startup-parser/issues/4):
  Console output methods need refactor.

## 2.0.2
### Hotfixes:
* [Issue #6](https://bitbucket.org/erenhatirnaz/angel.co-startup-parser/issues/6):
Capitalization error in the library name. 

## 2.0.1
### Hotfixes:
* [Issue #5](https://bitbucket.org/erenhatirnaz/angel.co-startup-parser/issues/5):
  If the views.yml file is missing, throws an unhandled error.

## 2.0.0
### Features:
* Database integration and database views support.
    * Added option whether the sought market tag include or not.
    * Added database directory name generator method in `helper.rb`.
    * Added `create_and_open_database` method into `helper.rb` for creation 
      database file.
    * Added models to use the tables in the created database.
    * Added `sqlite_to_csv_converter` script.
* Progress Bar: Show the CSV file creation progress.
* Colorize output messages of the console: More readable console outputs.
    * Added bundler for dependency management.

## 1.0.0
* First release.
