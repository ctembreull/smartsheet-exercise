class Sheet < ActiveRecord::Base

  belongs_to :container
  belongs_to :home

  def columns
    @columns = []
    conn = Faraday.new('https://api.smartsheet.com')
  end

  def self.find_or_create_from(sheet, container_id, home_id)
    Sheet.find_by(smartsheet_id: sheet['id']) || Sheet.create(
      smartsheet_id: sheet['id'],
      container_id:  container_id,
      home_id:       home_id,
      name:          sheet['name'],
      access_level:  sheet['accessLevel'],
      permalink:     sheet['permalink'],
      created_at:    sheet['createdAt'],
      modified_at:   sheet['modifiedAt']
    )
  end


end
