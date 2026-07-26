class AllowNullUserInActivities < ActiveRecord::Migration[8.1]
  def change
    change_column_null :activities, :user_id, true
  end
end
