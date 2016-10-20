require 'yaml'
require 'optparse'

require 'colorize'
require 'ruby-progressbar'

require './helper.rb'

options = { soughtMarketTagName: nil }

parser = OptionParser.new do |opts|
  banner = []
  banner[0] = "Script Name\t: Angel.co Startup Parser".light_green
  banner[1] = "Description\t: This script parses startups on angel.co by\n".light_green \
            + "\t\t  a market tag and creates a sqlite database\n".light_green \
            + "\t\t  with that parsed data.".light_green
  banner[2] = "Developer\t: Eren Hatirnaz <erenhatirnaz@atinasoft.com>".light_green
  banner[3] = "Company\t\t: Atinasoft \t<info@atinasoft.com>".light_green
  banner[4] = '~'.cyan * 61
  banner[5] = 'Usage: ruby angel.rb -m MARKET_TAG_NAME'
  opts.banner = banner.join("\n")

  opts.on('-m', '--market-tag-name MARKET_TAG_NAME', 'Sought market tag name') do |market_tag_name|
    options[:soughtMarketTagName] = market_tag_name
  end

  opts.on_tail('-h', '--help', 'Displays Help') do
    puts opts
    exit
  end
end

parser.parse!

unless File.exist?('config.yml')
  abort "[ERR] config.yml file not found!\n".on_red\
      + "Please, rename to file name 'config.example.yaml' to 'config.yaml' and edit that file by yourself.".on_red
end

config = YAML.load_file('config.yml')
ACCESS_TOKEN = config['angel-co']['access-token']

if options[:soughtMarketTagName].nil?
  print '> Enter market tag: '.light_blue
  options[:soughtMarketTagName] = gets.chomp
  if options[:soughtMarketTagName].empty?
    abort '[ERR] Market tag cannot be empty!'.on_red
  end
end

market_tag_name = options[:soughtMarketTagName]

search_results = query("https://api.angel.co/1/search?query=#{market_tag_name}&type=MarketTag", ACCESS_TOKEN)

if search_results.empty?
  abort '[WARN] No result for this market tag='.black.on_yellow + market_tag_name.black.on_white
end

selected_market_tag = search_results.count > 1 ? get_user_choice(search_results, 'Founded markets:') : search_results[0]

print '> Do you want include this market tag into database?(y/N): '.light_blue
include_main_market_tag = gets.chomp.downcase
include_main_market_tag = include_main_market_tag == 'yes' || include_main_market_tag == 'y' ? true : false

market_tag_id = selected_market_tag['id']
market_tag_name = selected_market_tag['name'].strip

database_directory_name = generate_database_directory_name(market_tag_name)
database_path = "#{database_directory_name}/database.sqlite"
Dir.mkdir(database_directory_name)

create_and_open_database(database_path)

market_startups = query("https://api.angel.co/1/tags/#{market_tag_id}/startups", ACCESS_TOKEN)

last_page = market_startups['last_page']
hidden_startup_count = 0

progressbar = ProgressBar.create(format: '%a <%B> %p%% %t', total: last_page)

last_page.times do |current_page|
  market_startups = query("https://api.angel.co/1/tags/#{market_tag_id}/startups?page=#{current_page + 1}",
                          ACCESS_TOKEN)

  market_startups['startups'].each do |item|
    if item['hidden']
      hidden_startup_count += 1
      next
    end

    next unless Startup.where(name: item['name'].strip).first.nil?

    startup_description = item['high_concept'].strip if item['high_concept']

    startup = Startup.create(id: item['id'],
                             name: item['name'].strip,
                             description: startup_description,
                             website_url: item['company_url'],
                             logo_url: item['logo_url'],
                             reference: item['angellist_url'],
                             quality: item['quality'],
                             follower_count: item['follower_count'])

    item['markets'].each do |mrkt|
      next if mrkt['id'] == market_tag_id && !include_main_market_tag
      market_name = mrkt['display_name'].strip
      market = Market.where(name: market_name).first || Market.create(id: mrkt['id'], name: market_name)
      startup.add_market(market)
    end

    item['locations'].each do |lctn|
      location_name = lctn['display_name']
      location = Location.where(name: location_name).first || Location.create(id: lctn['id'], name: location_name)
      startup.add_location(location)
    end
  end

  progressbar.increment
end

statistics = []
statistics[0] = "Total startups\t\t\t:#{Startup.all.length} (#{hidden_startup_count} hidden startup)"
statistics[1] = "Total markets\t\t\t:#{Market.all.length}"
statistics[2] = "Total locations\t\t\t:#{Location.all.length}"
statistics[3] = "Directory of output database\t:#{database_directory_name}"

puts '-'.cyan * 55
puts statistics.join("\n").yellow
puts "\nDatabase created succesfully!".black.on_green
puts "If you want CSV files, run '".black.on_green \
    + "ruby sqlite_to_csv_converter.rb -d #{database_directory_name}".red.on_white \
    + "' command.".black.on_green
