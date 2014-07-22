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

    strategy = Odo::Strategies::LocalStrategy.new
    assets = strategy.adjust_assets assets

    strategy.create_the_site target: target

    Odo::Pages.from(options).each do |page|
      html = Html.for page, considering: { assets: assets }

      uri = URI.parse(page)
      path = uri.path == "" ? "index.html" : uri.path
      File.open("#{target}/#{path}", 'w') { |f| f.write html }
    end

    Assets.download assets

  end

end
