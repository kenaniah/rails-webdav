module Rails
	module WebDAV
		module Controller
			module XMLHelpers

			private

				def _xml_qualified_node_name node
					node.namespace.nil? || node.namespace.prefix.nil? ? "DAV:#{node.name}" : "#{node.namespace.prefix}:#{node.name}"
				end

				def _xml_qualified_property_name node
					node.namespace.nil? || node.namespace.href == 'DAV:' ? node.name : "{#{node.namespace.href}}#{node.name}"
				end

			end
		end
	end
end
