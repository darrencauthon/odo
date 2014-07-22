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

    strategy = Odo::Strategies::LocalStrategy.new

    strategy.create_the_site target: target

    all_assets = []

    Odo::Pages.from(options).each do |page|

      page_assets = Assets.from_url(url: page, target: target)
      page_assets = strategy.adjust_assets page_assets

      html = Html.for page, considering: { assets: page_assets }

      uri = URI.parse(page)
      path = uri.path == "" ? "index.html" : uri.path
      File.open("#{target}/#{path}", 'w') { |f| f.write html }

      all_assets += page_assets
    end

    all_assets += strategy.adjust_assets(Assets.from_domain(options))
    all_assets.flatten!

    Assets.download all_assets

  end

end
