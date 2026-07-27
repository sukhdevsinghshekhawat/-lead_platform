require 'rails_helper'

RSpec.describe 'Leads API', type: :request do
  let!(:admin) { create(:user, :admin) }
  let!(:member) { create(:user, :member) }
  let!(:lead) { create(:lead, assigned_to: member) }
  let(:admin_token) { JwtService.encode(user_id: admin.id) }
  let(:member_token) { JwtService.encode(user_id: member.id) }

  describe 'GET /api/leads' do
    it 'returns paginated leads for admin' do
      get '/api/leads', headers: { 'Authorization' => "Bearer #{admin_token}" }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']).to be_an(Array)
      expect(json['meta']).to be_present
    end

    it 'returns only assigned leads for member' do
      get '/api/leads', headers: { 'Authorization' => "Bearer #{member_token}" }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data'].length).to eq(1)
      expect(json['data'].first['id']).to eq(lead.id)
    end

    it 'supports search' do
      get "/api/leads?search=#{lead.name}", headers: { 'Authorization' => "Bearer #{admin_token}" }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data'].length).to eq(1)
    end

    it 'supports status filter' do
      get '/api/leads?status=new_lead', headers: { 'Authorization' => "Bearer #{admin_token}" }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data'].length).to eq(1)
    end
  end

  describe 'GET /api/leads/:id' do
    it 'returns lead details for admin' do
      get "/api/leads/#{lead.id}", headers: { 'Authorization' => "Bearer #{admin_token}" }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['lead']['id']).to eq(lead.id)
      expect(json['notes']).to be_an(Array)
      expect(json['activities']).to be_an(Array)
    end

    it 'returns lead details for assigned member' do
      get "/api/leads/#{lead.id}", headers: { 'Authorization' => "Bearer #{member_token}" }

      expect(response).to have_http_status(:ok)
    end

    it 'returns 404 for non-existent lead' do
      get '/api/leads/99999', headers: { 'Authorization' => "Bearer #{admin_token}" }

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'POST /api/leads' do
    it 'creates a lead without authentication (public)' do
      expect {
        post '/api/leads', params: { name: 'Test', email: 'test@example.com', phone: '123', company: 'TestCo', message: 'Hello' }
      }.to change(Lead, :count).by(1)

      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json['data']['name']).to eq('Test')
    end

    it 'returns 422 with invalid data' do
      post '/api/leads', params: { name: '', email: '' }

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'PATCH /api/leads/:id' do
    it 'updates lead as admin' do
      patch "/api/leads/#{lead.id}", params: { name: 'Updated Name' }, headers: { 'Authorization' => "Bearer #{admin_token}" }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['name']).to eq('Updated Name')
    end

    it 'updates lead as assigned member' do
      patch "/api/leads/#{lead.id}", params: { name: 'Updated by Member' }, headers: { 'Authorization' => "Bearer #{member_token}" }

      expect(response).to have_http_status(:ok)
    end
  end

  describe 'DELETE /api/leads/:id' do
    it 'deletes lead as admin' do
      delete "/api/leads/#{lead.id}", headers: { 'Authorization' => "Bearer #{admin_token}" }

      expect(response).to have_http_status(:no_content)
    end

    it 'returns 403 for member' do
      delete "/api/leads/#{lead.id}", headers: { 'Authorization' => "Bearer #{member_token}" }

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe 'PATCH /api/leads/:id/status' do
    it 'updates status as admin' do
      patch "/api/leads/#{lead.id}/update_status", params: { status: 'contacted' }, headers: { 'Authorization' => "Bearer #{admin_token}" }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['data']['status']).to eq('contacted')
    end

    it 'updates status as assigned member' do
      patch "/api/leads/#{lead.id}/update_status", params: { status: 'qualified' }, headers: { 'Authorization' => "Bearer #{member_token}" }

      expect(response).to have_http_status(:ok)
    end
  end

  describe 'PATCH /api/leads/:id/assign' do
    it 'assigns lead as admin' do
      patch "/api/leads/#{lead.id}/assign", params: { assigned_to_id: member.id }, headers: { 'Authorization' => "Bearer #{admin_token}" }

      expect(response).to have_http_status(:ok)
    end

    it 'returns 403 for member' do
      patch "/api/leads/#{lead.id}/assign", params: { assigned_to_id: admin.id }, headers: { 'Authorization' => "Bearer #{member_token}" }

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe 'POST /api/leads/:id/add_note' do
    it 'adds note as admin' do
      expect {
        post "/api/leads/#{lead.id}/add_note", params: { message: 'Test note' }, headers: { 'Authorization' => "Bearer #{admin_token}" }
      }.to change(Note, :count).by(1)

      expect(response).to have_http_status(:created)
    end

    it 'adds note as assigned member' do
      expect {
        post "/api/leads/#{lead.id}/add_note", params: { message: 'Member note' }, headers: { 'Authorization' => "Bearer #{member_token}" }
      }.to change(Note, :count).by(1)

      expect(response).to have_http_status(:created)
    end
  end
end
