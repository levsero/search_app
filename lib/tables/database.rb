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

  def self.initialize_from_files(_organizations_path, _users_path, _tickets_path)
    organizations_json = File.read('data/organizations.json')
    users_json = File.read('data/users.json')
    tickets_json = File.read('data/tickets.json')

    new(organizations_json, users_json, tickets_json)
  end

  def available_tables
    @database.keys
  end

  def search(table, field, value)
    @database[table].find_by(field, value)
  end
end
