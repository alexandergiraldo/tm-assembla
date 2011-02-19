module TicketMaster::Provider
  module Assembla
    # Project class for ticketmaster-assembla
    #
    #
    class Project < TicketMaster::Provider::Base::Project
      API = AssemblaAPI::Project # The class to access the api's projects
      # declare needed overloaded methods here
      def name
        self[:name]
      end

      def created_at
        begin
          Time.parse(self[:created_at])
        rescue
          self[:created_at]
        end
      end
      
      def updated_at
        begin
          Time.parse(self[:updated_at])
        rescue
          self[:updated_at]
        end
      end
      
      # copy from this.copy(that) copies that into this
      def copy(project)
        project.tickets.each do |ticket|
          copy_ticket = self.ticket!(:title => ticket.title, :description => ticket.description)
          ticket.comments.each do |comment|
            copy_ticket.comment!(:body => comment.body)
            sleep 1
          end
        end
      end

    end
  end
end


