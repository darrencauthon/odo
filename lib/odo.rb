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

    assets = Assets.from(url: url, target: target)

    strategy = Odo::Strategies::LocalStrategy.new
    assets = strategy.adjust_assets assets

    html = Html.for url, considering: { assets: assets }

    strategy.create_the_site target: target

    File.open("#{target}/index.html", 'w') { |f| f.write html }

    Assets.download assets

  end

  def self.stubbing_more_things_out options
    url    = options[:url]
    target = options[:target]

    assets = Assets.from(url: url, target: target)

    strategy = Odo::Strategies::LocalStrategy.new
    assets = strategy.adjust_assets assets

    html = Html.for url, considering: { assets: assets }

    strategy.create_the_site target: target

    File.open("#{target}/index.html", 'w') { |f| f.write html }

    Assets.download assets
  end

end
