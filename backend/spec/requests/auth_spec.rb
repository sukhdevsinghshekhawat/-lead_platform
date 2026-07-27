require 'rails_helper'

RSpec.describe 'Authentication', type: :request do
  describe 'POST /api/login' do
    let!(:user) { create(:user, email: 'admin@example.com', password: 'password123') }

    it 'returns token and user on valid credentials' do
      post '/api/login', params: { email: 'admin@example.com', password: 'password123' }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['token']).to be_present
      expect(json['user']['email']).to eq('admin@example.com')
    end

    it 'returns 401 on invalid password' do
      post '/api/login', params: { email: 'admin@example.com', password: 'wrong' }

      expect(response).to have_http_status(:unauthorized)
      json = JSON.parse(response.body)
      expect(json['error']).to eq('Invalid email or password')
    end

    it 'returns 401 on non-existent user' do
      post '/api/login', params: { email: 'nobody@example.com', password: 'password123' }

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe 'GET /api/me' do
    let!(:user) { create(:user) }
    let(:token) { JwtService.encode(user_id: user.id) }

    it 'returns current user with valid token' do
      get '/api/me', headers: { 'Authorization' => "Bearer #{token}" }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['user']['email']).to eq(user.email)
    end

    it 'returns 401 without token' do
      get '/api/me'

      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns 401 with invalid token' do
      get '/api/me', headers: { 'Authorization' => 'Bearer invalid' }

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
