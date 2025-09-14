class UserSearchSerializer
  def initialize(user)
    @user = user
  end

  def as_json
    {
      model: "User",
      title: @user.name,
      text: @user.email,
      path: "#",
      created_at: @user.created_at
    }
  end
end
