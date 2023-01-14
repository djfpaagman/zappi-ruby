require 'faraday'
require 'json'
require 'net/http/digest_auth'

# Based off https://github.com/codegram/hyperclient
module Hyperclient
  # Internal: This class wrapps HTTParty and performs the HTTP requests for a
  # resource.
  class HTTP
    attr_writer :faraday
    # Public: Initializes the HTTP agent.
    #
    # url    - A String to send the HTTP requests.
    # config - A Hash with the configuration of the HTTP connection.
    #          :headers - The Hash with the headers of the connection.
    #          :auth    - The Hash with the authentication options:
    #            :type     - A String or Symbol to set the authentication type.
    #                        Allowed values are :digest or :basic.
    #            :user     - A String with the user.
    #            :password - A String with the user.
    #
    def initialize(url, config)
      @url      = url
      @config   = config
      @base_uri = config.fetch(:base_uri)

      authenticate!
    end

    def url
      begin
        URI.parse(@base_uri).merge(@url).to_s
      rescue URI::InvalidURIError
        @url
      end
    end

    # Public: Sends a GET request the the resource url.
    #
    # Returns: The parsed response.
    def get
      response = process_request :get

      return unless response.body

      begin
        JSON.parse(response.body)
      rescue JSON::ParserError
        response.body
      end
    end

    private

    def faraday
      default_block = lambda do |faraday|
          faraday.request  :url_encoded
          faraday.adapter :net_http
      end
      @faraday ||= Faraday.new({:url => @base_uri, :headers => @config[:headers] })
    end

    def process_request(method, params = nil)
      response = faraday.run_request method, url, params, faraday.headers
      if response.status == 401 && @digest_auth
        response = faraday.run_request method, url, nil, faraday.headers do |request|
          request.headers['Authorization'] = digest_auth_header(
            url,  response.headers['www-authenticate'], method)
        end
      end
      response
    end

    def authenticate!
      if (options = @config[:auth])
        auth_method = options.fetch(:type).to_s + '_auth'
        send auth_method, options
      end
    end

    def digest_auth(options)
      @digest_auth = options
    end

    def digest_auth_header(url, realm, method)
      uri = URI.parse(url)
      uri.user = @digest_auth[:user]
      uri.password = @digest_auth[:password]
      digest_auth = Net::HTTP::DigestAuth.new
      digest_auth.auth_header uri, realm, method.upcase
    end
  end
end
