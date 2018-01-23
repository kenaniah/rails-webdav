module Rails
	module WebDAV
		module Controller

			module ClassMethods
			end

			module InstanceMethods

			protected

				# Defines a request handler
				def handle_request
					begin
						yield
					rescue Status => status
						response.status = status.code
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
					resource.property_names.map do |n|
						node = Nokogiri::XML::Element.new n, request_document
						node.add_namespace nil, 'DAV:'
						node
					end
				end

				# Generates an XML response
				def render_xml
					content = Nokogiri::XML::Builder.new encoding: "UTF-8" do |xml|
						yield xml
					end
					response.body = [content]
					response["Content-Type"] = 'text/xml; charset=utf-8'
					response["Content-Length"] = content.bytesize.to_s
				end

				# Renders a multi-status XML response
				def multistatus
					render_xml do |xml|
						xml.multistatus 'xmlns' => 'DAV:' do
							yield xml
						end
					end
					response.status = MultiStatus
				end

				# Returns the available property names
				def property_names
					%w(creationdate displayname getlastmodified getetag resourcetype getcontenttype getcontentlength)
				end

				# Defines PROPFIND method
				def propfind

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
						raise BadRequest if n.namespace.nil? && n.namespace_definitions.empty?

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
						self.index.each do |resource|
							xml.response do
								xml.href resource.path
								propstats xml, getproperties(resource, nodes)
							end
						end

					end

				end

				# Appends XML status codes
				def propstats xml, stats

				end

				def get_properties resource, nodes
					stats = Hash.new { |h, k| h[k] = [] }
					nodes.each do |node|
						begin
							stats[OK] << [node, resource.get_property(qualified_property_name(node))]
						rescue Status
							stats[$!] << node
						end
					end
					stats
				end

				def qualified_property_name node
					node.namespace.nil? || node.namespace.href == 'DAV:' ? node.name : "{#{node.namespace.href}}#{node.name}"
				end

			end

		end
	end
end
