module Rails
	module WebDAV
		module Controller

			ALLOWED_MODES = [
				:single_file,
				:single_folder,
				:multiple_files,
				:multiple_folders
			].freeze

			module ClassMethods

				attr_reader :webdav_controller_mode

				# Sets the controller's mode of behavior for routing purposes
				def webdav_controller_mode= val
					unless ALLOWED_MODES.include? val.to_sym
						raise ArgumentError, "Must be set to one of: #{ALLOWED_MODES.join(', ')}"
					end
					@webdav_controller_mode = val
				end

				def webdav_routing_mode
					unless @webdav_controller_mode
						raise "#{self}.webdav_controller_mode must be set to one of: #{ALLOWED_MODES.join(', ')}"
					end
					@webdav_controller_mode.match?(/^multiple/) ? :resources : :resource
				end

			end
		end
	end
end
