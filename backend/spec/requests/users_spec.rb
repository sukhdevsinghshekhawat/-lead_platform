require 'rails_helper'

RSpec.describe 'Users API', type: :request do
  let!(:admin) { create(:user, :admin) }
  let!(:member) { create(:user, :member) }
  let(:admin_token) { JwtService.encode(user_id: admin.id) }
  let(:member_token) { JwtService.encode(user_id: member.id) }

  describe 'GET /api/users' do
    it 'returns all users for admin' do
      get '/api/users', headers: { 'Authorization' => "Bearer #{admin_token}" }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']).to be_an(Array)
    end

    it 'returns all users for member (index is public to authenticated users)' do
      get '/api/users', headers: { 'Authorization' => "Bearer #{member_token}" }

      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /api/users' do
    it 'creates a user as admin' do
      expect {
        post '/api/users', params: { name: 'New User', email: 'new@example.com', password: 'password123', role: 'member' }, headers: { 'Authorization' => "Bearer #{admin_token}" }
      }.to change(User, :count).by(1)

      expect(response).to have_http_status(:created)
    end

    it 'returns 422 for member' do
      post '/api/users', params: { name: 'New User', email: 'new@example.com', password: 'password123', role: 'member' }, headers: { 'Authorization' => "Bearer #{member_token}" }

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe 'DELETE /api/users/:id' do
    it 'deletes user as admin' do
      delete "/api/users/#{member.id}", headers: { 'Authorization' => "Bearer #{admin_token}" }

      expect(response).to have_http_status(:no_content)
    end

    it 'returns 403 for member' do
      delete "/api/users/#{admin.id}", headers: { 'Authorization' => "Bearer #{member_token}" }

      expect(response).to have_http_status(:forbidden)
    end
  end
end
