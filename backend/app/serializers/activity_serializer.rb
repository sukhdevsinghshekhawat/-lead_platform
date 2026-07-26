class ActivitySerializer
  def initialize(activity)
    @activity = activity
  end

  def as_json(options = {})
    {
      id: @activity.id,
      action: @activity.action,
      action_label: @activity.action&.humanize,
      details: @activity.details,
      user: @activity.user ? {
        id: @activity.user.id,
        name: @activity.user.name,
        email: @activity.user.email
      } : nil,
      created_at: @activity.created_at
    }
  end
end

class ActivitiesSerializer
  def initialize(activities)
    @activities = activities
  end

  def as_json(options = {})
    @activities.map { |activity| ActivitySerializer.new(activity).as_json }
  end
end

