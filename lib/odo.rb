require "odo/version"
require 'nokogiri'
require 'open-uri'
require 'pp'
require 'uuid'

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
                            uri = URI.parse(ref)
                            download_location = "#{target}/" + (uri.host ? "#{uri.host}#{uri.path}" : uri.path).to_s
                            { 
                              type:                     type,
                              original:                 ref,
                              source:                   uri.host ? ref : "#{url}/#{uri.path}",
                              download_location:        download_location,
                              replacement_for_original: uri.path.to_s
                            }
                          end
                        end.flatten

    files_to_download.reject { |x| x[:replacement_for_original].start_with?('/') }.each do |file_to_download|
      file_to_download[:replacement_for_original] = "/" + file_to_download[:replacement_for_original]
    end

    files_to_download.select { |x| x[:replacement_for_original] == "/" }.each do |file|
      file[:replacement_for_original] = "/" + UUID.new.generate
      file[:download_location] += "/#{file[:replacement_for_original]}".gsub("//", "/")
    end

    pp files_to_download

  end

end
