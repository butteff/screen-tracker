require 'rainbow'

module Views
    @@COLOR_HEADER = 'coral'
    @@COLOR_KEY = 'plum'
    @@COLOR_ERROR = 'crimson'
    @@COLOR_DANGER = 'red'
    @@COLOR_SUCCESS = 'green'
    @@COLOR_WARNING = 'yellow'
    @@SPACERS = 32
    @@KEY_SPACERS = 24
    @@LOW_SPACERS = 6
    
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

    def print_clients(clients)
        if !clients.empty?
        clients.each do |client|
            text = Rainbow("[id] ").send(@@COLOR_KEY).ljust(@@KEY_SPACERS)
            text += client['id'].to_s.ljust(@@LOW_SPACERS)
            text += Rainbow(" Name: ").send(@@COLOR_HEADER)
            text += client['name'].to_s  
            text += "\n"
            puts text
        end
        else
            print_no_clients_exception
        end
    end

    def print_tasks(tasks)
        if !tasks.empty?
            tasks.each do |task|
                text = Rainbow("[id] ").send(@@COLOR_KEY).ljust(@@KEY_SPACERS)
                text += task['id'].to_s.ljust(@@LOW_SPACERS)
                text += Rainbow(" Title: ").send(@@COLOR_HEADER)
                text += task['title'].to_s         
                text += "\n"
                puts text
            end
        else
            print_no_tasks_exception
        end
    end

    def print_status(res, clients, tasks)
        client = clients&.map{|cli| cli['name'] if cli['id'] == res['client_id']}&.compact&.first
        task = tasks&.map{|task| task['title'] if task['id'] == res['task_id']}&.compact&.first

        text = Rainbow("  Status: ").send(@@COLOR_HEADER).ljust(@@SPACERS)
        text += res['started_at'].nil? ? Rainbow("Disabled").send(@@COLOR_DANGER) : Rainbow("Active").send(@@COLOR_SUCCESS)
        text += "\n"

        if res['client_id'].nil? == false
            text += Rainbow("  Client: ").send(@@COLOR_HEADER).ljust(@@SPACERS)
            text += client.to_s
            text += "\n"
        end

        if res['task_id'].nil? == false
            text += Rainbow("  Task: ").send(@@COLOR_HEADER).ljust(@@SPACERS)
            text += task.to_s
            text += "\n"
        end

        if res['started_at'].nil? == false
            text += Rainbow("  Started at: ").send(@@COLOR_HEADER).ljust(@@SPACERS)
            text += res['started_at'].to_s
            text += "\n"
            text += Rainbow("  Tracked: ").send(@@COLOR_HEADER).ljust(@@SPACERS)
            text += 'X mins'
            text += "\n"
        end
       
        puts text
    end

    # Exceptions:

    def print_select_client_exception
        text = Rainbow('You should select a client to see it\'s tasks.').send(@@COLOR_ERROR)
        text += "\n"
        text += 'Try '
        text += Rainbow('[CLIENTS]').send(@@COLOR_HEADER)
        text += ' + '
        text += Rainbow('[USE]').send(@@COLOR_HEADER)
        text += ' commands first.'
        puts text
    end

    def print_no_clients_exception
        text = Rainbow('There are no clients to select.').send(@@COLOR_ERROR)
        text += "\n"
        text += 'Try to use '
        text += Rainbow('[PULL]').send(@@COLOR_HEADER)
        text += ' command to download data from the server first.'
        puts text
    end

    def print_no_tasks_exception
        text = Rainbow('There are no tasks of the selected client.').send(@@COLOR_ERROR)
        text += "\n"
        text += 'Try to use '
        text += Rainbow('[PULL]').send(@@COLOR_HEADER)
        text += ' command to download data or '
        text += Rainbow('[CLIENTS]').send(@@COLOR_HEADER)
        text += ' + '
        text += Rainbow('[USE]').send(@@COLOR_HEADER)
        text += ' command to select another one.'
        puts text
    end

    def print_wrong_key(key)
        text = Rainbow("  Error: Wrong key #{key}").send(@@COLOR_ERROR)
        text += "\n\n"
        puts text
    end
end    