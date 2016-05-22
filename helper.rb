require 'net/https'
require 'uri'
require 'json'

def query(query_url, access_token)
  query_url += (query_url.include?('?') ? '&' : '?') + "access_token=#{access_token}"
  url = URI.parse(query_url)
  req = Net::HTTP::Get.new(url.to_s)
  http = Net::HTTP.new(url.host, url.port)

  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  response = http.request(req)

  JSON.parse(response.body, symbolize_names: true)
end

def exist_market_tag_id(needle, list)
  result = false

  list.each do |item|
    if item[:id].to_i == needle.to_i
      result = true
      break
    end
  end

  result
end

def select_marget_tag(search_results)
  print "Founded market tags:\n"

  search_results.each do |result|
    print "#{result[:id]})- #{result[:name]}\n"
  end

  print "\n > Select one market tag id:"
  market_tag_id = gets.chomp
  if market_tag_id.empty? || !exist_market_tag_id(market_tag_id, search_results)
    print 'Please select valid market tag id!'
    exit
  end

  market_tag_id
end
