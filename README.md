# Angel.co Startup Parser
This script parses startups on angel.co by a market tag and creates a sqlite
database with that parsed data.

# Requirements
* Ruby >= 2.2.x
* Bundler(`gem install bundler`)
* See also [Gemfile](Gemfile)

# Usage
First of all, rename to file name `config.example.yaml` to `config.yaml` and
edit that file by yourself. After:

```bash
$ git clone https://erenhatirnaz@bitbucket.org/erenhatirnaz/angel.co-startup-parser.git
$ cd angel.co-startup-parser
$ bundler install
$ ruby angel.rb --help
```

# Output database schema
![database schema](db_schema.png)

# License
Apache 2.0
