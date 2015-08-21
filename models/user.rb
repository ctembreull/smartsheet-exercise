class User < ActiveRecord::Base

  has_one :home


  def to_json
    {
      email_address: email_address,
      first_name:    first_name,
      last_name:     last_name
    }.to_json
  end



  class << self

    def find_or_create_by(json)
      # in a more featureful application there would be some better error handling here,
      # but since we're just doing a demo here, we're going to be extremely naive about
      # our data integrity
      return nil unless json.is_a? Hash
      return nil if json['id'].nil?

      user =   self.find_by(smartsheet_id: json['id'])
      user ||= self.create(
        smartsheet_id: json['id'],
        email_address: json['email'],
        first_name:    json['firstName'] || '',
        last_name:     json['lastName'] || '',
        locale:        json['locale'] || '',
        time_zone:     json['timeZone'] || ''
      )
    end

    def find_by_token(token)
      return nil if (token.nil? || token.empty?)

      conn = Faraday.new('https://api.smartsheet.com')
      res  = conn.get('/2.0/users/me') do |req|
        req.headers['Authorization'] = "Bearer #{token}"
      end
      user_json = JSON.parse(res.body)
      user = self.find_or_create_by(user_json)
      user.update(token: token)
      user
    end
  end

end
