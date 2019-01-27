require "todoable/version"
require "rest-client"

module Todoable
  class Error < StandardError; end

  BASE_URL = "http://todoable.teachable.tech/api"

  def self.hi
    puts "Hello world!"
  end

  def self.bye
    puts "Goodbye world!"
  end

  def self.get_token
    response = RestClient::Request.execute(
      method: :post,
      url: "http://todoable.teachable.tech/api/authenticate",
      user: "vinod_lala@usa.net",
      password: "todoable"
    )

    response
  end

  def self.get_lists
    response = Todoable::Client.new(:get, "/lists").execute

    response
  end

  def self.post_list(name: "default")
    post_params = {
      list: {
        name: name
      }
    }.to_json

    response = Todoable::Client.new(:post,
                                    "/lists",
                                    "",
                                    post_params
    ).execute

    response
  end

  def self.get_list(list_id:)
    response = Todoable::Client.new(:get, "/lists/#{list_id}").execute

    response
  end

  def self.patch_list(list_id:, name:)
    post_params = {
      list: {
        name: name
      }
    }.to_json

    response = Todoable::Client.new(:patch,
                                    "/lists/#{list_id}",
                                    "",
                                    post_params
    ).execute

    response
  end

  def self.delete_list(list_id:)
    response = Todoable::Client.new(:delete,
                                    "/lists/#{list_id}"
    ).execute

    response
  end

  def self.post_list_items(list_id:, name:)
    post_params = {
      item: {
        name: name
      }
    }.to_json

    response = Todoable::Client.new(:post,
                                    "/lists/#{list_id}/items",
                                    "",
                                    post_params
    ).execute

    response
  end

  def self.finish_list_item(list_id:, item_id:)
    response = Todoable::Client.new(:put,
                                    "/lists/#{list_id}/items/#{item_id}/finish"
    ).execute

    response
  end

  def self.delete_list_item(list_id:, item_id:)
    response = Todoable::Client.new(:delete,
                                    "/lists/#{list_id}/items/#{item_id}"
    ).execute

    response
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
      @response = RestClient::Request.execute(request_args)

      if @response.is_a?(RestClient::Response)
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
      response = Todoable.get_token

      parsed_response = JSON.parse(response)

      token = parsed_response["token"]

      token
    end

    # def this_be_token_hc
    #   token = "939cd8aa-456a-4c11-81be-4b01d2f5377a"
    #
    #   token
    # end

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

      # This is a weird RestClient thing
      if !@query_string.nil?
        out.merge(params: @query_string)
      else
        out
      end

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
