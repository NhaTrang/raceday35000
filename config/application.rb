require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Raceday
  class Application < Rails::Application
    
    Mongoid.load!('./config/mongoid.yml')
    
    #which default ORM are we using with scaffold
    
    #add --orm mongoid, or active_record
    
    # to rails generate cmd line to be specific
    
    #config.generators {|g| g.orm :active_record}
    
    config.generators {|g| g.orm :mongoid}
   
    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true
  end
end
