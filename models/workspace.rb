class DeprecatedWorkspace
  attr_reader :sheets, :id, :name, :access_level, :permalink
  def initialize(workspace)
    @id           = workspace['id']
    @name         = workspace['name']
    @access_level = workspace['accessLevel']
    @permalink    = workspace['permalink']
    @sheets       = []

    workspace['sheets'].each { |s| @sheets << Sheet.new(s) } unless workspace['sheets'].nil?
  end
end
