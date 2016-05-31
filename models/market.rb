require 'sequel'

# Market model
class Market < Sequel::Model
  many_to_many :startups
end
