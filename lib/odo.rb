require "odo/version"
require 'nokogiri'
require 'open-uri'

module Odo

  def self.stubbing_things_out options

    url    = options[:url]
    target = options[:target]

    original = Nokogiri::HTML open(url)

    files = {
              stylesheets:      original.css('script').map { |e| e['src'] },
              javascript_files: original.css('script').map { |e| e['src'] },
              images:           original.css('img').map { |e| e['src'] }
            }
    files.keys.each { |k| files[k] = files[k].select { |x| x.to_s != '' } }

    files_to_download = files.map do |_, v|
                          v.map do |x| 
                            { 
                              source: url + '/' + x.to_s,
                              target: target + '/' + x.to_s
                            }
                          end
                        end.flatten

    puts files_to_download.inspect

  end

end
