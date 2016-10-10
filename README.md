# Angel.co Startup Parser
* `angel.rb`: This script parses startups on angel.co by a market tag and creates a sqlite
database with that parsed data.
* `sqlite_to_csv_converter.rb`: This script creates two csv files(one for nodes, one for
edges) with parsed data by `angel.rb` for graph commons.

# Features
* Database views

# Requirements
* Ruby >= 2.2.x
* Bundler(`gem install bundler`)
* See also [Gemfile](Gemfile)

# Usage
First of all, rename to file name `config.example.yaml` to `config.yaml` and
rename to filename `views.example.yml` to `views.yml` edit those files by
yourself. After:

## Setup
```bash
$ git clone https://erenhatirnaz@bitbucket.org/erenhatirnaz/angel.co-startup-parser.git
$ cd angel.co-startup-parser
$ bundler install
```

## Creation database
Run `ruby angel.rb -m "[Market Tag]"` or just `ruby angel.rb` command, and then follow the steps.

## Convert database to csv files (for import GraphCommons)
```bash
$ ruby sqlite_to_csv_converter.rb -d [Database directory]
```

# Output database schema
![database schema](db_schema.png)

# License
Apache 2.0
