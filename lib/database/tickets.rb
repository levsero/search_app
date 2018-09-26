require_relative './base_table'

class Tickets < BaseTable
  def add_data(tickets, organizations, users)
    @tickets = tickets
    @indexed_by_id = index_by_id
    @indexed_by_organization = indexed_by_organization
    @indexed_by_user = indexed_by_user
    @organizations = organizations
    @users = users
    self
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

  def data
    @tickets
  end

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
