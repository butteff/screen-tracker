require "sqlite3"
#require 'singleton'

module Database
    class Sqlt
        #include Singleton

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
            # ============ 
            
            # add default settings:
            setup = read('select * from settings')
            if setup.empty?
                settings = {url: "https://track.butteff.ru", is_shot: 1, interval: 5}
                write('settings', settings)
            end
            # ============

            # add default status:
            status = read('select * from status')
            if status.empty?
                status = {client_id: nil, task_id: nil, started_at: nil, finished_at: nil}
                write('status', status)
            end
            # ============

            # fetch clients:
            fetched_clients = [{id: 1, name: 'Google'}, {id: 2, name: 'Yandex'}] #to do some API to fetch
            fetched_clients.each do |client_hash|
                write('clients', client_hash)
            end
            #-------------

            # fetch tasks:
            fetched_tasks = [
                {id: 1, client_id: 1, title: 'upload some code to github'}, 
                {id: 2, client_id: 2, title: 'update something'}, 
                {id: 3, client_id: 2, title: 'write some documentation'}
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

        def write(tbl, hash_data, cleanup=false)
            if empty_or_unique_check(tbl, hash_data)
                questions = '?'
                looop = hash_data.length-1
                looop.times{questions.prepend('?, ')}
                values = hash_data.keys.map{|a| a.to_s}.to_s[1..-2].sub(':', '').gsub('"', '')

                qry = "INSERT INTO #{tbl} (#{values}) VALUES (#{questions})"

                array = []
                keys = hash_data.keys
                keys.each do |key|
                    array += [hash_data[key]]
                end
                query("DELETE FROM #{tbl} WHERE 1") if cleanup
                query(qry, array)
            end
        end

        private

        def empty_or_unique_check(tbl, hash_data)
            check = read("select * from #{tbl} where id = '#{hash_data[:id]}'") if hash_data.key?(:id)
            check = check.nil? || check.empty? ? true : false
        end

        def query(sql, data = [])
            @db.execute(sql, data)
        end
        
        def db_init
            SQLite3::Database.new "track.db"
        end

    end
end    