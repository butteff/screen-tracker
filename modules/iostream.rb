require 'rainbow'
require 'is_valid'
require_relative './database.rb'
include Database

module Iostream    
    @@sqlt = Sqlt.new
    @@valid = IsValid.new({
        settings: {
            url: 'url',
            is_shot: 'boolean',
            interval: 'integer',
        }
    })
    @@COLOR_HEADER = 'coral'
    @@COLOR_KEY = 'plum'
    @@COLOR_ERROR = 'crimson'
    @@SPACERS = 30
    @@KEY_SPACERS = 20
    
    def io_set_one(tbl, key, value)
        sql = 'select * from '+tbl
        res = @@sqlt.read(sql)
        hash_data= res[0]
        hash_data[key] = value
        
        validation = @@valid.check_hash(hash_data, 'settings')
        if validation == true
            @@sqlt.write(tbl, hash_data, true) 
        else
            print_errors(validation)
        end
    end

    def io_get(tbl, and_print=true)
        sql = 'select * from '+tbl
        res = @@sqlt.read(sql)
        send('print_'+tbl, res) if and_print
    end

    def print_settings(res)
        res = res.first
        
        text = Rainbow("  Logs Push URL: ").send(@@COLOR_HEADER).ljust(@@SPACERS)
        text += Rainbow("[url] ").send(@@COLOR_KEY).ljust(@@KEY_SPACERS)
        text += res['url'].to_s
        text += "\n"

        text += Rainbow("  Screenshots: ").send(@@COLOR_HEADER).ljust(@@SPACERS)
        text += Rainbow("[is_shot] ").send(@@COLOR_KEY).ljust(@@KEY_SPACERS)
        text += enabled = res['is_shot'] == 1 ? 'enabled' : 'disabled'
        text += "\n"

        if res['is_shot'] == 1
        text += Rainbow("  Interval: ").send(@@COLOR_HEADER).ljust(@@SPACERS) 
        text += Rainbow("[interval] ").send(@@COLOR_KEY).ljust(@@KEY_SPACERS)
        text += res['interval'].to_s+' mins between screenshots'
        end
        
        text += "\n\n"
        text += "  Use \"track settings {key} {value}\" to change these params, for example:\n" 
        text += "  \"track settings is_shot 0\" or \"track settings interval 10\""
        text += "\n\n"
        puts text
    end

    def print_errors(errors)
        text ="\n"
        text += Rainbow("  Your forwarded data are not valid:").send(@@COLOR_ERROR)
        text +="\n\n"
        errors.each do |err|
            text += Rainbow('    * '+err).send(@@COLOR_ERROR)+"\n"
        end
        text +="\n\n"
        puts text
    end
end    