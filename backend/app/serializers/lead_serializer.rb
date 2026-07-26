class LeadSerializer
  def initialize(lead)
    @lead = lead
  end

  def as_json(options = {})
    {
      id: @lead.id,
      name: @lead.name,
      email: @lead.email,
      phone: @lead.phone,
      company: @lead.company,
      message: @lead.message,
      status: @lead.status,
      status_label: @lead.status&.humanize,
      assigned_to: assigned_user,
      created_at: @lead.created_at,
      updated_at: @lead.updated_at,
      notes_count: @lead.notes.count,
      activities_count: @lead.activities.count
    }
  end

  private

  def assigned_user
    return nil unless @lead.assigned_to

    {
      id: @lead.assigned_to.id,
      name: @lead.assigned_to.name,
      email: @lead.assigned_to.email
    }
  end
end

class LeadsSerializer
  def initialize(leads, meta = {})
    @leads = leads
    @meta = meta
  end

  def as_json(options = {})
    {
      data: @leads.map { |lead| LeadSerializer.new(lead).as_json },
      meta: @meta
    }
  end
end

