require "sqlite3"
#require 'singleton'

module Database
    class Sqlt
        #include Singleton 

        def initialize
            @db = db_init
            @db.results_as_hash = true
            query('create table if not exists settings (url varchar(64), is_shot boolean, interval int);')
            setup = read('select * from settings')
            if setup.empty?
                settings_default = {url: "https://track.butteff.ru", is_shot: 1, interval: 5}
                query("INSERT INTO settings (url, is_shot, interval) VALUES (?, ?, ?)", [settings_default[:url], settings_default[:is_shot], settings_default[:interval]] )
            end
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