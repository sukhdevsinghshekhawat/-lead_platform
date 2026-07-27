require 'rails_helper'

RSpec.describe 'Dashboard API', type: :request do
  let!(:admin) { create(:user, :admin) }
  let!(:member) { create(:user, :member) }
  let!(:lead1) { create(:lead, status: :new_lead, assigned_to: member) }
  let!(:lead2) { create(:lead, status: :contacted, assigned_to: member) }
  let!(:lead3) { create(:lead, status: :won, assigned_to: member) }
  let!(:lead4) { create(:lead, status: :lost) }
  let(:admin_token) { JwtService.encode(user_id: admin.id) }
  let(:member_token) { JwtService.encode(user_id: member.id) }

  describe 'GET /api/dashboard' do
    it 'returns dashboard stats for admin' do
      get '/api/dashboard', headers: { 'Authorization' => "Bearer #{admin_token}" }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['total_leads']).to eq(4)
      expect(json['new_leads']).to eq(1)
      expect(json['contacted']).to eq(1)
      expect(json['won']).to eq(1)
      expect(json['lost']).to eq(1)
    end

    it 'returns filtered stats for member (only assigned leads)' do
      get '/api/dashboard', headers: { 'Authorization' => "Bearer #{member_token}" }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['total_leads']).to eq(3)
    end

    it 'returns 401 without authentication' do
      get '/api/dashboard'

      expect(response).to have_http_status(:unauthorized)
    end
  end
end
