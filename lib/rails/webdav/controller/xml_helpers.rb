module Rails
	module WebDAV
		module Controller
			module XMLHelpers

			private

				# Returns an instance of the XML document
				def _xml_request_document
					@_xml_request_document ||= if (body = request.body.read).empty?
						Nokogiri::XML::Document.new
					else
						Nokogiri::XML body, &:strict
					end
				end

				# Traverses the XML document to find certain nodes
				def _xml_request_match pattern
					_xml_request_document.xpath pattern, 'd' => 'DAV:'
				end

				# Ensures that XML node names are properly qualified
				def _xml_qualified_node_name node
					node.namespace.nil? || node.namespace.prefix.nil? ? node.name : "#{node.namespace.prefix}:#{node.name}"
				end

				# Ensures that XML property names are properly qualified
				def _xml_qualified_property_name node
					node.namespace.nil? || node.namespace.href == 'DAV:' ? node.name : "{#{node.namespace.href}}#{node.name}"
				end

				# Generates an XML response
				def _xml_render
					content = Nokogiri::XML::Builder.new encoding: "UTF-8" do |xml|
						yield xml
					end.to_xml
					response.body = [content]
					response["Content-Type"] = 'text/xml; charset=utf-8'
					response["Content-Length"] = content.bytesize.to_s
				end

			end
		end
	end
end
