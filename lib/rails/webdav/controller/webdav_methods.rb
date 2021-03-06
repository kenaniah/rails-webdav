module Rails
	module WebDAV
		module Controller
			module WebDAVMethods

				# Defines a request handler
				def webdav
					request.headers.select{ |k, v| k.starts_with? "HTTP_" }.each { |k, v| puts "#{k} - #{v}".light_blue }
					puts request.body.read.light_blue
					begin
						self.send :"webdav_#{request.request_method.downcase}"
					rescue ::Rack::HTTP::Status::Status => status
						response.status = status.to_i
					end
					puts response.body.cyan
				end

				# Defines the PROPFIND method
				def webdav_propfind

					# Determine what properties to return
					nodes = nil
					if _xml_request_match("/d:propfind/d:allprop").empty?
						nodes = _xml_request_match "/d:propfind/d:prop/*"
					end
					nodes = all_prop_nodes if nodes.empty?

					# Iterate the nodes
					nodes.each do |n|

						# Don't allow empty namespace declarations
						raise ::Rack::HTTP::Status::BadRequest if n.namespace.nil? && n.namespace_definitions.empty?

						# Set a blank namespace if one is included in the request
						# <propfind xmlns="DAV:"><prop><nonamespace xmlns=""/></prop></propfind>
						if n.namespace.nil?
							nd = n.namespace_definitions.first
							if nd.prefix.nil? && nd.href.empty?
								n.add_namespace(nil, '')
							end
						end

					end

					# Return a collection
					multistatus do |xml|
						self.index.each do |name, resource|
							xml.response do
								xml.href resource.path
								propstats xml, get_properties(resource, nodes)
							end
						end
					end

				end

				# Defines the OPTIONS method
				def webdav_options
					response["Allow"] = 'OPTIONS,HEAD,GET,PUT,POST,DELETE,PROPFIND,PROPPATCH,MKCOL,COPY,MOVE'
					response["Dav"] = "1"
					response["Ms-Author-Via"] = "DAV"
				end

			end
		end
	end
end
