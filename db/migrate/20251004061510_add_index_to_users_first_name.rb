class AddIndexToUsersFirstName < ActiveRecord::Migration[8.0]
  def change
    add_index :users, :first_name
  end
end
