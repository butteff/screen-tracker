require 'rainbow'
require_relative './database.rb'
include Database

module Iostream    
    @@sqlt = Sqlt.new
    @@COLOR_HEADER = 'sienna'
    @@COLOR_KEY = 'red'
    @@SPACERS = 30
    @@KEY_SPACERS = 20
    
    def io_set_one(tbl, key, value)
        sql = 'select * from '+tbl
        res = @@sqlt.read(sql)
        hash_data= res[0]
        hash_data[key] = value
        @@sqlt.write(tbl, hash_data, true)
    end

    def io_get(tbl, and_print=true)
        sql = 'select * from '+tbl
        res = @@sqlt.read(sql)
        send('print_'+tbl, res) if and_print
    end

    def print_settings(res)
        res = res.first
        
        text = Rainbow("Logs Push URL: ").send(@@COLOR_HEADER).ljust(@@SPACERS)
        text += Rainbow("[url] ").send(@@COLOR_KEY).ljust(@@KEY_SPACERS)
        text += res['url'].to_s
        text += "\n"

        text += Rainbow("Screenshots: ").send(@@COLOR_HEADER).ljust(@@SPACERS)
        text += Rainbow("[is_shot] ").send(@@COLOR_KEY).ljust(@@KEY_SPACERS)
        text += enabled = res['is_shot'] == 1 ? 'enabled' : 'disabled'
        text += "\n"

        text += Rainbow("Interval: ").send(@@COLOR_HEADER).ljust(@@SPACERS)
        text += Rainbow("[interval] ").send(@@COLOR_KEY).ljust(@@KEY_SPACERS) if res['is_shot'] == 1
        text += res['interval'].to_s+' mins between screenshots' if res['is_shot'] == 1
        
        text += "\n\n"
        text += "Use \"track settings {key} {value}\" to change these params, for example:" 
        text += "\n\"track settings is_shot 0\" or \"track settings interval 10\""

        puts text
    end
end    