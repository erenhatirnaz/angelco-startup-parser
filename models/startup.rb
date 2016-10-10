require 'sequel'

# Startup model
class Startup < Sequel::Model
  many_to_many :markets
  many_to_many :locations
end
