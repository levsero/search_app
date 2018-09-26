require 'database/tickets'

describe Tickets do
  let(:organizations) { double(:organizations) }
  let(:users) { double(:user) }
  let(:ticket_1) do
    {
      '_id' => 'uuid-1',
      'url' => 'http://initech.zendesk.com/api/v2/tickets/436bf9b0-1147-4c0a-8439-6f79833bff5b.json',
      'external_id' => '9210cdc9-4bee-485f-a078-35396cd74063',
      'created_at' => '2016-04-28T11:19:34 -10:00',
      'type' => 'incident',
      'subject' => 'A Catastrophe in Korea (North)',
      'description' => 'Nostrud ad sit velit cupidatat laboris ipsum nisi amet laboris ex exercitation amet et proident. Ipsum fugiat aute dolore tempor nostrud velit ipsum.',
      'priority' => 'high',
      'status' => 'pending',
      'submitter_id' => 1,
      'assignee_id' => 2,
      'organization_id' => 1,
      'tags' => [
        'Ohio',
        'Pennsylvania',
        'American Samoa',
        'Northern Mariana Islands'
      ],
      'has_incidents' => false,
      'due_at' => '2016-07-31T02:37:50 -10:00',
      'via' => 'web'
    }
  end
  let(:ticket_2) do
    {
      '_id' => 'uuid-2',
      'url' => 'http://initech.zendesk.com/api/v2/tickets/1a227508-9f39-427c-8f57-1b72f3fab87c.json',
      'external_id' => '3e5ca820-cd1f-4a02-a18f-11b18e7bb49a',
      'created_at' => '2016-04-14T08:32:31 -10:00',
      'type' => 'incident',
      'subject' => 'A Catastrophe in Micronesia',
      'description' => 'Aliquip excepteur fugiat ex minim ea aute eu labore. Sunt eiusmod esse eu non commodo est veniam consequat.',
      'priority' => 'low',
      'status' => 'hold',
      'submitter_id' => 1,
      'assignee_id' => 2,
      'organization_id' => 2,
      'tags' => [
        'Puerto Rico',
        'Idaho',
        'Oklahoma',
        'Louisiana'
      ],
      'has_incidents' => false,
      'due_at' => '2016-08-15T05:37:32 -10:00',
      'via' => 'chat'
    }
  end
  let(:ticket_3) do
    {
      '_id' => 'uuid-3',
      'url' => 'http://initech.zendesk.com/api/v2/tickets/2217c7dc-7371-4401-8738-0a8a8aedc08d.json',
      'external_id' => '3db2c1e6-559d-4015-b7a4-6248464a6bf0',
      'created_at' => '2016-07-16T12:05:12 -10:00',
      'type' => 'problem',
      'subject' => 'A Catastrophe in Hungary',
      'description' => 'Ipsum fugiat voluptate reprehenderit cupidatat aliqua dolore consequat. Consequat ullamco minim laboris veniam ea id laborum et eiusmod excepteur sint laborum dolore qui.',
      'priority' => 'normal',
      'status' => nil,
      'submitter_id' => 1,
      'assignee_id' => 2,
      'organization_id' => 2,
      'tags' => [
        'Massachusetts',
        'New York',
        'Minnesota',
        'New Jersey'
      ],
      'has_incidents' => true,
      'due_at' => '2016-08-06T04:16:06 -10:00',
      'via' => 'web'
    }
  end

  let(:tickets_hash) { [ticket_1, ticket_2, ticket_3] }

  subject(:tickets) do
    Tickets.new.add_data(tickets_hash, organizations, users)
  end

  describe '#add_data' do
    it 'succesfully creates a tickets instance' do
      expect(subject).to be
    end
  end

  describe '#find' do
    context 'and the user is in the list' do
      it 'returns the correct user' do
        expect(subject.find('uuid-2')).to equal(ticket_2)
      end
    end

    context 'and the user id does not exist' do
      it 'returns the correct user' do
        expect(subject.find(0)).to equal(nil)
      end
    end
  end

  describe '#find_by_organization' do
    context 'and the organization has a user' do
      it 'returns the correct tickets' do
        expect(subject.find_by_organization(1)).to eq([ticket_1])
      end
    end

    context 'and the organization has multiple tickets' do
      it 'returns the correct tickets' do
        expect(subject.find_by_organization(2)).to eq([ticket_2, ticket_3])
      end
    end

    context 'and the organization has no tickets' do
      it 'returns the correct user' do
        expect(subject.find_by_organization(0)).to eq([])
      end
    end
  end

  describe '#find_by' do
    let(:organization_1) { { id: 1, name: 'zendesk platform' } }
    let(:organization_2) { { id: 2, name: 'zendesk api' } }
    let(:user_1) { { id: 1, name: 'mike' } }
    let(:user_2) { { id: 2, name: 'jack' } }
    let(:user_3) { { id: 3, name: 'sam' } }
    let(:ticket_1_users) { [user_1] }
    let(:ticket_2_users) { [user_2, user_3] }
    let(:ticket_1_with_associations) { ticket_1.merge(submitter: ticket_1_users, assignee: ticket_2_users, organization: organization_1) }
    let(:ticket_2_with_associations) { ticket_2.merge(submitter: ticket_1_users, assignee: ticket_2_users, organization: organization_2) }
    let(:ticket_3_with_associations) { ticket_3.merge(submitter: ticket_1_users, assignee: ticket_2_users, organization: organization_2) }

    before do
      allow(organizations).to receive(:find).with(1).and_return(organization_1)
      allow(organizations).to receive(:find).with(2).and_return(organization_2)
      allow(users).to receive(:find).with(1).and_return(ticket_1_users)
      allow(users).to receive(:find).with(2).and_return(ticket_2_users)
    end

    context 'and the field is specified' do
      context 'and the field does not exist' do
        it 'returns an empty array' do
          expect(subject.find_by('justin', 'madeup')).to eq([])
        end
      end

      context 'and there no tickets that match' do
        it 'returns an empty array' do
          expect(subject.find_by('made up', 'type')).to eq([])
        end
      end

      context 'and there is a single user that matches' do
        it 'returns the correct user' do
          expect(subject.find_by('chat', 'via')).to eq([ticket_2_with_associations])
        end
      end

      context 'and there are multiple tickets that match' do
        it 'returns the tickets' do
          expect(subject.find_by('web', 'via')).to eq([ticket_1_with_associations, ticket_3_with_associations])
        end
      end

      context 'and the field is not a string' do
        it 'returns the tickets' do
          expect(subject.find_by('true', 'has_incidents')).to eq([ticket_3_with_associations])
        end
      end

      context 'and the field is an array' do
        it 'returns the tickets' do
          expect(subject.find_by('Ohio', 'tags')).to eq([ticket_1_with_associations])
        end
      end

      context 'and the field is nil' do
        it 'returns the tickets' do
          expect(subject.find_by('', 'status')).to eq([ticket_3_with_associations])
        end
      end
    end

    context 'and the field is empty' do
      context 'and there no tickets that match' do
        it 'returns an empty array' do
          expect(subject.find_by('justin', '')).to eq([])
        end
      end

      context 'and there is a single ticket that matches' do
        it 'returns the correct ticket' do
          expect(subject.find_by('chat', '')).to eq([ticket_2_with_associations])
        end
      end

      context 'and there are multiple tickets that match' do
        it 'returns the tickets' do
          expect(subject.find_by('web', '')).to eq([ticket_1_with_associations, ticket_3_with_associations])
        end
      end

      context 'and the value is in an array' do
        it 'returns the tickets' do
          expect(subject.find_by('Ohio', '')).to eq([ticket_1_with_associations])
        end
      end
    end
  end
end
