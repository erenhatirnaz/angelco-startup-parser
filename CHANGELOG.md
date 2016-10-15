# Change Log

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
