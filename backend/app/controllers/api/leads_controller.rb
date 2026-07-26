module Api
  class LeadsController < ApplicationController
    before_action :authenticate_request, except: [:create]
    before_action :set_lead, only: [:show, :update, :destroy, :update_status, :assign, :add_note]

    def index
      leads = policy_scope(Lead)
      leads = leads.search(params[:search])
      leads = leads.by_status(params[:status])
      leads = leads.by_assigned_user(params[:assigned_to_id])
      leads = leads.newest_first

      paginated = leads.page(params[:page] || 1).per(params[:per_page] || 10)

      render json: {
        data: paginated.map { |lead| LeadSerializer.new(lead).as_json },
        meta: {
          current_page: paginated.current_page,
          total_pages: paginated.total_pages,
          total_count: paginated.total_count,
          per_page: paginated.limit_value
        }
      }, status: :ok
    end

    def show
      authorize @lead
      render json: {
        lead: LeadSerializer.new(@lead).as_json,
        notes: @lead.notes.newest_first.includes(:user).map { |note| NoteSerializer.new(note).as_json },
        activities: @lead.activities.newest_first.includes(:user).map { |activity| ActivitySerializer.new(activity).as_json }
      }, status: :ok
    end

    def create
      @lead = Lead.new(lead_params)
      @lead.status = :new_lead

      if @lead.save
        ActivityService.lead_created(@lead, nil)
        render json: { data: LeadSerializer.new(@lead).as_json }, status: :created
      else
        render json: { errors: @lead.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def update
      authorize @lead

      if @lead.update(lead_params)
        render json: { data: LeadSerializer.new(@lead).as_json }, status: :ok
      else
        render json: { errors: @lead.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @lead
      @lead.destroy
      head :no_content
    end

    def update_status
      authorize @lead, :update_status?

      old_status = @lead.status
      new_status = params[:status]

      if @lead.update(status: new_status)
        ActivityService.status_changed(@lead, current_user, old_status, new_status)
        render json: { data: LeadSerializer.new(@lead).as_json }, status: :ok
      else
        render json: { errors: @lead.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def assign
      authorize @lead, :assign?

      assigned_user = User.find_by(id: params[:assigned_to_id])

      if assigned_user.nil?
        return render json: { error: "User not found" }, status: :not_found
      end

      @lead.update!(assigned_to: assigned_user)
      ActivityService.lead_assigned(@lead, current_user, assigned_user)

      render json: { data: LeadSerializer.new(@lead).as_json }, status: :ok
    end

    def add_note
      authorize @lead, :add_note?

      note = @lead.notes.build(
        message: params[:message],
        user: current_user
      )

      if note.save
        ActivityService.note_added(@lead, current_user)
        render json: { data: NoteSerializer.new(note).as_json }, status: :created
      else
        render json: { errors: note.errors.full_messages }, status: :unprocessable_entity
      end
    end

    private

    def set_lead
      @lead = Lead.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { error: "Lead not found" }, status: :not_found
    end

    def lead_params
      params.permit(:name, :email, :phone, :company, :message, :status)
    end
  end
end
