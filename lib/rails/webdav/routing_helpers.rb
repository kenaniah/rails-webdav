module Rails
	module WebDAV
		module RoutingHelpers
			def webdav_resource *resources, &block

				options = resources.extract_options!.dup
				if apply_common_behavior_for(:webdav_resource, resources, options, &block)
					return self
				end

				with_scope_level @scope[:options][:routing_mode] do

					routing_mode = @scope[:options].delete :routing_mode
					klass = routing_mode == :resources ? ActionDispatch::Routing::Mapper::Resources::Resource : ActionDispatch::Routing::Mapper::Resources::SingletonResource

					options = apply_action_options options
					options[:controller] ||= resources.first
					resource_scope(klass.new(resources.pop, api_only?, @scope[:shallow], options)) do

						yield if block_given?

						concerns(options[:concerns]) if options[:concerns]

						collection do
							[:propfind, :options].each do |m|
								match "", action: :webdav, via: m
							end
						end

						if routing_mode == :resources
							member do
								[:propfind, :options, :head, :get].each do |m|
									match "", action: :webdav, via: m
								end
							end
						end

					end

				end

			end
		end
	end
end
