require "rack/http/status"
require "rails/webdav/controller/class_methods"
require "rails/webdav/controller/instance_methods"
require "rails/webdav/controller/webdav_methods"
require "rails/webdav/controller/xml_helpers"
require "rails/webdav/routing_helpers"
require "rails/webdav/version"

module Rails
	module WebDAV

		# Returns a new controller based on an existing controller
		def self.Controller base = nil

			Class.new(base || ActionController::Base) do

				# Adds controller methods
				include Controller::InstanceMethods
				include Controller::WebDAVMethods
				include Controller::XMLHelpers
				extend Controller::ClassMethods

				# Bypass controller rendering
				around_action :webdav do
					yield
				end

			end
		end

		# Inject routing helpers if available
		::ActionDispatch::Routing::Mapper.include RoutingHelpers if defined? ::ActionDispatch::Routing

	end
end
