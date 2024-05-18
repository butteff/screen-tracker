# frozen_string_literal: true

require 'is_valid'
require_relative './database'
require_relative './views'
include Database
include Views

module Iostream
  @@sqlt = Sqlt.new
  @@valid = IsValid.new(
    {
      settings: {
        url: 'url',
        is_shot: 'boolean',
        interval: 'integer'
      },
      status: {
        client_id: 'integer',
        task_id: 'integer*',
        started_at: 'nil',
        finished_at: 'nil'
      },
      tasks: {
        client_id: 'integer',
        title: 'words'
      },
      logs: {
        client_id: 'integer',
        task_id: 'integer',
        user_id: 'integer',
        timestamp: 'integer',
        screenshot: 'any'
      }
    }
  )

  def io_set_one(tbl, key, value)
    where = false
    if key == 'task_id'
      status = io_get_raw('status')&.first
      where = "client_id = #{status['client_id']}"
    end
    has_reference = @@sqlt.check_exist("#{key.gsub('_id', '')}s", value, where) if key.end_with?('_id')
    has_reference = @@sqlt.check_key(tbl, key) if tbl == 'settings'
    if has_reference
      io_set_row(tbl, key, value)
    else
      tbl != 'settings' ? send("print_no_#{key.gsub('_id', '')}s_exception") : print_wrong_key(key)
    end
  end

  def io_set_row(tbl, key, value)
    sql = "select * from #{tbl}"
    res = @@sqlt.read(sql)
    hash_data = res.first
    hash_data[key] = value
    validation = @@valid.check_hash(hash_data, tbl)
    if validation == true
      hash_data['task_id'] = nil if key == 'client_id'
      @@sqlt.write(tbl, hash_data, true)
    else
      print_errors(validation)
    end
  end

  def io_add_row(tbl, hash_data)
    validation = @@valid.check_hash(hash_data, tbl)
    return unless validation == true

    @@sqlt.write(tbl, hash_data)
  end

  def io_del_row(tbl, id)
    validation = @@valid.check(id, 'integer')
    return unless validation == true

    @@sqlt.remove_by_id(tbl, id)
  end

  def io_get_raw(tbl, where = false)
    sql = "select * from #{tbl}"
    sql += " where #{where}" if where
    @@sqlt.read(sql)
  end

  def io_get(tbl, where = false)
    res = io_get_raw(tbl, where)
    send("print_#{tbl}", res)
  end

  def io_print(view)
    send("print_#{view}")
  end
end
