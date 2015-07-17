# encoding: utf-8

require 'ruby-plsql'

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

  def change(uid:,mail:)
    plsql.mail_pkg.updateMailAddress(uid, mail)
  end

  def verify?(uid:,mail:)
    current_mail = plsql.mail_pkg.getMailAddress(uid)

    current_mail == mail ? true : false
  end

private
  def connect
    plsql.connection = OCI8.new \
      ENV['IDM_USERNAME'],
      ENV['IDM_PASSWORD'],
      ENV['IDM_SID']
  end
end
