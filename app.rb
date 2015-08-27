require File.expand_path('../config/environment', __FILE__)

module Smartsheet
  class App < Sinatra::Application

    SS_API_URL   = 'https://api.smartsheet.com'
    SS_API_VERSION = '2.0'
    SS_CLIENTID  = ENV['SS_CLIENTID'] || ''
    SS_APPSECRET = ENV['SS_APPSECRET'] || ''

    configure do
      register Sinatra::Reloader if development?
      enable :logging
      enable :sessions
      set :session_secret, ENV['SESSION_SECRET'] || 'TODO_CHANGE_ME'
      set :public_folder, File.dirname(__FILE__) + '/public'
    end

    before do
    end

    after do
    end

    get '/' do
      erb :base, :layout => false do
        erb :index
      end
    end

    get '/app' do
      if session[:token].nil? or (DateTime.now.to_i >= session[:expiry])
        redirect gen_auth_link
      else
        # TODO: token renewal flow
      end

      @user = User.find_by_token(session[:token])
      redirect url('/signout') if @user.nil?
      @home = @user.home.refresh

      erb :base, layout: false do
        erb :app
      end

    end

    get '/authorize' do
      # 1. Ensure that the state variable we got back matches the one we stored in the session
      unless valid_state? params[:state]
        flash({errorCode: 'StateError', message: 'Invalid state, cannot continue'})
        error
        halt 500
      end

      # 2. Send request for an actual auth token using the code we got back from Smartsheet
      unless get_token(params[:code], params[:expires_in])
        # our flash should have been set by the get_token method
        error
        halt 500
      end

      # 3. If we got here, we presume the token get operation was successful.
      redirect url('/app')
    end

    # /signout is a simple way of
    get '/signout' do
      @user = User.find_by_token(session[:token])
      @user.update(token: nil) unless @user.nil?
      session[:token] = nil
      session[:expiry] = nil

      flash({message: 'Signed out from Smartsheet'})
      redirect url('/')
    end

    get '/error' do
      raise Exception, "I meant to do that"
    end

    get '/sheets/:sheet_id' do
      conn = Faraday.new(SS_API_URL)
      res  = conn.get("/#{SS_API_VERSION}/sheets/#{params[:sheet_id]}") do |req|
        req.headers['Authorization'] = "Bearer #{session[:token]}"
      end
      sheet = JSON.parse(res.body)

      halt 200, {'Content-Type' => 'application/json'}, sheet
    end

    get '/sheets/:sheet_id/columns' do

      #halt 200, {'Content-Type' => 'application/json'}, {columns: ['woohoo']}.to_json

      conn = Faraday.new(SS_API_URL)
      res  = conn.get("/#{SS_API_VERSION}/sheets/#{params[:sheet_id]}") do |req|
        req.headers['Authorization'] = "Bearer #{session[:token]}"
      end
      sheet = JSON.parse(res.body)

      halt 200, {'Content-Type' => 'application/json'}, {columns: sheet['columns']}.to_json
    end

    def error
      @flash = session.delete(:flash)
      erb :base, layout: false do
        erb :error
      end
    end


    ### HELPER METHODS
    # => In an application designed for any sort of maintenance, these would be
    # => declared elsewhere and required.
    def valid_state?(state)
      session[:state] == state
    end

    def get_token(code, expiry)

      # Parameters for token request as specified at:
      # http://smartsheet-platform.github.io/api-docs/?csharp#oauth-flow
      params = {
        grant_type:   'authorization_code',
        client_id:    SS_CLIENTID,
        code:         code,
        hash:         generate_hash(code)
      }

      # TODO: refactor connection into a shared resource
      # Make HTTP POST request to token endpoint
      conn = Faraday.new(SS_API_URL)
      res  = conn.post("/#{SS_API_VERSION}/token", params) do |req|
        req.headers['Content-Type'] = 'application/x-www-form-urlencoded'
      end
      json = JSON.parse(res.body)

      unless (json['errorCode'].nil?)
        flash({errorCode: json['errorCode'], message: json['message']})
        return false
      end

      session.delete(:errorCode)
      session.delete(:message)

      session[:token]  = json['access_token']
      session[:expiry] = (DateTime.now + json['expires_in'].seconds).to_i

      true
    end

    def generate_hash(code)
      Digest::SHA256.hexdigest(SS_APPSECRET + "|#{code}")
    end

    def generate_state
      (0..6).map { ('A'..'Z').to_a[rand(26)] }.join
    end

    def gen_auth_link
      state = generate_state
      session[:state] = state
      base_url = "https://www.smartsheet.com/b/authorize?"
      base_url += "response_type=#{URI::encode('code')}&"
      base_url += "client_id=#{URI::encode(SS_CLIENTID)}&"
      base_url += "scope=#{URI::encode('READ_SHEETS')}&"
      base_url += "state=#{URI::encode(session[:state])}&"
      #base_url += "redirect_uri=#{URI::encode(uri('/authorize'))}" if ENV['RACK_ENV'] != 'production'
    end

    def flash(obj)
      session[:flash] = obj
    end

    ### In case we're called by something like `ruby app.rb`, we can still run
    run! if app_file == $0
  end
end
