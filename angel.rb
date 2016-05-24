require 'optparse'
require 'yaml'

require 'colorize'
require 'ruby-progressbar'

require_relative 'helper.rb'

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
  print "[ERR] config.yml file not found!\n".on_red\
      + "Please, rename to file name 'config.example.yaml' to 'config.yaml' and edit that file by yourself.".on_red
  exit
end

config = YAML.load_file('config.yml')
ACCESS_TOKEN = config['angel-co']['access-token']

if options[:soughtMarketTagName].nil?
  print '> Enter market tag: '.light_blue
  options[:soughtMarketTagName] = gets.chomp
  if options[:soughtMarketTagName].empty?
    print '[ERR] Market tag cannot be empty!'.on_red
    exit
  end
end

market_tag_name = options[:soughtMarketTagName]

search_results = query("https://api.angel.co/1/search?query=#{market_tag_name}&type=MarketTag", ACCESS_TOKEN)

if search_results.empty?
  print '[WARN] No result for this market tag='.black.on_yellow + market_tag_name.black.on_white
  exit
end

selected_market_tag_id = search_results.count > 1 ? select_marget_tag(search_results) : search_results[0][:id]

output_file_name = "#{market_tag_name.tr(' ', '-')}-#{rand(1000)}.csv"
output_file = File.new(output_file_name, 'w')
output_file.puts('from_type, from_name, edge_type, to_type, to_name, weight')
output_file_total_line = 1

market_startups = query("https://api.angel.co/1/tags/#{selected_market_tag_id}/startups", ACCESS_TOKEN)

last_page = market_startups[:last_page].to_i

progressbar = ProgressBar.create(format: '%a <%B> %p%% %t', total: last_page)

total_startup_count = 0

last_page.times do |current_page|
  market_startups = query("https://api.angel.co/1/tags/#{selected_market_tag_id}/startups?page=#{current_page + 1}",
                          ACCESS_TOKEN)

  market_startups[:startups].each do |item|
    next if item[:hidden].to_s == 'true'
    prefix = "Startup,#{item[:name].tr(',', '')},BELONGS_TO"

    item[:markets].each do |market|
      if market[:name].to_s != 'internet of things'
        output_file.puts("#{prefix},Market,#{market[:name]},#{item[:follower_count]}")
        output_file_total_line += 1
      end
    end
    item[:locations].each do |location|
      output_file.puts("#{prefix},Location,#{location[:name].tr(',', '')},#{item[:follower_count]}")
      output_file_total_line += 1
    end
    total_startup_count += 1
  end

  progressbar.increment
end

output_file.close

statistics = []
statistics[0] = "Total startups\t\t: #{total_startup_count}"
statistics[1] = "Total line\t\t: #{output_file_total_line}"
statistics[2] = "Output file name\t: #{output_file_name}"

print '-'.cyan * 46 + "\n"
print statistics.join("\n").yellow
print "\n\nCSV file created succesfully!".black.on_green
