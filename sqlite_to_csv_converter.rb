require 'optparse'

require 'colorize'

require './helper.rb'

options = { databaseDirectory: nil }

parser = OptionParser.new do |opts|
  banner = []
  banner[0] = "Script Name\t: SQLite to CSV converter for GraphCommans".light_green
  banner[1] = "Description\t: This script creates two csv file(one for\n".light_green\
            + "\t\t  nodes, one for edges) with parsed data\n".light_green\
            + "\t\t  by `angel.rb` for graph commons.".light_green
  banner[2] = "Developer\t: Eren Hatirnaz <erenhatirnaz@atinasoft.com>".light_green
  banner[3] = "Company\t\t: Atinasoft\t<info@atinasoft.com>".light_green
  banner[4] = '~'.cyan * 61
  banner[5] = 'Usage: ruby sqlite_to_csv_converter.rb -d DATABASE_DIRECTORY'
  opts.banner = banner.join("\n")

  opts.on('-d', '--database-directory DATABASE_DIRECTORY',
          'The directory name containing the database created by angel.rb') do |database_directory|
    options[:databaseDirectory] = database_directory
  end

  opts.on_tail('-h', '--help', 'Displays Help') do
    puts opts
    exit
  end
end

parser.parse!

if options[:databaseDirectory].nil?
  print '> Enter database directory: '.light_blue
  options[:databaseDirectory] = gets.chomp.downcase
  if options[:databaseDirectory].empty?
    print '[ERR] Database directory cannot be empty!'.on_red
    exit
  end
end

unless File.exist?(options[:databaseDirectory])
  print '[ERR] Database directory not found!'.on_red
  exit
end

database_directory_name = options[:databaseDirectory].sub('/', '')
database_path = "#{database_directory_name}/database.sqlite"

open_database(database_path)

nodes_file_path = "#{database_directory_name}/nodes.csv"
edges_file_path = "#{database_directory_name}/edges.csv"

if File.exist?(nodes_file_path) || File.exist?(edges_file_path)
  print "[WARN] nodes.csv or edges.csv file is already exist!\n".black.on_yellow\
      + '> Do you want to overwrite these files?(y/N): '.light_blue
  overwrite = gets.chomp.downcase
  if overwrite == 'y' || overwrite == 'yes'
    File.delete(nodes_file_path)
    File.delete(edges_file_path)
  else
    exit
  end
end

nodes_file = File.new(nodes_file_path, 'w')
nodes_file.puts('Type,Name,Description,Image,Reference,Website Url,Quality,Follower Count')

Startup.all.each do |startup|
  nodes_file.puts('Startup,'\
                + "\"#{normalize_string(startup[:name].to_s)}\","\
                + "\"#{normalize_string(startup[:description].to_s)}\","\
                + "#{startup[:logo_url]},"\
                + "#{startup[:reference]},"\
                + "#{startup[:website_url]},"\
                + "#{startup[:quality]},"\
                + "#{startup[:follower_count]},")
end

Market.all.each { |market| nodes_file.puts("Market,\"#{market[:name]}\",") }
Location.all.each { |location| nodes_file.puts("Location,\"#{location[:name]}\"") }

nodes_file.close

edges_file = File.new(edges_file_path, 'w')
edges_file.puts('FROM NODE TYPE,FROM NODE NAME,EDGE TYPE,TO NODE TYPE,TO NODE NAME,Weight')

Startup.all.each do |startup|
  prefix = "Startup,\"#{normalize_string(startup[:name].to_s)}\""

  startup.markets.each { |market| edges_file.puts("#{prefix},BELONGS_TO,Market,#{market[:name]},") }
  startup.locations.each { |location| edges_file.puts("#{prefix},BASED_IN,Location,#{location[:name]},") }
end

edges_file.close

statistics = []
statistics[0] = "Total line count of nodes.csv\t:#{IO.readlines(nodes_file).count}"
statistics[1] = "Total line count of edges.csv\t:#{IO.readlines(edges_file).count}"
statistics[2] = "Directory of output CSV files\t:#{database_directory_name}"

print '-'.cyan * 55 + "\n"
print statistics.join("\n").yellow
print "\n\nCSV files created succesfully!".black.on_green
