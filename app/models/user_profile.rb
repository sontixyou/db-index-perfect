class UserProfile < ApplicationRecord
  searchkick word_start: [:career], callbacks: false

  belongs_to :user

  def search_data
    {
      career: career,
      user_id: user_id,
      created_at: created_at
    }
  end

  # MySQL FULLTEXT search
  def self.search_by_fulltext(query, page: 1, per_page: 20)
    return none if query.blank?

    offset = (page - 1) * per_page
    where("MATCH(career) AGAINST(? IN NATURAL LANGUAGE MODE)", query)
      .limit(per_page)
      .offset(offset)
  end

  # MySQL LIKE search
  def self.search_by_like(query, page: 1, per_page: 20)
    return none if query.blank?

    offset = (page - 1) * per_page
    where("career LIKE ?", "%#{query}%")
      .limit(per_page)
      .offset(offset)
  end
end
