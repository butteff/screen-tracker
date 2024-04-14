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
                settings = {url: "https://track.butteff.ru", is_shot: 1, interval: 55}        
                write('settings', settings)
            end
        end

        def read(sql)
            res = []
            @db.execute(sql) do |row|
              res << row
            end
            res
        end

        def write(tbl, hash_data, cleanup=false)
            questions = '?'
            looop = hash_data.length-1
            looop.times{questions.prepend('?, ')}
            values = hash_data.keys.map{|a| a.to_s}.to_s[1..-2].sub(':', '').gsub('"', '')

            qry = "INSERT INTO"
            qry+= ' '+tbl
            qry+= ' ('+values+') '
            qry+= 'VALUES ('+questions+')'

            array = []
            keys = hash_data.keys
            keys.each do |key|
                array += [hash_data[key]]
            end
            query('DELETE FROM '+tbl+' WHERE 1') if cleanup
            query(qry, array)
        end

        private

        def query(sql, data = nil)
            @db.execute(sql, data)
        end
        
        def db_init
            SQLite3::Database.new "track.db"
        end

    end
end    