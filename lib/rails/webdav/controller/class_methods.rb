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

				def inherited child
					child.instance_variable_set :@webdav_controller_mode, @webdav_controller_mode
					super
				end

				# Define a convenient accessor
				def webdav_controller_mode *args
					return self.webdav_controller_mode = args[0] if args.count == 1
					@webdav_controller_mode
				end

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
