require 'faraday'
require 'json'
require 'net/http/digest_auth'

# Based off https://github.com/codegram/hyperclient, stripped to only support digest auth.
class DigestAuthClient
  attr_writer :faraday
  attr_reader :base_uri, :auth

  def initialize(base_uri:, auth:)
    @base_uri = base_uri
    @auth = auth
  end

  def get(path)
    response = process_request(:get, path)

    return unless response.body

    begin
      JSON.parse(response.body)
    rescue JSON::ParserError
      response.body
    end
  end

  private

  def faraday
    @faraday ||= Faraday.new({ url: base_uri })
  end

  def process_request(method, path)
    url = URI.parse(base_uri).merge(path).to_s

    response = faraday.run_request(method, url, nil, faraday.headers)

    if response.status == 401
      response = faraday.run_request(method, url, nil, faraday.headers) do |request|
        request.headers['Authorization'] = digest_auth_header(
          url,
          response.headers['www-authenticate'],
          method
        )
      end
    end

    response
  end

  def digest_auth_header(url, realm, method)
    uri = URI.parse(url)
    uri.user = auth[:user]
    uri.password = auth[:password]
    digest_auth = Net::HTTP::DigestAuth.new
    digest_auth.auth_header(uri, realm, method.upcase)
  end
end
