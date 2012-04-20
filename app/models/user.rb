class User < ActiveRecord::Base
  attr_accessible :description, :id, :name
  validates_presence_of :description, :id, :name
end
