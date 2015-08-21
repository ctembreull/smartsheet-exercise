class Sheet
  attr_reader :id, :name, :accessLevel, :permalink, :created_at, :modified_at, :columns
  def initialize(sheet)
    @id          = sheet['id']
    @name        = sheet['name']
    @accessLevel = sheet['accessLevel']
    @permalink   = sheet['permalink']
    @created_at  = sheet['createdAt']
    @modified_at = sheet['modifiedAt']
  end

  def columns
    @columns = []
    conn = Faraday.new('https://api.smartsheet.com')
  end
end
