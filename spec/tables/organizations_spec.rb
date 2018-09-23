require 'tables/organizations'
require 'json'

describe Organizations do
  let(:users) { double(:users) }
  let(:tickets) { double(:ticket) }
  let(:organization_1) do
    {
      "_id" => 1,
      "url" => "http://initech.zendesk.com/api/v2/organizations/101.json",
      "external_id" => "9270ed79-35eb-4a38-a46f-35725197ea8d",
      "name" => "Enthaze",
      "domain_names" => [
        "kage.com",
        "ecratic.com",
        "endipin.com",
        "zentix.com"
      ],
      "created_at" => "2016-05-21T11:10:28 -10:00",
      "details" => "MegaCorp",
      "shared_tickets" => false,
      "tags" => [
        "Fulton",
        "West",
        "Rodriguez",
        "Farley"
      ]
    }
  end
  let(:organization_2) do
    {
      "_id" => 2,
      "url" => "http://initech.zendesk.com/api/v2/organizations/102.json",
      "external_id" => "7cd6b8d4-2999-4ff2-8cfd-44d05b449226",
      "name" => "Nutralab",
      "domain_names" => [
        "trollery.com",
        "datagen.com",
        "bluegrain.com",
        "dadabase.com"
      ],
      "created_at" => "2016-04-07T08:21:44 -10:00",
      "details" => "Non profit",
      "shared_tickets" => false,
      "tags" => [
        "Cherry",
        "Collier",
        "Fuentes",
        "Trevino"
      ]
    }
  end
  let(:organization_3) do
    {
      "_id" => 3,
      "url" => "http://initech.zendesk.com/api/v2/organizations/103.json",
      "external_id" => "e73240f3-8ecf-411d-ad0d-80ca8a84053d",
      "name" => "Plasmos",
      "domain_names" => [
        "comvex.com",
        "automon.com",
        "verbus.com",
        "gogol.com"
      ],
      "created_at" => "2016-05-28T04:40:37 -10:00",
      "details" => "profit",
      "shared_tickets" => true,
      "tags" => [
        "Parrish",
        "Lindsay",
        "Armstrong",
        "Vaughn"
      ]
    }
  end

  let(:organizations_hash) { [organization_1, organization_2, organization_3] }

  subject(:organizations) do
    Organizations.new(organizations_hash, users, tickets)
  end

  describe '.new' do
    it 'succesfully creates a organizations instance' do
      expect(subject).to be
    end
  end

  describe '#find' do
    context 'and the user is in the list' do
      it 'returns the correct user' do
        expect(subject.find(2)).to eq(organization_2)
      end
    end

    context 'and the user id does not exist' do
      it 'returns the correct user' do
        expect(subject.find(0)).to equal(nil)
      end
    end
  end

  describe '#find_by' do
    let(:user_1) { { id: 1, name: 'zendesk platform' } }
    let(:user_2) { { id: 2, name: 'zendesk api' } }
    let(:ticket_1) { { id: 1, desciption: 'server down' } }
    let(:ticket_2) { { id: 2, desciption: 'need graphql' } }
    let(:ticket_3) { { id: 3, desciption: 'need relay' } }
    let(:organization_1_tickets) { [ticket_1] }
    let(:organization_2_tickets) { [ticket_2, ticket_2] }
    let(:organization_1_users) { [user_1] }
    let(:organization_2_users) { [user_2, user_2] }
    let(:organization_1_with_associations) { organization_1.merge(tickets: organization_1_tickets, users: organization_1_users) }
    let(:organization_2_with_associations) { organization_2.merge(tickets: organization_2_tickets, users: organization_2_users) }

    before do
      allow(users).to receive(:find_by_organization).with(1).and_return(organization_1_users)
      allow(users).to receive(:find_by_organization).with(2).and_return(organization_2_users)
      allow(tickets).to receive(:find_by_organization).with(1).and_return(organization_1_tickets)
      allow(tickets).to receive(:find_by_organization).with(2).and_return(organization_2_tickets)
    end

    context 'and the field does not exist' do
      it 'returns an empty array' do
        expect(subject.find_by('made up', 'justin')).to eq([])
      end
    end

    context 'and there no organizations that match' do
      it 'returns an empty array' do
        expect(subject.find_by('name', 'justin')).to eq([])
      end
    end

    context 'and there is a single user that matches' do
      it 'returns the correct user' do
        expect(subject.find_by('details', 'Non profit')).to eq([organization_2_with_associations])
      end
    end

    context 'and there are multiple organizations that match' do
      it 'returns the organizations' do
        expect(subject.find_by('shared_tickets', 'false')).to eq([organization_1_with_associations, organization_2_with_associations])
      end
    end
  end
end
