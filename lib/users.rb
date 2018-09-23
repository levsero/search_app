class Users
  def initialize(users, organizations, tickets)
    @users = users
    @indexed_by_id = index_by_id
    @organizations = organizations
    @tickets = tickets
  end

  def find_by(field, value)
    @users.select do |user|
      user[field] == value.to_s
    end.map { |user| user.merge(associations_for(user)) }
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
end
