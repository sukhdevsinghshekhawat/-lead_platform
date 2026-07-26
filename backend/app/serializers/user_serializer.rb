class UserSerializer
  def initialize(user)
    @user = user
  end

  def as_json(options = {})
    {
      id: @user.id,
      name: @user.name,
      email: @user.email,
      role: @user.role,
      role_label: @user.role&.humanize,
      created_at: @user.created_at
    }
  end
end

class UsersSerializer
  def initialize(users)
    @users = users
  end

  def as_json(options = {})
    @users.map { |user| UserSerializer.new(user).as_json }
  end
end

