require 'pp'

class Home < ActiveRecord::Base

  belongs_to :user

  def explode
    return HomeStructure.new(raw_json)
  end

  def refresh
    conn = Faraday.new('https://api.smartsheet.com')
    res  = conn.get('/2.0/home') do |req|
      req.headers['Authorization'] = "Bearer #{user.token}"
    end
    user_json = JSON.parse(res.body)
    update(raw_json: user_json.to_json)
  end

  def to_json
    raw_json.to_s
  end

  class << self
    # For this specific use case, we're overriding the find_or_create_by method
    # and replacing it with our more specific functionality.
    def find_or_create_by(user_obj)
      home   = self.find_by(user: user_obj)
      home ||= self.create(user: user_obj)
    end
  end

end
