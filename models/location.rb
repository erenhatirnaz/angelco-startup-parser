require 'sequel'

# Location model
class Location < Sequel::Model
  many_to_many :startups
end
