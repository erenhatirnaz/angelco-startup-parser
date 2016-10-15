require 'uri'
require 'json'
require 'net/https'
require 'yaml'
require 'English'

require 'sequel'
require 'sqlite3'

def query(query_url, access_token)
  query_url += (query_url.include?('?') ? '&' : '?') + "access_token=#{access_token}"
  url = URI.parse(query_url)
  req = Net::HTTP::Get.new(url.to_s)
  http = Net::HTTP.new(url.host, url.port)

  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  response = http.request(req)

  if response.code.to_i == 401
    abort '[ERR] This access token is invalid or has been revoked by the user.'.on_red
  end

  JSON.parse(response.body)
end

def get_user_choice(collection, message)
  puts message.to_s.magenta

  collection.each_with_index do |item, index|
    puts((index + 1).to_s.light_red + " )- #{item['name']}".yellow)
  end

  print '> Select an item from the list: '.light_blue

  selected_index = gets.chomp.to_i - 1
  if selected_index < 0 || collection[selected_index].nil?
    abort '[ERR] Please enter a valid item number!'.on_red
  end

  collection[selected_index]
end

def normalize_string(string)
  string.tr("/\u2019/", "/\u0027/").tr("/\u0022/", "/\u0027/")
end

def generate_database_directory_name(market_tag_name)
  market_tag_name = market_tag_name.tr(' ', '-').downcase
  database_directory_name = nil

  loop do
    database_directory_name = "#{market_tag_name}-#{rand(1000)}"
    break unless File.exist?(database_directory_name)
  end

  database_directory_name
end

def create_and_open_database(database_path)
  db_connection = Sequel.connect("sqlite://#{database_path}")

  db_connection.create_table(:locations) do
    primary_key :id
    column :name, :text, null: false
  end

  db_connection.create_table(:markets) do
    primary_key :id
    column :name, :text, null: false
  end

  db_connection.create_table(:startups) do
    primary_key :id
    column :name, :text, null: false
    column :description, :text
    column :website_url, :text
    column :logo_url, :text
    column :reference, :text
    column :quality, :integer
    column :follower_count, :integer
  end

  db_connection.create_table(:locations_startups) do
    foreign_key :startup_id, :startups, null: false
    foreign_key :location_id, :locations, null: false
    primary_key [:startup_id, :location_id]
  end

  db_connection.create_table(:markets_startups) do
    foreign_key :startup_id, :startups, null: false
    foreign_key :market_id, :markets, null: false
    primary_key [:startup_id, :market_id]
  end

  views_file = File.exist?('views.yml') ? 'views.yml' : 'views.example.yml'
  import_views_from_yml_file(db_connection, views_file)

  Dir['./models/*.rb'].each { |model| require model }
end

def import_views_from_yml_file(db_connection, file_name)
  views = YAML.load_file(file_name)
  views.each do |view|
    next if (view['name'].nil? || view['name'].empty?) ||
            (view['query'].nil? || view['query'].empty?)
    begin
      db_connection.create_or_replace_view(view['name'].strip, view['query'].strip)
    rescue Sequel::DatabaseError
      puts '[ERR] There is an error in this query:'.white.on_red
      puts "\tName : ".cyan + view['name']
      puts "\tQuery: ".cyan + view['query'].strip
      puts "\tError: ".cyan + $ERROR_INFO.to_s[23..-1]
    end
  end
  fail_views_count = views.length - db_connection.views.length
  puts "DB Views -> Total  :#{views.length}\n".yellow + \
       "\t    Created:#{db_connection.views.length}\n".yellow + \
       "\t    Fail   :#{fail_views_count}".yellow
end

def open_database(database_path)
  Sequel.connect("sqlite://#{database_path}")

  Dir['./models/*.rb'].each { |model| require model }
end
