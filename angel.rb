require 'optparse'

require_relative 'helper.rb'

options = { soughtMarketTagName: nil }

parser = OptionParser.new do |opts|
  banner = []
  banner[0] = "Script Name\t: Angel.co Startup Parser"
  banner[1] = "Description\t: This script parses startups on angel.co by a market tag and creates a\n"\
            + "\t          sqlite database with that parsed data."
  banner[2] = "Developer\t: Eren Hatirnaz <erenhatirnaz@atinasoft.com>"
  banner[3] = "Company\t\t: Atinasoft \t<info@atinasoft.com>"
  banner[4] = '~' * 61
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

if options[:soughtMarketTagName].nil?
  print 'Enter market tag:'
  options[:soughtMarketTagName] = gets.chomp
  if options[:soughtMarketTagName].empty?
    print 'Market tag cannot be empty!'
    exit
  end
end

market_tag_name = options[:soughtMarketTagName]
ACCESS_TOKEN = 'YOUR ACCESS TOKEN'.freeze # edit this line for yourself!

search_results = query("https://api.angel.co/1/search?query=#{market_tag_name}&type=MarketTag", ACCESS_TOKEN)

if search_results.empty?
  print "No result for this market tag=#{market_tag_name}"
  exit
end

selected_market_tag_id = search_results.count > 1 ? select_marget_tag(search_results) : search_results[0][:id]

output_file_name = "#{market_tag_name.tr(' ', '-')}-#{rand(1000)}.csv"
output_file = File.new(output_file_name, 'w')
output_file.puts('from_type, from_name, edge_type, to_type, to_name, weight')
output_file_total_line = 1

market_startups = query("https://api.angel.co/1/tags/#{selected_market_tag_id}/startups", ACCESS_TOKEN)

last_page = market_startups[:last_page].to_i

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

  print "Page #{current_page + 1} / #{last_page} finished!\r"
  $stdout.flush
end

output_file.close

print '-' * 46 + "\n"
print "Total startups\t\t: #{total_startup_count}\n"
print "Total line\t\t: #{output_file_total_line}\n"
print "Output file name\t: #{output_file_name}\n"
print "Completed!\n"
