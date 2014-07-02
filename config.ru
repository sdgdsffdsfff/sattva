require 'sidekiq'
require 'puma/cli'
require 'connection_pool'
require 'redis'
require_relative 'lib/store'

Sidekiq.configure_client do |config|
  config.redis = ConnectionPool.new({size: Puma.cli_config.options[:max_threads], timeout: 1}) { Redis.new Sattva::Store.instance.get('redis').inject({}) { |memo, (k, v)| memo[k.to_sym] = v; memo } }
end

require 'sidekiq/web'
map '/' do
  use Rack::Auth::Basic, 'Protected Area' do |username, password|
    Sattva::Store.instance.auth_user username, password
  end

  run Sidekiq::Web
end
