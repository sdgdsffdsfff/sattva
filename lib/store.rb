require 'singleton'
require 'sequel'
require 'json'
require 'logger'
require 'digest'

module Sattva
  class Store
    include Singleton

    def initialize(name=nil)
      #@db = Sequel.sqlite(name ? name : "#{File.dirname __FILE__}/../tmp/.db", loggers: [Logger.new($stdout)])
      @db = Sequel.sqlite(name ? name : "#{File.dirname __FILE__}/../tmp/.db")
      @db.create_table? :users do
        primary_key :id
        String :name, unique: true, null: false
        String :password, null: false
        Timestamp :created, null: false
      end
      @db.create_table? :settings do
        primary_key :id
        String :key, unique: true, null: false
        String :val, null: false
        Timestamp :created, null: false
      end
      @db.create_table? :logs do
        primary_key :id
        String :message, null: false
        Timestamp :created, null: false
      end
    end

    def init?
      !get('init').nil?
    end

    def set(key, val)
      val = val.to_json
      if get(key)
        @db[:settings].where(key: key).update(val: val)
      else
        @db[:settings].insert key: key, val: val, created: Time.now
      end
    end

    def get(key)
      s = @db[:settings].first key: key
      JSON.parse(s[:val]) if s
    end

    def add_user(username, password)
      @db[:users].insert name: username, password: password(password), created: Time.now
    end

    def del_user(user_id)
      @db[:users].where(id: user_id).delete
    end

    def get_user(username)
      @db[:users].first name: username
    end

    def auth_user(username, password)
      user = @db[:users].first name: username
      user && user[:password] == password(password)
    end

    def list_user
      @db[:users].select(:name).order(:id)
    end

    def add_log(message)
      @db[:logs].insert message: message, created: Time.now
    end

    def list_log(size)
      @db[:logs].select(:created, :message).limit size
    end

    private
    def password(password)
      Digest::SHA512.hexdigest password
    end
  end
end