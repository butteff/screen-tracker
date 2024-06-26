# frozen_string_literal: false

require 'sqlite3'
# require 'singleton'

module Database
  class Sqlt
    # include Singleton

    def initialize
      @db = db_init
      @db.results_as_hash = true
      # create tables:
      query('create table if not exists settings (
                url varchar(64),
                is_shot boolean,
                interval int
            );')
      query('create table if not exists clients (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name varchar(64)
            );')
      query('create table if not exists tasks (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                client_id int,
                title varchar(128),
                FOREIGN KEY(client_id) REFERENCES clients(id)
            );')
      query('create table if not exists status (
                client_id int,
                task_id int,
                started_at datetime,
                finished_at datetime,
                FOREIGN KEY(client_id) REFERENCES clients(id)
                FOREIGN KEY(task_id) REFERENCES tasks(id)
            );')
      query('create table if not exists logs (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                client_id int,
                task_id int,
                user_id int,
                timestamp int,
                screenshot varchar(256),
                FOREIGN KEY(client_id) REFERENCES clients(id)
                FOREIGN KEY(task_id) REFERENCES tasks(id)
            );')
      # ============

      # add default settings:
      setup = read('select * from settings')
      if setup.empty?
        settings = { url: 'https://track.butteff.ru', is_shot: 1, interval: 5 }
        write('settings', settings)
      end
      # ============

      # add default status:
      status = read('select * from status')
      if status.empty?
        status = { client_id: nil, task_id: nil, started_at: nil, finished_at: nil }
        write('status', status)
      end
      # ============

      # fetch clients:
      clients = read('select * from clients')
      if clients.empty? # to do some API to fetch
        fetched_clients = [
          { id: 1, name: 'Google' },
          { id: 2, name: 'Yandex' },
          { id: 3, name: 'NoName Company' }
        ]
        fetched_clients.each do |client_hash|
          write('clients', client_hash)
        end
      end
      #-------------

      # fetch tasks:
      tasks = read('select * from tasks')
      return unless tasks.empty?

      fetched_tasks = [
        { id: 1, client_id: 1, title: 'upload some code to github' },
        { id: 2, client_id: 2, title: 'update something' },
        { id: 3, client_id: 2, title: 'write some documentation' }
      ]
      fetched_tasks.each do |task_hash|
        write('tasks', task_hash)
      end
      #-------------
    end

    def read(sql)
      res = []
      @db.execute(sql) do |row|
        res << row
      end
      res
    end

    def write(tbl, hash_data, cleanup = false)
      return unless empty_or_unique_check(tbl, hash_data)

      questions = '?'
      looop = hash_data.length - 1
      looop.times { questions.prepend('?, ') }
      values = hash_data.keys.map(&:to_s).to_s[1..-2].sub(':', '').gsub('"', '')

      qry = "INSERT INTO #{tbl} (#{values}) VALUES (#{questions})"

      array = []
      keys = hash_data.keys
      keys.each do |key|
        array += [hash_data[key]]
      end
      query("DELETE FROM #{tbl} WHERE 1") if cleanup
      query(qry, array)
    end

    def remove_by_id(tbl, id)
      query("DELETE FROM #{tbl} WHERE id = #{id}")
    end

    def check_exist(type, value, where = false)
      sql = "select * from #{type}"
      sql += " where #{where}" if where
      values = read(sql)
      values&.map { |ex| value.to_i == ex['id'] }&.include?(true)
    end

    def check_key(tbl, key)
      begin
        res = true
        sql = "select #{key} from #{tbl}"
        read(sql)
      rescue StandardError
        res = false
      end
      res
    end

    private

    def filter(val)
      val.instance_of?(String) ? val.delete('"\'`') : val
    end

    def empty_or_unique_check(tbl, hash_data)
      check = read("select * from #{tbl} where id = '#{hash_data[:id]}'") if hash_data&.key?(:id)
      check.nil? || check.empty? ? true : false
    end

    def query(sql, data = [])
      data.map! { |a| filter(a) }
      sql = filter(sql)
      @db.execute(sql, data)
    end

    def db_init
      SQLite3::Database.new 'track.db'
    end
  end
end
