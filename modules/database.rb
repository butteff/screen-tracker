require "sqlite3"
#require 'singleton'

module Database
    class Sqlt
        #include Singleton 

        def initialize
            @db = db_init
            query('create table if not exists settings (url varchar(64), is_shot boolean, interval int);')
            setup = read('select * from settings')
            query("INSERT INTO settings (url, is_shot, interval) VALUES (?, ?, ?)", ["https://track.butteff.ru", 1, 5]) if setup.empty?
        end

        def query(sql, data = nil)
            @db.execute(sql, data)
        end

        def read(sql)
            res = []
            @db.execute(sql) do |row|
              res << row
            end
            res
        end

        private

        def db_init
            SQLite3::Database.new "track.db"
        end

    end
end    