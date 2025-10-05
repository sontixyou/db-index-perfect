class AddIndexToUserProfilesCareer < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def up
    execute <<-SQL
      ALTER TABLE user_profiles
      ADD FULLTEXT INDEX index_user_profiles_on_career (career),
      ALGORITHM=INPLACE, LOCK=SHARED
    SQL
  end

  def down
    remove_index :user_profiles, :career
  end
end
