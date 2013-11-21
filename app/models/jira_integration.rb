require 'net/http'
require 'net/https'
require 'open-uri'

class JIRAIntegration < Integration
  attr_accessible :username, :password
  attr_accessor :username, :password

  validate :credentials_correctness, on: :create
  validates_uniqueness_of :api_key

  def service_name
    "JIRA"
  end

  private

  def credentials_correctness
    if api_key.present?
      validate_credentials_with_token
    elsif username.present? && password.present?
      validate_credentials_with_username_and_password
    else
      errors.add(:api_key, 'you need to provide login credentials')
    end
  rescue Exception
    errors.add(:api_key, 'could not get response from JIR; Provided credentials might be invalid')
  end

  def validate_credentials_with_token

  end

 def validate_credentials_with_username_and_password
    https = Net::HTTP.new(authentication_uri.host, authentication_uri.port)
    https.use_ssl = true
    https.verify_mode = OpenSSL::SSL::VERIFY_NONE
    req = Net::HTTP::Post.new(authentication_uri.path)
    req.basic_auth username, password
    req.body = '{"scopes": ["user", "public_repo", "repo"]}'
    res = https.request(req)
    puts res.body
    token = JSON.parse(res.body)["value"]
    if token.present?
      self.api_key = token
      self.source_id = username
    else
      errors.add(:password, 'provided username/password combination is invalid')
    end
  rescue StandardError => e
    Rails.logger.warn "Exception when validating Github integration: #{e.class}: #{e.message}"

    errors.add(:password, 'provided username/password combination is invalid')
  end

  def authentication_uri
    URI('https://jira.atlassian.com/rest/auth/latest/session')
  end

  def authentication_token_uri
    URI('https://jira.atlassian.com/rest/api/latest/user')
  end
end
