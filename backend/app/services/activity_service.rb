class ActivityService
  def self.track(lead:, user: nil, action:, details: nil)
    Activity.create!(
      lead: lead,
      user: user,
      action: action,
      details: details
    )
  end

  def self.lead_created(lead, user = nil)
    track(lead: lead, user: user, action: "lead_created", details: "Lead was created")
  end

  def self.lead_assigned(lead, user, assigned_user)
    track(
      lead: lead,
      user: user,
      action: "lead_assigned",
      details: "Lead assigned to #{assigned_user.name}"
    )
  end

  def self.status_changed(lead, user, old_status, new_status)
    track(
      lead: lead,
      user: user,
      action: "status_changed",
      details: "Status changed from #{old_status} to #{new_status}"
    )
  end

  def self.note_added(lead, user)
    track(
      lead: lead,
      user: user,
      action: "note_added",
      details: "Note added by #{user.name}"
    )
  end
end

