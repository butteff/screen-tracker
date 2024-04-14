require 'rainbow'
require_relative './database.rb'
include Database

module Iostream    
    @@sqlt = Sqlt.new
    @@COLOR_HEADER = 'sienna'
    @@SPACERS = 30

    def io_print(info)
        sql = 'select * from '+info
        res = @@sqlt.read(sql)
        send('print_'+info, res[0])
    end

    def print_settings(res)
        text = Rainbow("Logs Push URL: ").send(@@COLOR_HEADER).ljust(@@SPACERS)+res['url'].to_s
        text += "\n"+Rainbow("Screenshots: ").send(@@COLOR_HEADER).ljust(@@SPACERS) + enabled = res['is_shot'] == 1 ? 'enabled' : 'disabled'
        text += "\n"+Rainbow("Interval: ").send(@@COLOR_HEADER).ljust(@@SPACERS)+res['interval'].to_s+' mins between screenshots' if res['is_shot'] == 1
        puts text
    end
end    