require 'rubygems'
require 'active_support'
require 'active_resource'

# Ruby lib for working with the Mingle API's XML interface.
# You should set the authentication using your login
# credentials with HTTP Basic Authentication.

# This library is a small wrapper around the REST interface
begin
  require 'uri'
  require 'addressable/uri'

  module URI
    def decode(*args)
      Addressable::URI.decode(*args)
    end

    def escape(*args)
      Addressable::URI.escape(*args)
    end

    def parse(*args)
      Addressable::URI.parse(*args)
    end
  end
rescue LoadError => e
  puts "Install the Addressable gem (with dependencies) to support accounts with subdomains."
  puts "# sudo gem install addressable --development"
  puts e.message
end

module AssemblaAPI
  class Error < StandardError; end
  class << self
    attr_accessor :username, :password, :host_format, :account_format, :domain_format, :protocol

    #Sets up basic authentication credentials for all the resources.
    def authenticate(username, login)
      @username  = username
      @password  = login
      self::Base.user = username
      self::Base.password = login

      resources.each do |klass|
        klass.site = "http://#{username}:#{login}@www.assembla.com"
        #klass.site = klass.site_format % (host_format % [protocol, account_format % [username, login], domain_format % [server, "#{port}"]])
        klass.headers['Content-Type'] = 'application/x-www-form-urlencoded'
      end
    end

    def resources
      @resources ||= []
    end
  end

  #self.host_format    = '%s://%s@%s/api/v2'
  #self.account_format = '%s:%s'
  #self.domain_format  = '%s:%s'
  #self.protocol       = 'http'

  class Base < ActiveResource::Base
    def self.inherited(base)
      AssemblaAPI.resources << base
      class << base
        attr_accessor :site_format
      end  
      base.site_format = '%s'
      super
    end
  end

  class Space < Base

   def tickets(options = {})
      Ticket.find(:all, :params => options.update(:space_id => id))
    end
  
    def milestones(options = {})
      Milestone.find(:all, :params => options.update(:space_id => id))
    end
  end

  class Ticket < Base
    site_format << '/spaces/:space_id'
  end

  class Comment < Base
    site_format << '/spaces/:space_id/tickets/:ticket_id'
  end
  
  class Message < Base
    site_format << '/spaces/:space_id'
  end
  

end
