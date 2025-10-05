class User < ApplicationRecord
  searchkick word_start: [:first_name, :last_name, :email], callbacks: false

  has_one :user_profile, dependent: :destroy

  def search_data
    {
      first_name: first_name,
      last_name: last_name,
      email: email,
      created_at: created_at
    }
  end
end
