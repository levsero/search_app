require_relative './tables/database'
require 'json'

class SearchApp
  def initialize(organizations_path, users_path, tickets_path)
    @database = Database.initialize_from_files(organizations_path, users_path, tickets_path)
  rescue StandardError => e
    puts e.message
    puts 'error initializing database'
    raise e
  end

  def accept_inputs
    loop do
      puts 'Select a field to search'
      field = gets.chomp

      puts 'Select a value to search on'
      value = gets.chomp

      result = @database.search(value, field)

      puts JSON.pretty_generate(result)
    end
  end
end

app = SearchApp.new('data/organizations.json', 'data/users.json', 'data/tickets.json')
app.accept_inputs
