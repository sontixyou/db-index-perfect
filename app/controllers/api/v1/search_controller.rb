class Api::V1::SearchController < ApplicationController
  # GET /api/v1/search/users?q=query
  def users
    query = params[:q] || "*"

    results = User.search(
      query,
      fields: [:first_name, :last_name, :email],
      match: :word_start,
      page: params[:page] || 1,
      per_page: params[:per_page] || 11
    )

    render json: {
      results: results,
      total: results.total_count,
      page: results.current_page,
      per_page: results.limit_value,
      total_pages: results.total_pages
    }
  rescue => e
    render json: { error: e.message }, status: :internal_server_error
  end

  # GET /api/v1/search/user_profiles?q=query
  def user_profiles
    query = params[:q] || "*"

    results = UserProfile.search(
      query,
      fields: [:career],
      match: :word_start,
      page: params[:page] || 1,
      per_page: params[:per_page] || 20
    )

    render json: {
      results: results,
      total: results.total_count,
      page: results.current_page,
      per_page: results.limit_value,
      total_pages: results.total_pages
    }
  rescue => e
    render json: { error: e.message }, status: :internal_server_error
  end

  # GET /api/v1/search/user_profiles_mysql?q=query
  def user_profiles_mysql
    query = params[:q]
    page = (params[:page] || 1).to_i
    per_page = (params[:per_page] || 20).to_i

    if query.blank?
      results = []
      total_count = 0
    else
      results = UserProfile.search_by_fulltext(query, page: page, per_page: per_page)
      total_count = UserProfile.where("MATCH(career) AGAINST(? IN NATURAL LANGUAGE MODE)", query).count
    end

    render json: {
      results: results,
      total: total_count,
      page: page,
      per_page: per_page,
      total_pages: (total_count.to_f / per_page).ceil
    }
  rescue => e
    render json: { error: e.message }, status: :internal_server_error
  end

  # GET /api/v1/search/user_profiles_like?q=query
  def user_profiles_like
    query = params[:q]
    page = (params[:page] || 1).to_i
    per_page = (params[:per_page] || 20).to_i

    if query.blank?
      results = []
      total_count = 0
    else
      results = UserProfile.search_by_like(query, page: page, per_page: per_page)
      total_count = UserProfile.where("career LIKE ?", "%#{query}%").count
    end

    render json: {
      results: results,
      total: total_count,
      page: page,
      per_page: per_page,
      total_pages: (total_count.to_f / per_page).ceil
    }
  rescue => e
    render json: { error: e.message }, status: :internal_server_error
  end

  # GET /api/v1/search/benchmark?q=query&iterations=10
  def benchmark
    query = params[:q] || "Ruby"
    per_page = (params[:per_page] || 20).to_i
    iterations = (params[:iterations] || 5).to_i

    results = {}

    # Benchmark Elasticsearch
    es_times = []
    iterations.times do
      start_time = Time.current
      UserProfile.search(query, fields: [:career], match: :word_start, per_page: per_page).to_a
      es_times << (Time.current - start_time) * 1000
    end
    results[:elasticsearch] = {
      avg_time_ms: (es_times.sum / es_times.size).round(2),
      min_time_ms: es_times.min.round(2),
      max_time_ms: es_times.max.round(2),
      times: es_times.map { |t| t.round(2) }
    }

    # Benchmark MySQL FULLTEXT
    fulltext_times = []
    iterations.times do
      start_time = Time.current
      UserProfile.search_by_fulltext(query, per_page: per_page).to_a
      fulltext_times << (Time.current - start_time) * 1000
    end
    results[:mysql_fulltext] = {
      avg_time_ms: (fulltext_times.sum / fulltext_times.size).round(2),
      min_time_ms: fulltext_times.min.round(2),
      max_time_ms: fulltext_times.max.round(2),
      times: fulltext_times.map { |t| t.round(2) }
    }

    # Benchmark MySQL LIKE
    like_times = []
    iterations.times do
      start_time = Time.current
      UserProfile.search_by_like(query, per_page: per_page).to_a
      like_times << (Time.current - start_time) * 1000
    end
    results[:mysql_like] = {
      avg_time_ms: (like_times.sum / like_times.size).round(2),
      min_time_ms: like_times.min.round(2),
      max_time_ms: like_times.max.round(2),
      times: like_times.map { |t| t.round(2) }
    }

    render json: {
      query: query,
      per_page: per_page,
      iterations: iterations,
      results: results,
      comparison: {
        es_vs_fulltext_ratio: (results[:mysql_fulltext][:avg_time_ms] / results[:elasticsearch][:avg_time_ms]).round(2),
        es_vs_like_ratio: (results[:mysql_like][:avg_time_ms] / results[:elasticsearch][:avg_time_ms]).round(2),
        fulltext_vs_like_ratio: (results[:mysql_like][:avg_time_ms] / results[:mysql_fulltext][:avg_time_ms]).round(2)
      }
    }
  rescue => e
    render json: { error: e.message, backtrace: e.backtrace.first(5) }, status: :internal_server_error
  end
end
