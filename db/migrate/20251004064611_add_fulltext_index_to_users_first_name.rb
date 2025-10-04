class AddFulltextIndexToUsersFirstName < ActiveRecord::Migration[8.0]
  def change
    # Remove existing B-tree index
    remove_index :users, :first_name

    # Add FULLTEXT index
    execute "CREATE FULLTEXT INDEX index_users_on_first_name_fulltext ON users(first_name)"
  end
end
