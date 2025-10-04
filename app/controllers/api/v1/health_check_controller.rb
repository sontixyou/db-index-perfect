class Api::V1::HealthCheckController < ApplicationController
  def index
    render json: {
      status: 'OK',
      message: 'API is running',
      database: database_status,
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
end