# Angel.co Startup Parser
This script parses startups on angel.co by a market tag and creates a csv file
with that parsed data.

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

# Output file template
```csv
from_type, from_name, edge_type, to_type, to_name, weight
Startup,[STARTUP NAME],BELONGS_TO,Market,[MARKET NAME],[FOLLOWER COUNT]
Startup,[STARTUP NAME],BELONGS_TO,Location,[LOCATION NAME],[FOLLOWER COUNT]
```

# License
Apache 2.0
