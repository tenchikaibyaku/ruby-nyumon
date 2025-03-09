require 'sinatra/activerecord'

class Todo < ActiveRecord::Base
  validates :title, presence: true
end
