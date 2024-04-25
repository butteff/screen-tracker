require 'is_valid'
require_relative './database.rb'
require_relative './views.rb'
include Database
include Views

module Iostream    
    @@sqlt = Sqlt.new
    @@valid = IsValid.new({
        settings: {
            url: 'url',
            is_shot: 'boolean',
            interval: 'integer',
        },
        status: {
            client_id: 'integer',
            task_id: 'integer*',
            started_at: 'nil',
            finished_at: 'nil',
        }
    })
    
    def io_set_one(tbl, key, value)
        sql = "select * from #{tbl}"
        res = @@sqlt.read(sql)
        hash_data= res[0]
        hash_data[key] = value
        validation = @@valid.check_hash(hash_data, tbl)
        if validation == true
            hash_data['task_id'] = nil if key == 'client_id'
            @@sqlt.write(tbl, hash_data, true) 
        else
            print_errors(validation)
        end
    end

    def io_get_raw(tbl, where=false)
        sql = "select * from #{tbl}"
        sql += " where #{where}" if where
        @@sqlt.read(sql)
    end

    def io_get(tbl, where=false)
        res = io_get_raw(tbl, where)
        send('print_'+tbl, res)
    end
end    