require "todoable/version"
require "rest-client"

module Todoable
  class Error < StandardError; end
  # Your code goes here...

  def self.hi
    puts "Hello world!"
  end

  def self.bye
    puts "Goodbye world!"
  end

  def self.get_token
    puts "get_token start"


    puts "get_token end"
  end
end
