module Api
  class DashboardController < ApplicationController
    before_action :authenticate_request

    def index
      leads = policy_scope(Lead)

      render json: {
        total_leads: leads.count,
        new_leads: leads.where(status: :new_lead).count,
        contacted: leads.where(status: :contacted).count,
        qualified: leads.where(status: :qualified).count,
        proposal_sent: leads.where(status: :proposal_sent).count,
        won: leads.where(status: :won).count,
        lost: leads.where(status: :lost).count
      }, status: :ok
    end
  end
end
