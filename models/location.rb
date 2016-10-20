require 'sequel'

# Location model
class Location < Sequel::Model
  many_to_many :startups
  unrestrict_primary_key
end
