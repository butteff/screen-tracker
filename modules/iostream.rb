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
        where = false
        if key == 'task_id'
            status = io_get_raw('status')&.first
            where = "client_id = #{status['client_id']}"
        end
        has_reference = @@sqlt.check_exist(key.gsub('_id', '')+'s', value, where) if key.end_with?('_id')
        has_reference = @@sqlt.check_key(tbl, key) if tbl == 'settings'
        if has_reference
            sql = "select * from #{tbl}"
            res = @@sqlt.read(sql)
            hash_data= res[0] if res
            hash_data[key] = value
            validation = @@valid.check_hash(hash_data, tbl)
            if validation == true
                hash_data['task_id'] = nil if key == 'client_id'
                @@sqlt.write(tbl, hash_data, true) 
            else
                print_errors(validation)
            end
        else
            tbl != 'settings' ? send('print_no_'+key.gsub('_id', '')+'s_exception') : print_wrong_key(key)
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

    def io_print(view)
        send('print_'+view)
    end
end    