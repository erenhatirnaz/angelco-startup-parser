require 'sequel'

# Market model
class Market < Sequel::Model
  many_to_many :startups
  unrestrict_primary_key
end
