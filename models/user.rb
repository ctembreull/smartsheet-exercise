class User < ActiveRecord::Base

  # We've used a bit of a hack here, making the Home#smartsheet_id match the
  # User#smartsheet_id. This makes a mess of ActiveRecord's associations, so
  # for these purposes, we're going to simply provide the "relation" as a
  # class method.
  def home
    Home.find_by(smartsheet_id: smartsheet_id)
  end

  # In lieu of a more full-featured serializer, we can simply do this. There
  # are more robust ways, but this provides the basics.
  def to_json
    {
      email_address: email_address,
      first_name:    first_name,
      last_name:     last_name
    }.to_json
  end

  # ActiveRecord::Model#find_or_create_by is a little bit limited, so we provide
  # a somewhat parallel functionality to allow the creation and persistence
  # of a fully-populated object from the JSON we get back from an API call.
  def self.find_or_create_from(json)
    # in a more featureful application there would be some better error handling here,
    # but since we're just doing a demo here, we're going to be extremely naive about
    # our data integrity
    return nil unless json.is_a? Hash
    return nil if json['id'].nil?

    user = self.find_by(smartsheet_id: json['id'])
    if user.nil?
      user = self.create(
        smartsheet_id: json['id'],
        email_address: json['email'],
        first_name:    json['firstName'] || '',
        last_name:     json['lastName'] || '',
        locale:        json['locale'] || '',
        time_zone:     json['timeZone'] || ''
      )
      # This should work; we create a user, create their home structure at the same time
      Home.create(smartsheet_id: user.smartsheet_id)
    end
    return user
  end

  # Attempt to find a user where all we know is their access_token, since that's all that
  # comes in on a session.
  def self.find_by_token(token)
    return nil if (token.nil? || token.empty?)

    # Try to get the user from the database with a stored token first.
    user = User.find_by(token: token)

    # If that doesn't work, we take that access token and ask Smartsheet for
    # the user's info, which will include an actual smartsheet_id that will
    # be used in the find_or_create_from method.
    if user.nil?
      conn = Faraday.new('https://api.smartsheet.com')
      res  = conn.get('/2.0/users/me') do |req|
        req.headers['Authorization'] = "Bearer #{token}"
      end
      user_json = JSON.parse(res.body)
      user      = self.find_or_create_from(user_json)
      user.update(token: token)
    end

    return user
  end

end
