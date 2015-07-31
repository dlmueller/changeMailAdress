# encoding: utf-8

require "awesome_print"
require 'ruby-plsql'
require 'pry'

class Idm
  def initialize
    connect
  end

  def mail_exist?(mail:)
    result = plsql.mail_pkg.exist mail
    result == 1 ? true : false
  end

  def mail_not_exist?(mail:)
    !mail_exist?(mail: mail)
  end

  def uid_exist?(uid:)
    plsql.account_pkg.exist(uid)
  end

  def uid_not_exist?(uid:)
    !uid_exist?(uid: uid)
  end

  def change(id:,mail:)
    plsql.mail_pkg.updateMailAddress(id, mail)
  end

  def verify?(uid:,mail:)
    current_mail = plsql.mail_pkg.getMailAddress(uid)

    current_mail == mail ? true : false
  end

  def get_change_mail_queue
    records = nil
    plsql.mail_pkg.getChangeMailQueue { |c| records = c.fetch_all }
    records
  end

  def get_change_mail_queue_entry(id:)
    record = []
    plsql.mail_pkg.getChangeMailQueueEntry(id) { |c| record = c.fetch_all }

    if record.count != 0
      record.first
    else
      []
    end
  end

  def set_change_admin(id:,uid:)
    plsql.mail_pkg.setChangeSignatureAdmin(id, uid)
  end

  def set_new_mail(id:,mail:)
    plsql.mail_pkg.setChangeSignatureMail(id,mail)
  end

  def set_change_mail_queue_task_close(id:)
    plsql.mail_pkg.setChangeMailTaskClose(id)
  end

  def set_gw_change_task(id:)
    entry = get_change_mail_queue_entry(id: id)
    plsql.mail_pkg.setGwChangeTask(id, entry[1])
  end

  def set_change_signature(uid:,id:,mail:)
    set_change_admin(id: id, uid: uid)
    set_new_mail(id: id, mail: mail)
    set_change_mail_queue_task_close(id: id)
  end

  def getUid(umt_login_id:)
    plsql.account_pkg.getNKZ(umt_login_id)
  end

  def get_account_type(uid_number:)
    plsql.account_pkg.getAccountType(uid_number)
  end

  def get_account_state(uid_number:)
    plsql.account_pkg.getAccountState(uid_number)
  end

private
  def connect
    plsql.connection = OCI8.new \
      ENV['IDM_USERNAME'],
      ENV['IDM_PASSWORD'],
      ENV['IDM_SID']
  end
end
