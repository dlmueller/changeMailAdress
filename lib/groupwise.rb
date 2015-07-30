# encoding: utf-8

# Diese Klasse ist der Konnektor hin zum Groupwise.
#

require "net/ldap"
require "awesome_print"

class Groupwise

  def initialize
    connect
  end

  def get_mail uid:
    filter = Net::LDAP::Filter.eq 'uid', uid
    basedn = ENV['GWLDAP_BASEDN']
    attributes = ['dn', 'mail']

    mail_attribute = nil
    @ldap.search(base: basedn, filter: filter, attributes: attributes) do |entry|
      mail_attribute = entry.mail[0]
    end
    mail_attribute
  end

  def uid_exist? uid: uid
    filter = Net::LDAP::Filter.eq 'uid', uid
    basedn = ENV['GWLDAP_BASEDN']
    attributes = ['dn']

    counter = 0
    @ldap.search(base: basedn, filter: filter, attributes: attributes) do |entry|
      counter += 1
    end

    counter > 0 ? true : false
  end

  def uid_not_exist? uid: uid
    !uid_exist?(uid: uid)
  end

private
  def connect
    @ldap = Net::LDAP.new(
      host: ENV['GWLDAP_HOST'],
      port: ENV['GWLDAP_PORT'].to_i,
      auth: {
        method: :simple,
        username: ENV['GWLDAP_USER'],
        password: ENV['GWLDAP_PASSWORD']
      }
    )
  end
end
