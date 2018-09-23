class Organizations
  def initialize(organizations, users, tickets)
    @organizations = organizations
    @indexed_by_id = index_organizations
    @users = users
    @tickets = tickets
  end

  def find_by(field, value)
    @organizations.select do |organization|
      organization[field].to_s == value
    end.map { |organization| organization.merge(associations_for(organization)) }
  end

  def find(id)
    @indexed_by_id[id]
  end

  private

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
