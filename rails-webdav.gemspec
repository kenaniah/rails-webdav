lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "rails/webdav/version"

Gem::Specification.new do |gem|
	gem.name = "rails-webdav"
	gem.version = Rails::WebDAV::VERSION
	gem.authors = ["Kenaniah Cerny"]
	gem.email = ["kenaniah@gmail.com"]

	gem.summary = "Provides WebDAV functionality for Rails controllers"
	gem.homepage = "https://github.com/kenaniah/rails-webdav"

	gem.files = `git ls-files -z`.split("\x0").reject do |f|
		f.match(%r{^(test|spec|features)/})
	end
	gem.bindir = "exe"
	gem.executables = gem.files.grep(%r{^exe/}) { |f| File.basename(f) }
	gem.require_paths = ["lib"]

	gem.add_dependency "nokogiri", "~> 1.8"
	gem.add_dependency "rails", "~> 5.0"

	gem.add_development_dependency "bundler", "~> 1.16"
	gem.add_development_dependency "rake", "~> 10.0"
	gem.add_development_dependency "pry"

end
