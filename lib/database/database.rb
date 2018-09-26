require_relative './organizations'
require_relative './users'
require_relative './tickets'
require 'json'

class Database
  def initialize(organizations_json, users_json, tickets_json)
    @database = {}

    organizations = Organizations.new
    users = Users.new
    tickets = Tickets.new

    organizations.add_data(JSON.parse(organizations_json), users, tickets)
    users.add_data(JSON.parse(users_json), organizations, tickets)
    tickets.add_data(JSON.parse(tickets_json), organizations, users)

    @database['users'] = users
    @database['tickets'] = tickets
    @database['organizations'] = organizations
  end

  def self.initialize_from_files(organizations_path, users_path, tickets_path)
    organizations_json = File.read(organizations_path)
    users_json = File.read(users_path)
    tickets_json = File.read(tickets_path)

    new(organizations_json, users_json, tickets_json)
  end

  def available_tables
    @database.keys
  end

  def search(value, field)
    result = []
    @database.values.each { |table| result << table.find_by(value, field) }
    result.flatten
  end
end
