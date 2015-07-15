# encoding: utf-8

require 'ruby-plsql'

class Idm
  def initialize
    connect
  end

  def exist?(mail:)
    result = plsql.mail_pkg.exist mail
    result == 1 ? true : false
  end

private
  def connect
    plsql.connection = OCI8.new \
      ENV['IDM_USERNAME'],
      ENV['IDM_PASSWORD'],
      ENV['IDM_SID']
  end
end
