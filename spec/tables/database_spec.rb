require 'tables/database'

describe Database do
  let(:organizations) { double(:organizations, add_data: nil, find_by: []) }
  let(:users) { double(:users, add_data: nil, find_by: []) }
  let(:tickets) { double(:tickets, add_data: nil, find_by: []) }

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

    context 'when calling users' do
      before do
        database.search('users', '_id', '234')
      end

      it 'calls the users table' do
        expect(users).to have_received(:find_by).with('_id', '234')
      end
    end

    context 'when calling organizations' do
      before do
        database.search('organizations', 'name', 'zendesk')
      end

      it 'calls the organizations table' do
        expect(organizations).to have_received(:find_by).with('name', 'zendesk')
      end
    end

    context 'when calling tickets' do
      before do
        database.search('tickets', 'description', 'flooded')
      end

      it 'calls the tickets table' do
        expect(tickets).to have_received(:find_by).with('description', 'flooded')
      end
    end
  end
end
