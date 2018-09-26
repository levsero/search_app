require 'tables/database'

describe Database do
  let(:user) { double(:user) }
  let(:organization) { double(:organization) }
  let(:ticket) { double(:ticket) }
  let(:organizations) { double(:organizations, add_data: nil, find_by: [organization]) }
  let(:users) { double(:users, add_data: nil, find_by: [user]) }
  let(:tickets) { double(:tickets, add_data: nil, find_by: [ticket]) }

  before do
    allow(Users).to receive(:new).and_return(users)
    allow(Organizations).to receive(:new).and_return(organizations)
    allow(Tickets).to receive(:new).and_return(tickets)
  end

  describe '.new' do
    before { Database.new('{"organizations": []}', '{"users": []}', '{"tickets": []}') }

    it 'makes the correct calls' do
      expect(users).to have_received(:add_data).with({ 'users' => [] }, organizations, tickets)
      expect(organizations).to have_received(:add_data).with({ 'organizations' => [] }, users, tickets)
      expect(tickets).to have_received(:add_data).with({ 'tickets' => [] }, organizations, users)
    end
  end

  describe '#available_tables' do
    let(:database) { Database.new('{"organizations": []}', '{"users": []}', '{"tickets": []}') }

    it 'returns the correct tables' do
      expect(database.available_tables).to eq(%w[users tickets organizations])
    end
  end

  describe '#search' do
    let(:database) { Database.new('{"organizations": []}', '{"users": []}', '{"tickets": []}') }

    it 'combines the results from all tables' do
      expect(database.search('users', '_id', '234')).to eq([user, ticket, organization])
    end
  end
end
