class Organizations
  def add_data(organizations, users, tickets)
    @organizations = organizations
    @indexed_by_id = index_organizations
    @users = users
    @tickets = tickets
    self
  end

  def find_by(field, value)
    @organizations.select do |organization|
      if organization[field].is_a? Array
        organization[field].include?(value)
      else
        organization[field].to_s == value
      end
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
