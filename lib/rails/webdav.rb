require "rails/webdav/controller"
require "rails/webdav/http_status"
require "rails/webdav/version"

module Rails
	module WebDAV

		# Returns a new controller based on an existing controller
		def self.Controller base = nil
			Class.new(base || ActionController::Base) do

				# Adds controller methods
				include Controller::InstanceMethods
				extend Controller::ClassMethods

				# Adds HTTP status handling
				include Rails::WebDAV::HTTPStatus
				around_action :handle_request

			end
		end

	end
end
