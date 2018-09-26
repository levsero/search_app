class Tickets
  def initialize(tickets, organizations, users)
    @tickets = tickets
    @indexed_by_id = index_by_id
    @indexed_by_organization = indexed_by_organization
    @indexed_by_user = indexed_by_organization
    @organizations = organizations
    @users = users
  end

  def find_by(field, value)
    @tickets.select do |ticket|
      if ticket[field].is_a? Array
        ticket[field].include?(value)
      else
        ticket[field].to_s == value
      end
    end.map { |ticket| ticket.merge(associations_for(ticket)) }
  end

  def find_by_organization(organization_id)
    @indexed_by_organization[organization_id].map { |ticket_id| find(ticket_id) }
  end

  def find_by_user(user_id)
    @indexed_by_user[user_id].map { |ticket_id| find(ticket_id) }
  end

  def find(id)
    @indexed_by_id[id]
  end

  private

  def associations_for(ticket)
    {
      organization: @organizations.find(ticket['organization_id']),
      assignee: @users.find(ticket['assignee_id']),
      submitter: @users.find(ticket['submitter_id'])
    }
  end

  def index_by_id
    @tickets.each_with_object({}) do |ticket, hash|
      hash[ticket['_id']] = ticket
    end
  end

  def indexed_by_organization
    @tickets.each_with_object(Hash.new { |h, k| h[k] = [] }) do |ticket, hash|
      hash[ticket['organization_id']] << ticket['_id']
    end
  end

  def indexed_by_user
    @tickets.each_with_object(Hash.new { |h, k| h[k] = [] }) do |ticket, hash|
      hash[ticket['assignee_id']] << ticket['_id']
      hash[ticket['submitter_id']] << ticket['_id']
    end
  end
end
