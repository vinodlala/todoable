require "todoable/version"
require "rest-client"

module Todoable
  class Client
    BASE_URL = "http://todoable.teachable.tech/api"

    class NoResponseError < StandardError; end
    class NoTokenError < StandardError; end
    # RestClient has other errors

    attr_reader :token, :token_expires_at

    def initialize(username:, password:)
      @username = username

      @password = password

      authenticate
    end

    def authenticate
      token_info = get_token

      @token = token_info["token"]

      @token_expires_at = Time.parse(token_info["expires_at"])

      self
    end

    def get_token
      response = RestClient::Request.execute(
        method: :post,
        url: BASE_URL + "/authenticate",
        user: @username,
        password: @password
      )

      if response.is_a?(RestClient::Response)
        JSON.parse(response)
      else
        raise NoResponseError
      end
    end

    def rest_client_request(method:, path:, params: {})
      response = RestClient::Request.execute(
        method: method,
        url: BASE_URL + path,
        payload: params.to_json,
        headers: headers
      )

      if response.is_a?(RestClient::Response)
        response
      else
        raise NoResponseError
      end

    # RestClient returns these errors, but they can be handled better
    # rescue NoResponseError,
    #   RestClient::InternalServerError,
    #   RestClient::BadRequest,
    #   RestClient::ExceptionWithResponse,
    #   RestClient::ResourceNotFound,
    #   RestClient::Unauthorized,
    #   Errno::ECONNREFUSED => e
    end

    def get_lists
      check_token

      response = rest_client_request(
        method: :get,
        path: "/lists"
      )

      # Return a hash
      JSON.parse(response)
    end

    def post_list(name)
      check_token

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

      # Return a hash
      # If a list with the name already exists, this is returned:
      # {"name"=>["has already been taken"]}
      JSON.parse(response)
    end

    def get_list(list_id)
      check_token

      response = rest_client_request(
        method: :get,
        path: "/lists/#{list_id}"
      )

      # Return a hash
      JSON.parse(response)
    end

    def patch_list(list_id, name)
      check_token

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

      # Returns "#{name of the list} updated"
      response
    end

    def delete_list(list_id)
      check_token

      response = rest_client_request(
        method: :delete,
        path: "/lists/#{list_id}"
      )

      # Returns an empty string
      response
    end

    def post_list_items(list_id, name)
      check_token

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

      # Returns a hash of the created list item only
      # Multiple list items with the same name are allowed
      JSON.parse(response)
    end

    def finish_list_item(list_id, item_id)
      check_token

      response = rest_client_request(
        method: :put,
        path: "/lists/#{list_id}/items/#{item_id}/finish"
      )

      # Returns "#{name of the list item} finished"
      # 404 if item is already finished
      response
    end

    def delete_list_item(list_id, item_id)
      check_token

      response = rest_client_request(
        method: :delete,
        path: "/lists/#{list_id}/items/#{item_id}"
      )

      # Returns ""
      # 404 if item is already finished
      response
    end

    def check_token
      raise NoTokenError unless @token

      authenticate if token_expired?
    end

    def token_expired?
      @token_expires_at < Time.now.utc
    end

    def headers
      {
        'Content-Type': "application/json",
        'Accept': "application/json",
        Authorization: "Token token=\"#{@token}\""
      }
    end
  end
end
