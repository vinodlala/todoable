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

  def self.post_list(name: "OLD")
    post_params = {
      list: {
        name: name
      }
    }.to_json

    # binding.pry

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

  class ClientNew
    attr_reader :token, :token_expires_at, :username, :password


    def initialize(username: "vinod_lala@usa.net", password: "todoable")
      @username = username

      @password = password

      authenticate
      # @options = {}
    end

    def authenticate
      puts "in authenticate"
      # @options[:basic_auth] = {
      #   username: @username,
      #   password: @password
      # }

      # response = self.class.post('/authenticate', @options)
      # check_and_raise_errors(response)
      # @token = response.parsed_response['token']
      # tokens expire after 20 minutes

      token_info = get_token
      puts "token_info"
      puts token_info

      @token = token_info["token"]

      puts "@token"
      puts @token
      @token_expires_at = token_info["token_expires_at"]
      # use legit expiry in case it changes from 20 mins
      @token_expiry = Time.now + (20 * 60)

      self
    end

    def get_token
      response = RestClient::Request.execute(
        method: :post,
        url: BASE_URL + "/authenticate",
        user: @username,
        password: @password
      )
      puts response

      JSON.parse(response)
    end

    def rest_client_request(method:, path:, params: {})
      puts "in rest_client_request"
      puts headers
      response = RestClient::Request.execute(
        method: method,
        url: BASE_URL + path,
        payload: params.to_json,
        headers: headers
      )

      if response.is_a?(RestClient::Response)
        return response
      else
        raise NoResponseError
      end

      puts "leaving rest_client_request"
      response
    rescue NoResponseError,
      RestClient::InternalServerError,
      RestClient::BadRequest,
      RestClient::ExceptionWithResponse,
      RestClient::ResourceNotFound,
      RestClient::Unauthorized,
      Errno::ECONNREFUSED => e

      puts "e.response"
      e.response

    # rescue => e
    #   puts "rest_client_request in rescue"
    #   puts e
    #   check_and_raise_errors(e)

      # rescue RestClient::ExceptionWithResponse => err
      #   ErrorParser.parse_error(err.response)
    end

    def get_lists
      # check token
      # response = Todoable::Client.new(:get, "/lists").execute
      response = rest_client_request(
        method: :get,
        path: "/lists"
      )

      # check_and_raise_errors(response)

      # return a hash
      JSON.parse(response)
    end

    def post_list(name)
      post_params = {
        list: {
          name: name
        }
      }

      response = rest_client_request(
        method: :post,
        path: "/lists",
        params: post_params
      )

      # check_and_raise_errors(response)
      # get a 422 UnprocessableEntity when it already exists

      JSON.parse(response)
    end

    def get_list(list_id)
      response = rest_client_request(
        method: :get,
        path: "/lists/#{list_id}"
      )

      # check_and_raise_errors(response)

      # return a hash
      JSON.parse(response)
    end

    def patch_list(list_id, name)
      post_params = {
        list: {
          name: name
        }
      }

      response = rest_client_request(
        method: :patch,
        path: "/lists/#{list_id}",
        params: post_params
      )

      # check_and_raise_errors(response)

      puts response

      response
      # JSON.parse(response)
    end

    def delete_list(list_id)
      response = rest_client_request(method: :delete,
                                     path: "/lists/#{list_id}"
      )

      # check_and_raise_errors(response)
      # 422 happens when it already exists

      # JSON.parse(response)
      response
    end

    def post_list_items(list_id, name)
      post_params = {
        item: {
          name: name
        }
      }

      response = rest_client_request(
        method: :post,
        path:  "/lists/#{list_id}/items",
        params: post_params
      )

      # check_and_raise_errors(response)

      # JSON.parse(response)
      response
    end

    def finish_list_item(list_id, item_id)
      response = rest_client_request(
        method: :put,
        path: "/lists/#{list_id}/items/#{item_id}/finish"
      )

      # check_and_raise_errors(response)

      response
      # JSON.parse(response)
    end

    def delete_list_item(list_id, item_id)
      response = rest_client_request(
        method: :delete,
        path: "/lists/#{list_id}/items/#{item_id}"
      )

      # check_and_raise_errors(response)
      # 422 happens when it already exists

      # returns "" if it works
      response

      # JSON.parse(response)
    end








    def check_token
      raise NoTokenError unless @token
      authenticate if token_expired
    end

    def token_expired
      Time.now > @token_expiry
    end

    def check_and_raise_errors(response)
      puts "in check_and_raise_error"
      puts "response error"
      puts response
      case response.code.to_i
      when 200..300 then true
      when 404 then raise NotFoundError
      when 401 then raise UnauthorizedError
      when 422
        # errors = response.parsed_response['errors']
        # raise UnprocessableError.new(errors: errors)
        # raise Error.new(errors: errors)
        raise UnprocessableError
      else
        raise StandardError, "Unknown error from Todoable: #{response}"
      end
    end

    def headers
      out = {
        'Content-Type': "application/json",
        'Accept': "application/json",
        # Authorization: "Token token='#{this_be_token}'"
        # Authorization: "Token token='#{this_be_token_hc}'"

        # Authorization: "Token token=\"#{this_be_token_hc}\""
        # Authorization: "Token token=\"939cd8aa-456a-4c11-81be-4b01d2f5377a\""
        # Authorization: "Token token=\"#{this_be_token}\""

        Authorization: "Token token=\"#{@token}\""
        # 'Authorization': "#{@token}"
      }

      # This is a weird RestClient thing
      # if !@query_string.nil?
      #   out.merge(params: @query_string)
      # else
      #   out
      # end

      puts "out"
      puts out
      out
    end

    class NoResponseError < StandardError
    end

    class NotFoundError < StandardError
    end

    class NoTokenError < StandardError
    end

    class UnauthorizedError < StandardError
    end

    class UnprocessableError < StandardError
    end
  end
end
