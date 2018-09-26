class Users
  def add_data(users, organizations, tickets)
    @users = users
    @indexed_by_id = index_by_id
    @indexed_by_organization = indexed_by_organization
    @organizations = organizations
    @tickets = tickets
    self
  end

  def find_by(field, value)
    @users.select do |user|
      if user[field].is_a? Array
        user[field].include?(value)
      else
        user[field].to_s == value
      end
    end.map { |user| user.merge(associations_for(user)) }
  end

  def find_by_organization(organization_id)
    @indexed_by_organization[organization_id].map { |user_id| find(user_id) }
  end

  def find(id)
    @indexed_by_id[id]
  end

  private

  def associations_for(user)
    {
      organization: @organizations.find(user['organization_id']),
      tickets: @tickets.find_by_user(user['_id'])
    }
  end

  def index_by_id
    @users.each_with_object({}) do |user, hash|
      hash[user['_id']] = user
    end
  end

  def indexed_by_organization
    @users.each_with_object(Hash.new { |h, k| h[k] = [] }) do |user, hash|
      hash[user['organization_id']] << user['_id']
    end
  end
end
