class DeprecatedFolder

  # belongs_to :home
  # has_many   :sheets, dependent: :destroy
  # has_many   :folders, dependent: :destroy

  attr_reader :sheets, :folders, :id, :name, :permalink

  def find_or_create_from(folder_json)
  end


  def initialize(folder)
    @id        = folder['id']
    @name      = folder['name']
    @permalink = folder['permalink']

    @sheets  = []
    @folders = []

    folder['sheets'].each { |s| @sheets << Sheet.new(s) } unless folder['sheets'].nil?
    folder['folders'].each { |f| @folders << Folder.new(f) } unless folder['folders'].nil?
  end
end
