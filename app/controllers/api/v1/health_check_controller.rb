class Api::V1::HealthCheckController < ApplicationController
  def index
    render json: {
      status: 'OK',
      message: 'API is running',
      database: database_status,
      elasticsearch: elasticsearch_status,
      timestamp: Time.current.iso8601
    }
  end

  private

  def database_status
    ActiveRecord::Base.connection.execute('SELECT 1')
    'Connected'
  rescue StandardError
    'Disconnected'
  end

  def elasticsearch_status
    Searchkick.client.cluster.health
    'Connected'
  rescue StandardError => e
    "Disconnected: #{e.message}"
  end
end