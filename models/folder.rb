class Folder
  attr_reader :sheets, :folders, :id, :name, :permalink
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
