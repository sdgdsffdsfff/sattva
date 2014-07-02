require 'highline/import'
require_relative 'lib/store'

PID = "#{File.dirname __FILE__}/tmp/.pid"

namespace :user do
  desc 'add user'
  task :add do
    username = ask('User name?  ') { |q| q.validate = /\w{3,8}/ }.to_s
    password = ask('Password? ') do |q|
      q.validate = /.{6,20}/
      q.echo = 'x'
    end
    re_password = ask('Re input password ') { |q| q.echo = 'x' }.to_s

    store = Sattva::Store.instance
    unless re_password == password
      puts 'Password not match!'
      next
    end
    ok = ask('Are you sure? (y/n)') { |q| q.default='n' }
    if ok == 'y'
      if store.get_user(username)
        puts "User name #{username} exist!"
        next
      end
      store.add_user username, password
      store.add_log "Add user #{username}"
      puts "Add user #{username} success!"
    end
  end

  desc 'remove user'
  task :del do
    username = ask('User name?  ') { |q| q.validate = /\w{3,8}/ }.to_s
    store = Sattva::Store.instance
    user = store.get_user(username)
    ok = ask('Are you sure? (y/n)') { |q| q.default='n' }
    if ok == 'y'
      if user
        store.del_user user[:id]
        store.add_log "Remove user #{username}"
        puts "Remove user #{username} success!"
      else
        puts "User #{username} not exist!"
      end
    end
  end

  desc 'list users'
  task :list do
    Sattva::Store.instance.list_user.each { |u| puts u[:name] }
  end

end

desc 'List logs'
task :logs, [:size] do |_, args|
  args.with_defaults size: 20
  Sattva::Store.instance.list_log(args[:size]).each { |l| puts "#{l[:created]}: #{l[:message]}" }
end

namespace :web do
  desc 'setup web'
  task :setup do
    r_host = ask('Redis host?(localhost)  ') { |q| q.default='localhost' }.to_s
    r_port = ask('Redis port?(6379)', Integer) do |q|
      q.default=6379
      q.in = 1..65535
    end
    r_db = ask('Redis db?(0)', Integer) do |q|
      q.default=0
      q.in = 0..16
    end

    h_port = ask('Http port?(8080)', Integer) do |q|
      q.default = 8080
      q.in = 1..65535
    end
    ok = ask('Are you sure? (y/n)') { |q| q.default='n' }
    if ok == 'y'
      store = Sattva::Store.instance
      store.set 'redis', {host: r_host, port: r_port, db: r_db}
      store.set 'http', {port: h_port, host: 'localhost'}
      store.set 'init', {stamp: Time.now}
      store.add_log 'web setup'
      puts 'Set web success!'
    end
  end

  desc 'show web setting'
  task :info do
    store = Sattva::Store.instance
    if store.init?
      puts "REDIS: #{store.get('redis')}"
      puts "HTTP URL: http://localhost:#{store.get('http')['port']}"
    end
  end

  desc 'start web server'
  task :start do

    if File.exist?(PID)
      puts "Already started? Or you need to delete file #{PID}"
    else
      store = Sattva::Store.instance
      if store.init?
        `puma -p #{store.get('http')['port']} --pidfile #{PID} -e production -d config.ru`
        store.add_log 'Start!'
        puts 'Start success!'
      else
        puts "Haven't setup!"
      end
    end
  end

  desc 'stop web server'
  task :stop do
    if File.exist?(PID)
      `kill $(cat #{PID})`
      Sattva::Store.instance.add_log 'Stop'
      puts 'Stop success!'
    else
      puts 'Not started!'
    end
  end

  desc 'restart web server' 
  task :restart do
	  if File.exist?(PID)
		  `kill -s SIGUSR2 $(cat #{PID})` 
      	  Sattva::Store.instance.add_log 'Restart'
		  puts 'Restart!'
	  else
		  puts "Haven't start!"
	  end
  end

  desc 'web server status'
  task :status do
    puts File.exist?(PID) ? 'START' : 'STOP'
  end
  
  desc 'nginx config file'
  task :nginx,[:domain] do |_, args|
    args.with_defaults domain:'localhost'
    domain = args[:domain]
    store = Sattva::Store.instance
    unless store.init?
      puts "Haven't setup!"
      next
    end
    port = store.get('http')['port']
    puts <<NGINX
upstream #{domain}_app {
  server http://localhost:#{port} fail_timeout=0;
}

server {
  listen 443;
  server_name #{domain};

  ssl  on;
  ssl_certificate  ssl/#{domain}-cert.pem;
  ssl_certificate_key  ssl/#{domain}-key.pem;
  ssl_session_timeout  5m;
  ssl_protocols  SSLv2 SSLv3 TLSv1;
  ssl_ciphers  RC4:HIGH:!aNULL:!MD5;
  ssl_prefer_server_ciphers  on;

  root /var/www/#{domain}/current/public;
  try_files $uri/index.html $uri @#{domain}_app;


  location @#{domain}_app {
    proxy_set_header  Host $http_host;
    proxy_set_header  X-Real-IP $remote_addr;
    proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header  X-Forwarded-Proto https;
    proxy_redirect  off;
    proxy_pass http://#{domain}_app;
  }
}
NGINX
    
  end
end


