require "odo/version"
Dir[File.dirname(__FILE__) + '/odo/*.rb'].each {|file| require file }
require 'nokogiri'
require 'open-uri'
require 'pp'
require 'uuid'

module Odo


  def self.stubbing_things_out options

    url    = options[:url]
    target = options[:target]

    assets = Assets.from url, target

    assets.each do |asset|
      asset[:replacement_for_original] = asset[:replacement_for_original].split('/')
                                           .reject { |x| x.to_s == '' }
                                           .join('/')
    end

    html = Html.for url, considering: { assets: assets }

    unless File.directory? target
      FileUtils.mkdir_p target
    end

    File.open("#{target}/index.html", 'w') { |f| f.write html }

    Assets.download assets

  end

end
