class RevertToBtreeIndexOnUsersFirstName < ActiveRecord::Migration[8.0]
  def change
    # Remove FULLTEXT index
    execute "DROP INDEX index_users_on_first_name_fulltext ON users"

    # Add back B-tree index
    add_index :users, :first_name
  end
end
