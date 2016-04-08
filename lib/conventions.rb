# encoding: utf-8

# In dieser Klasse sind die Bildungsvorschriften für Mailadressen kodiert
#

require "awesome_print"
require "umt"

class Conventions

  def initialize
    connect
  end

  def probe_for_next_free_mail(mail)
    return mail if (plsql.mail_pkg.exist(mail) == 0)
    parts = mail.split("@")
    local = parts[0]
    domain = parts[1]
    (2..20).each do |nr|
      other_mail = "#{local}#{nr}@#{domain}"
      return other_mail if (plsql.mail_pkg.exist(other_mail) == 0)
    end
    return nil
  end
  
  def get_proposed_mailaddress entry

    changeid = entry[0]
    userid = entry[1]
    nkz = entry[2]

    old_mail = entry[3]
    old_firstname = entry[5]
    old_lastname = entry[6]

    new_mail = entry[4]
    new_firstname = entry[7]
    new_lastname = entry[8]

    mailold_firstname = old_mail.split(".").first
    mailold_domainname = old_mail.split("@").last

    # entweder 
    mailprop_firstname = new_firstname.downcase.split(" ").first
    
    # oder
    #mailprop_firstname = mailold_firstname
    mailprop_lastname = new_lastname.downcase
    mailprop_lastname.gsub! '- ', '-'
    mailprop_lastname.gsub! ' -', '-'
    mailprop_lastname.gsub! ' ', '-'

    proposed_mail_raw = "#{mailprop_firstname}.#{mailprop_lastname}@#{mailold_domainname}"
    proposed_mail = substitute_special_characters proposed_mail_raw
    next_mail = proposed_mail
    #next_mail = probe_for_next_free_mail proposed_mail
    return next_mail
  end


  def substitute_special_characters proposed_mail_raw
    proposed_mail = proposed_mail_raw

    # Apostroph
    proposed_mail.gsub! "'", '-'

    # Umlaute
    proposed_mail.gsub! 'Ä', 'ae'
    proposed_mail.gsub! 'Ö', 'oe'
    proposed_mail.gsub! 'Ü', 'ue'
    proposed_mail.gsub! 'ä', 'ae'
    proposed_mail.gsub! 'ö', 'oe'
    proposed_mail.gsub! 'ü', 'ue'

    # deutsche Sonderzeichen
    proposed_mail.gsub! 'ß', 'ss'

    # norwegische Sonderzeichen
    # ae, oe
    
    # Akut
    proposed_mail.gsub! 'á', 'a'
    proposed_mail.gsub! 'é', 'e'

    # Gravis
    proposed_mail.gsub! 'à', 'a'
    proposed_mail.gsub! 'è', 'e'

    # Zirkumflex
    proposed_mail.gsub! 'â', 'a'
    proposed_mail.gsub! 'ê', 'e'

    # Trema
    proposed_mail.gsub! 'ë', 'e'
    proposed_mail.gsub! 'ï', 'i'
    
    # Tilde
    proposed_mail.gsub! 'ã', 'a'
    proposed_mail.gsub! 'ñ', 'n'
    proposed_mail.gsub! 'õ', 'o'

    # Cedille
    proposed_mail.gsub! 'ç', 'c'

    # Brevis (Rumänisch, Türkisch, Kyrillisch)
    proposed_mail.gsub! 'ă', 'a'

    # Hatschek (Tschechisch)
    proposed_mail.gsub! 'ǎ', 'a'
    proposed_mail.gsub! 'ě', 'e'
    proposed_mail.gsub! 'č', 'c'

    # Krouzek (Tschechisch, Dänisch, Norwegisch, Schwedisch)
    proposed_mail.gsub! 'å', 'a'
    proposed_mail.gsub! 'ů', 'u'
    
    # Doppelaktu (im Ungarischen als Längungszeichen)
    proposed_mail.gsub! 'ő', 'u'
    proposed_mail.gsub! 'ű', 'u'
    
    # sonstige diakritische Zeichen
    # ...
    
    return proposed_mail

  end


  def get_proposed_action(entry, groupwise, idm)
    proposed_mail =  get_proposed_mailaddress entry
    groupwise_mail = groupwise.get_mail(uid: entry[2])
    #groupwise_mail = entry[3]
    
    state = idm.get_account_state(uid_number: entry[1])
    ignore_states = ['suspended', 'after_hour']
    proposed_action = "UNKNOWN"
    if groupwise_mail.to_s.strip.length == 0
      proposed_action = 'EXTERNA' 
    elsif proposed_mail == groupwise_mail
      proposed_action = "CLOSE_NO_CHANGE"
    elsif ignore_states.include? state
      proposed_action = "CLOSE_BY_STATE"
    else
      proposed_action = "CHANGE"
    end

    proposed_action
  end
  
private
  def connect
    username = ENV['IDM_USERNAME']
    password = ENV['IDM_PASSWORD']
    sid = ENV['IDM_SID']
    plsql.connection ||= OCI8.new username, password, sid
    @db_umt = Sequel.connect("oracle://#{username}:#{password}@#{sid}")

    # @logging = UmtLogging.new
  end

end
