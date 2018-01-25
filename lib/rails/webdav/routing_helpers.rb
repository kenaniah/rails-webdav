module Rails
	module WebDAV
		module RoutingHelpers
			def webdav_collection *resources, &block
				options = resources.extract_options!.dup
				if apply_common_behavior_for(:webdav_collection, resources, options, &block)
					return self
				end
				with_scope_level :resources do
					options = apply_action_options options
					resource_scope(ActionDispatch::Routing::Mapper::Resources::Resource.new(resources.pop, api_only?, @scope[:shallow], options)) do
						yield if block_given?
						concerns(options[:concerns]) if options[:concerns]
						collection do
							[:propfind, :options, :head, :get].each do |m|
								match "", action: :webdav, via: m
							end
						end
					end
				end
			end
			def webdav_file *resources, &block
				options = resources.extract_options!.dup
				if apply_common_behavior_for(:webdav_file, resources, options, &block)
					return self
				end
				with_scope_level :resource do
					options = apply_action_options options
					resource_scope(ActionDispatch::Routing::Mapper::Resources::Resource.new(resources.pop, api_only?, @scope[:shallow], options)) do
						yield if block_given?
						concerns(options[:concerns]) if options[:concerns]
						collection do
							[:propfind, :options].each do |m|
								match "", action: :webdav, via: m
							end
						end
					end
				end
			end
		end
	end
end
