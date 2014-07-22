require "odo/version"
Dir[File.dirname(__FILE__) + '/odo/*.rb'].each {|file| require file }
Dir[File.dirname(__FILE__) + '/odo/strategies/*.rb'].each {|file| require file }
require 'nokogiri'
require 'open-uri'
require 'pp'
require 'uuid'

module Odo


  def self.stubbing_things_out options

    url    = options[:url]
    target = options[:target]
    filename = options[:filename] || 'index.html'

    assets = Assets.from(url: url, target: target)
    raise assets.inspect

    strategy = Odo::Strategies::LocalStrategy.new
    assets = strategy.adjust_assets assets

    html = Html.for url, considering: { assets: assets }

    strategy.create_the_site target: target

    File.open("#{target}/#{filename}", 'w') { |f| f.write html }

    Assets.download assets

  end

end
