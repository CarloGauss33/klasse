require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'Factory' do
    it 'has a valid factory' do
      expect(create(:user)).to be_valid
    end
  end

  describe 'Validations' do
    it 'is invalid without mail' do
      expect(build(:user, email: nil)).not_to be_valid
    end
  end

  describe 'Methods' do
    describe '#self.by_provider_and_uid' do
      let!(:user) { create(:user) }
      let!(:provider) do
        OauthProvider.create(
          provider: 'google_oauth2',
          uid: '123456789',
          user: user
        )
      end

      it 'returns the user by provider and uid' do
        expect(
          described_class.by_provider_and_uid(provider.provider, provider.uid)
        ).to eq(user)
      end
    end

    describe '#self.create_from_provider_data' do
      let(:provider_data) do
        OmniAuth::AuthHash.new(
          provider: 'google_oauth2',
          uid: '123456789',
          info: {
            email: 'test@example.com',
            first_name: 'John',
            last_name: 'Doe'
          }
        )
      end

      it 'creates a user from provider data' do
        expect do
          described_class.create_from_provider_data(provider_data)
        end.to change { described_class.count }.by(1)
      end
    end

    describe '.full_name' do
      it 'returns the full name of the user' do
        user = create(:user, names: 'John Joe', last_names: 'Doe Dae')
        expect(user.full_name).to eq('John Joe Doe Dae')
      end
    end

    describe '.first_name' do
      it 'returns the first name of the user' do
        user = create(:user, names: 'John Joe')
        expect(user.first_name).to eq('John')
      end
    end

    describe '.username' do
      it 'returns the username of the user' do
        user = create(:user, email: 'test@example.com')

        expect(user.username).to eq('test')
      end
    end
  end

  describe 'Associations' do
    it { is_expected.to have_many(:students) }
    it { is_expected.to have_many(:course_classes).through(:students) }
  end
end
