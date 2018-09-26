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
      puts 'Input a table, field, and value'
      table = gets.chomp.downcase
      unless @database.available_tables.include?(table)
        puts "table '#{table}' does not exist"
        next
      end

      puts 'Select a field to search'
      field = gets.chomp
      if field.empty?
        puts 'field cannot be empty'
        next
      end

      puts 'Select a value to search on'
      value = gets.chomp

      result = @database.search(table, field, value)

      puts JSON.pretty_generate(result)
    end
  end
end

app = SearchApp.new('data/organizations.json', 'data/tickets.json', 'data/users.json')
app.accept_inputs
