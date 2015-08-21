class HomeStructure
  attr_reader :sheets, :folders, :workspaces
  def initialize(json_str)
    json = JSON.parse(json_str)

    @sheets     = []
    @folders    = []
    @workspaces = []

    json['sheets'].each { |s| @sheets << Sheet.new(s) }
    json['folders'].each { |f| @folders << Folder.new(f) }
    json['workspaces'].each { |w| @workspaces << Workspace.new(w) }
  end
end
