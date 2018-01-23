module Rails
	module WebDAV
		module Controller

			module ClassMethods
			end

			module InstanceMethods

				# Defines PROPFIND method
				def propfind

					puts request.body.read.green

					# Determine what nodes to return
					if request_match("/d:propfind/d:allprop").empty?
						nodes = request_match "/d:propfind/d:prop/*"
						nodes = all_prop_nodes if nodes.empty?
					else
						nodes = all_prop_nodes
					end

					# Iterate the nodes
					nodes.each do |n|

						# Don't allow empty namespace declarations
						raise Rack::HTTP::Status::BadRequest if n.namespace.nil? && n.namespace_definitions.empty?

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
							xml['DAV'].response do
								xml['DAV'].href resource.path
								propstats xml, get_properties(resource, nodes)
							end
						end
					end

				end

				# Defines OPTIONS method
				def options
					response["Allow"] = 'OPTIONS,HEAD,GET,PUT,POST,DELETE,PROPFIND,PROPPATCH,MKCOL,COPY,MOVE'
					response["Dav"] = "1"
					response["Ms-Author-Via"] = "DAV"
				end

			protected

				# Defines a request handler
				def handle_request
					begin
						self.send request.request_method.downcase
					rescue Rack::HTTP::Status::Status => status
						response.status = status.to_i
					end
				end

				# Returns an instance of the XML document
				def request_document
					@request_document ||= if (body = request.body.read).empty?
						Nokogiri::XML::Document.new
					else
						Nokogiri::XML body, &:strict
					end
				end

				# Traverses the XML document to find certain nodes
				def request_match pattern
					request_document.xpath pattern, 'd' => 'DAV:'
				end

				# Returns a list of all property nodes
				def all_prop_nodes
					property_names.map do |n|
						node = Nokogiri::XML::Element.new n, request_document
						node.add_namespace nil, 'DAV:'
						node
					end
				end

				# HACK
				def property_names
					%w(creationdate displayname getlastmodified getetag resourcetype getcontenttype getcontentlength)
				end

				# Generates an XML response
				def render_xml
					content = Nokogiri::XML::Builder.new encoding: "UTF-8" do |xml|
						yield xml
					end.to_xml
					puts content.cyan
					response.body = [content]
					response["Content-Type"] = 'text/xml; charset=utf-8'
					response["Content-Length"] = content.bytesize.to_s
				end

				# Renders a multi-status XML response
				def multistatus
					render_xml do |xml|
						xml['DAV'].multistatus 'xmlns:DAV' => 'DAV:' do
							yield xml
						end
					end
					response.status = Rack::HTTP::Status::MultiStatus
				end

				# Appends XML status codes
				def propstats xml, stats
					return if stats.empty?
					stats.each do |status, props|
						xml.propstat do
							xml.status "HTTP/1.1 #{status.status_line}"
							xml.prop do
								props.each do |node, value|
									if value.is_a? Nokogiri::XML::Node
										xml['DAV'].send qualified_node_name(node).to_sym do
											rexml_convert xml, value
										end
									else
										attrs = {}
										unless node.namespace.nil?
											unless node.namespace.prefix.nil?
												attrs = { "xmlns:#{node.namespace.prefix}" => node.namespace.href }
											else
												attrs = { 'xmlns' => node.namespace.href }
											end
										end
										xml['DAV'].send qualified_node_name(node).to_sym, value, attrs
									end
								end
							end
						end
					end
				end

				def get_properties resource, nodes
					stats = Hash.new { |h, k| h[k] = [] }
					nodes.each do |node|
						begin
							stats[Rack::HTTP::Status::OK] << [node, resource.get_property(qualified_property_name(node))]
						rescue Rack::HTTP::Status::Status
							stats[$!] << node
						end
					end
					stats
				end

				def qualified_node_name(node)
					"DAV:#{node.name}"
					#node.namespace.nil? || node.namespace.prefix.nil? ? node.name : "#{node.namespace.prefix}:#{node.name}"
				end

				def qualified_property_name node
					node.namespace.nil? || node.namespace.href == 'DAV:' ? node.name : "{#{node.namespace.href}}#{node.name}"
				end

				def rexml_convert xml, element
					if element.elements.empty?
						if element.text
							xml['DAV'].send element.name.to_sym, element.text, element.attributes
						else
							xml['DAV'].send element.name.to_sym, element.attributes
						end
					else
						xml['DAV'].send element.name.to_sym, element.attributes do
							element.elements.each do |child|
								rexml_convert xml, child
							end
						end
					end
				end

			end

		end
	end
end
