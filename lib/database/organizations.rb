require_relative './base_table'

class Organizations < BaseTable
  def add_data(organizations, users, tickets)
    @organizations = organizations
    @indexed_by_id = index_organizations
    @users = users
    @tickets = tickets
    self
  end

  def find(id)
    @indexed_by_id[id]
  end

  private

  def data
    @organizations
  end

  def associations_for(organization)
    {
      users: @users.find_by_organization(organization['_id']),
      tickets: @tickets.find_by_organization(organization['_id'])
    }
  end

  def index_organizations
    @organizations.each_with_object({}) do |organization, hash|
      hash[organization['_id']] = organization
    end
  end
end
