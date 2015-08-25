class Container < ActiveRecord::Base
  has_many :sheets,  foreign_key: :container_id, dependent: :destroy
  has_many :folders, foreign_key: :container_id, dependent: :destroy
end

class Home < Container

  has_many :workspaces, foreign_key: :container_id, dependent: :destroy
  has_many :containers, foreign_key: :home_id

  def user
    User.find_by(smartsheet_id: smartsheet_id)
  end

  def refresh(debug = false)
    conn = Faraday.new(Smartsheet::App::SS_API_URL)
    res  = conn.get('/2.0/home') do |req|
      req.headers['Authorization'] = "Bearer #{user.token}"
    end
    home_json = JSON.parse(res.body)

    if debug
      return home_json
    else
      destroy_structure
      create_structure(home_json)
    end
  end

  def destroy_structure
    sheets.delete_all
    folders.delete_all
    workspaces.delete_all
  end

  def create_structure(structure)
    structure['sheets'].each do |sheet|
      sheets << Sheet.find_or_create_from(sheet, id, id)
    end

    structure['folders'].each do |folder|
      folders << Folder.create_structure(folder, id, id)
    end

    structure['workspaces'].each do |workspace|
      workspaces << Workspace.create_structure(workspace, id, id)
    end
  end

  def find_or_create_for(user)
    Home.find_by(smartsheet_id: user.smartsheet_id) || Home.create(smartsheet_id: user.smartsheet_id)
  end
end

class Workspace < Container

  belongs_to :home

  def self.create_structure(structure, parent, home)
    structure['sheets']  ||= []
    structure['folders'] ||= []
    workspace = Workspace.find_or_create_from(structure, parent, home)
    structure['sheets'].each do |sheet|
      workspace.sheets << Sheet.find_or_create_from(sheet, workspace.id, home)
    end
    structure['folders'].each do |folder|
      workspace.folders << Folder.create_structure(folder, workspace.id, home)
    end
    workspace
  end

  def self.find_or_create_from(wspace, parent, home)
    workspace = self.find_by(smartsheet_id: wspace['id']) || Workspace.create(
      smartsheet_id: wspace['id'],
      container_id:  parent,
      home_id:       home,
      name:          wspace['name'],
      permalink:     wspace['permalink'],
      access_level:  wspace['accessLevel']
    )
  end
end

class Folder < Container

  belongs_to :home

  def self.create_structure(structure, parent, home)
    structure['sheets']  ||= []
    structure['folders'] ||= []
    folder = Folder.find_or_create_from(structure, parent, home)
    structure['sheets'].each do |sheet|
      folder.sheets << Sheet.find_or_create_from(sheet, folder.id, home)
    end
    structure['folders'].each do |subfolder|
      folder.folders << Folder.create_structure(subfolder, folder.id, home)
    end
    folder
  end

  def self.find_or_create_from(folder_obj, parent, home)
    folder = self.find_by(smartsheet_id: folder_obj['id']) || Folder.create(
      smartsheet_id: folder_obj['id'],
      container_id:  parent,
      home_id:       home,
      name:          folder_obj['name'],
      permalink:     folder_obj['permalink']
    )
  end
end
