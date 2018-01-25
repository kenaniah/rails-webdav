module Rails
	module WebDAV
		module Controller
			module XMLHelpers

			private

				# Traverses the XML document to find certain nodes
				def _xml_request_match pattern
					request_document.xpath pattern, 'd' => 'DAV:'
				end

				# Ensures that XML node names are properly qualified
				def _xml_qualified_node_name node
					node.namespace.nil? || node.namespace.prefix.nil? ? node.name : "#{node.namespace.prefix}:#{node.name}"
				end

				# Ensures that XML property names are properly qualified
				def _xml_qualified_property_name node
					node.namespace.nil? || node.namespace.href == 'DAV:' ? node.name : "{#{node.namespace.href}}#{node.name}"
				end

			end
		end
	end
end
