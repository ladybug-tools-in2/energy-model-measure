source 'http://rubygems.org'

# Specify your gem's dependencies
gemspec

# get the openstudio-extension gem
if File.exist?('../OpenStudio-extension-gem')  # local development copy
  gem 'openstudio-extension', path: '../OpenStudio-extension-gem'
else  # get it from rubygems.org
  gem 'openstudio-extension', '0.1.6'
end

# coveralls gem is used to generate coverage reports through CI
gem 'coveralls', require: false

# uncomment the following to run tests locally using `bundle exec rake`.
# simplecov has an unneccesary dependency on native json gem, use fork that does not require this
#gem 'simplecov', github: 'NREL/simplecov'
