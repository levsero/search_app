require 'tables/users'
require 'json'

describe Users do
  let(:organizations) { double(:organizations) }
  let(:tickets) { double(:ticket) }
  let(:user_1) do
    {
      '_id' => 1,
      'url' => 'http =>//initech.zendesk.com/api/v2/users/1.json',
      'external_id' => '74341f74-9c79-49d5-9611-87ef9b6eb75f',
      'name' => 'Francisca Rasmussen',
      'alias' => nil,
      'created_at' => '2016-04-15T05 =>19 =>46 -10 =>00',
      'active' => true,
      'verified' => true,
      'shared' => true,
      'locale' => 'en-AU',
      'timezone' => 'Armenia',
      'last_login_at' => '2013-08-04T01 =>03 =>27 -10 =>00',
      'email' => 'coffeyrasmussen@flotonic.com',
      'phone' => '8335-422-718',
      'signature' => "Don't Worry Be Happy!",
      'organization_id' => 1,
      'tags' => [
        'Springville',
        'Sutton',
        'Hartsville/Hartley',
        'Diaperville'
      ],
      'suspended' => true,
      'role' => 'end-user'
    }
  end
  let(:user_2) do
    {
      '_id' => 2,
      'active' => true,
      'alias' => 'Miss Joni',
      'created_at' => '2016-06-23T10:31:39 -10:00',
      'email' => 'jonibarlow@flotonic.com',
      'external_id' => 'c9995ea4-ff72-46e0-ab77-dfe0ae1ef6c2',
      'last_login_at' => '2012-04-12T04:03:28 -10:00',
      'locale' => 'zh-CN',
      'name' => 'Cross Barlow',
      'organization_id' => 2,
      'phone' => '9575-552-585',
      'role' => 'admin',
      'shared' => false,
      'signature' => "Don't Worry Be Happy!",
      'suspended' => false,
      'tags' => %w[Foxworth Woodlands Herlong Henrietta],
      'timezone' => 'Armenia',
      'url' => 'http://initech.zendesk.com/api/v2/users/2.json',
      'verified' => true
    }
  end
  let(:user_3) do
    {
      '_id' => 3,
      'active' => true,
      'alias' => 'Miss Joni',
      'created_at' => '2016-06-23T10:31:39 -10:00',
      'email' => 'jonibarlow@flotonic.com',
      'external_id' => 'c9995ea4-ff72-46e0-ab77-dfe0ae1ef6c2',
      'last_login_at' => '2012-04-12T04:03:28 -10:00',
      'locale' => 'zh-CN',
      'name' => 'Cross Barlow',
      'organization_id' => 2,
      'phone' => '9575-552-585',
      'role' => 'end-user',
      'shared' => false,
      'signature' => "Don't Worry Be Happy!",
      'suspended' => false,
      'tags' => %w[Foxworth Woodlands Herlong Henrietta],
      'timezone' => 'Melbourne',
      'url' => 'http://initech.zendesk.com/api/v2/users/2.json',
      'verified' => true
    }
  end

  let(:users_hash) { [user_1, user_2, user_3] }

  subject(:users) do
    Users.new.add_data(users_hash, organizations, tickets)
  end

  describe '#add_data' do
    it 'succesfully creates a users instance' do
      expect(subject).to be
    end
  end

  describe '#find' do
    context 'and the user is in the list' do
      it 'returns the correct user' do
        expect(subject.find(2)).to equal(user_2)
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
      it 'returns the correct users' do
        expect(subject.find_by_organization(1)).to eq([user_1])
      end
    end

    context 'and the organization has multiple users' do
      it 'returns the correct users' do
        expect(subject.find_by_organization(2)).to eq([user_2, user_3])
      end
    end

    context 'and the organization has no users' do
      it 'returns the correct user' do
        expect(subject.find_by_organization(0)).to eq([])
      end
    end
  end

  describe '#find_by' do
    let(:organization_1) { { id: 1, name: 'zendesk platform' } }
    let(:organization_2) { { id: 2, name: 'zendesk api' } }
    let(:ticket_1) { { id: 1, desciption: 'server down' } }
    let(:ticket_2) { { id: 2, desciption: 'need graphql' } }
    let(:ticket_3) { { id: 3, desciption: 'need relay' } }
    let(:user_1_tickets) { [ticket_1] }
    let(:user_2_tickets) { [ticket_2, ticket_2] }
    let(:user_1_with_associations) { user_1.merge(tickets: user_1_tickets, organization: organization_1) }
    let(:user_2_with_associations) { user_2.merge(tickets: user_2_tickets, organization: organization_2) }

    before do
      allow(organizations).to receive(:find).with(1).and_return(organization_1)
      allow(organizations).to receive(:find).with(2).and_return(organization_2)
      allow(tickets).to receive(:find_by_user).with(1).and_return(user_1_tickets)
      allow(tickets).to receive(:find_by_user).with(2).and_return(user_2_tickets)
    end

    context 'and the field does not exist' do
      it 'returns an empty array' do
        expect(subject.find_by('made up', 'justin')).to eq([])
      end
    end

    context 'and there no users that match' do
      it 'returns an empty array' do
        expect(subject.find_by('name', 'justin')).to eq([])
      end
    end

    context 'and there is a single user that matches' do
      it 'returns the correct user' do
        expect(subject.find_by('role', 'admin')).to eq([user_2_with_associations])
      end
    end

    context 'and there are multiple users that match' do
      it 'returns the users' do
        expect(subject.find_by('timezone', 'Armenia')).to eq([user_1_with_associations, user_2_with_associations])
      end
    end

    context 'and the field is not a string' do
      it 'returns the user' do
        expect(subject.find_by('shared', 'true')).to eq([user_1_with_associations])
      end
    end

    context 'and the field is an array' do
      it 'returns the users' do
        expect(subject.find_by('timezone', 'Armenia')).to eq([user_1_with_associations, user_2_with_associations])
      end
    end

    context 'and the field is nil' do
      it 'returns the users' do
        expect(subject.find_by('alias', '')).to eq([user_1_with_associations])
      end
    end
  end
end
