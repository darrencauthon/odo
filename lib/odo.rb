require "odo/version"
require 'nokogiri'
require 'open-uri'

module Odo

  def self.extract_ref_from element
    element['href'] || element['src']
  end

  def self.stubbing_things_out options

    url    = options[:url]
    target = options[:target]

    original = Nokogiri::HTML open url

    files = {
              stylesheet: original.css('link'),
              javascript: original.css('script'),
              image:      original.css('img')
            }

    files.keys.each { |k| files[k] = files[k].map { |x| extract_ref_from x } }
    files.keys.each { |k| files[k] = files[k].select { |x| x.to_s != '' } }

    files_to_download = files.map do |type, refs|
                          refs.map do |ref|
                            { 
                              type:     type,
                              original: ref,
                              source:   "#{url}/#{ref}",
                              target:   "#{target}/#{ref}"
                            }
                          end
                        end.flatten

    puts files_to_download.inspect

  end

end
