require 'uri'
require 'json'
require 'net/https'

def query(query_url, access_token)
  query_url += (query_url.include?('?') ? '&' : '?') + "access_token=#{access_token}"
  url = URI.parse(query_url)
  req = Net::HTTP::Get.new(url.to_s)
  http = Net::HTTP.new(url.host, url.port)

  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  response = http.request(req)

  if response.code.to_i == 401
    print '[ERR] This access token is invalid or has been revoked by the user.'.on_red
    exit
  end

  JSON.parse(response.body, symbolize_names: true)
end

def find_market_tag(needle, list)
  result = nil

  list.each do |item|
    if item[:id].to_i == needle.to_i
      result = item
      break
    end
  end

  result
end

def select_marget_tag(search_results)
  print "Founded market tags:\n".magenta

  search_results.each do |result|
    print result[:id].to_s.light_red + "\t)- #{result[:name]}\n".yellow
  end

  print "\n> Select one market tag id: ".light_blue
  received_market_tag_id = gets.chomp
  market_tag = find_market_tag(received_market_tag_id, search_results)
  if received_market_tag_id.empty? || market_tag.nil?
    print '[ERR] Please select valid market tag id!'.on_red
    exit
  end

  market_tag
end

def generate_database_file_name(market_tag_name)
  market_tag_name = market_tag_name.tr(' ', '-').downcase
  database_file_name = nil

  loop do
    database_file_name = "#{market_tag_name}-#{rand(1000)}.csv"
    break unless File.exist?(database_file_name)
  end

  database_file_name
end
