module Ridley
  # @author Jamie Winsor <reset@riotgames.com>
  #
  # Classes and modules used for integrating with a Chef Server, the Chef community
  # site, and Chef Cookbooks
  module Chef
    require_relative 'chef/cookbook'
    require_relative 'chef/chefignore'
    require_relative 'chef/digester'
  end
end
