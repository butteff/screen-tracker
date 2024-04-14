module Validation    
    class ValidCheck
        def initialize
            @rules = {
                integer: '^(\d)+$',
                float: '^(\d)+,(\d)+$',
                word: '^(\w)+$',
                words: '^(\w| )+$',
                sentence: '^(\w| |,)+(\.|!|\?)$',
                boolean: '^(1|0|true|false)$',
                url: '^(http://|https://)(.)+\.(.)+$',
            }

            @templates = {
                settings: {
                    url: 'url',
                    is_shot: 'boolean',
                    interval: 'integer',
                }
            }
        end

        def check(var, rule_name)
            var.to_s.match?(@rules[rule_name.to_sym])
        end

        def check_hash(hash_var, template)
            errors = []
            rules = @templates[template.to_sym]
            if !rules.nil?
                hash_var.each do |key, val|
                   errors << checked = key+' is not valid, should be '+rules[key.to_sym] if !check(val, rules[key.to_sym])
                end
            else
                p 'template with rules does not exist'
            end
            res = errors.length == 0 ? true : errors
        end
    end
end
