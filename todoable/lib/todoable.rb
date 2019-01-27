require "todoable/version"
require "rest-client"

module Todoable
  class Error < StandardError; end
  # Your code goes here...

  BASE_URL = "http://todoable.teachable.tech/api"

  def self.hi
    puts "Hello world!"
  end

  def self.bye
    puts "Goodbye world!"
  end

  def self.get_token
    puts "get_token start"

    response = RestClient::Request.execute(
      method: :post,
      url: "http://todoable.teachable.tech/api/authenticate",
      user: "vinod_lala@usa.net",
      password: "todoable"
    )

    puts response
    puts "get_token end"
    response
  end

  def self.get_list
    response = Todoable::Client.new(:get, "/lists").execute
    puts response
  end

  class Client
    class NoResponseError < StandardError; end

    def initialize(method, endpoint = '', query_string = nil, payload = nil)
      @method = method

      @endpoint = endpoint

      @query_string = query_string

      @payload = payload
    end

    def execute
      puts "start execute"
      @response = RestClient::Request.execute(request_args)
      puts "after RestClient::Request.execute"
      puts "@response"
      puts @response

      if @response.is_a?(RestClient::Response)
        puts "ok"
        return @response
      else
        raise NoResponseError
      end
    rescue NoResponseError,
      RestClient::InternalServerError,
      RestClient::BadRequest,
      RestClient::ExceptionWithResponse,
      RestClient::ResourceNotFound,
      RestClient::Unauthorized,
      Errno::ECONNREFUSED => e

      puts "nope"
      puts e
    end

    def this_be_token
      # "32d5a9af-ce2e-457f-9bb4-775ed26c1a15"
      response = Todoable.get_token
      puts "response"
      puts response
      # token = "b4455124-8ec3-4db6-8cc9-0317246bce1f"
      parsed_response = JSON.parse(response)
      puts "parsed_response"
      puts parsed_response
      # token = JSON.parse(response)["token"]
      token = parsed_response["token"]
      puts "token"
      puts token
      # token = "48ca8cef-a31e-48c8-b3af-2570f7b0ef42"

      # token = "939cd8aa-456a-4c11-81be-4b01d2f5377a"

      token
    end

    def this_be_token_hc
      token = "939cd8aa-456a-4c11-81be-4b01d2f5377a"

      token
    end

    def headers
      out = {
        'Content-Type': "application/json",
        'Accept': "application/json",
        # Authorization: "Token token='#{this_be_token}'"
        # Authorization: "Token token='#{this_be_token_hc}'"

        # Authorization: "Token token=\"#{this_be_token_hc}\""
        # Authorization: "Token token=\"939cd8aa-456a-4c11-81be-4b01d2f5377a\""
        Authorization: "Token token=\"#{this_be_token}\""
      }

      puts "headers out"
      puts out

      if !@query_string.nil?
        out.merge(params: @query_string)
      else
        out
      end

      puts "headers out"
      puts out
      out
    end

    def url
      BASE_URL + @endpoint
    end

    def is_get_request?
      @method == :get
    end

    def request_args
      opts = { method: @method, url: url, headers: headers }

      is_get_request? ? opts : opts.merge({ payload: @payload })
    end
  end
end