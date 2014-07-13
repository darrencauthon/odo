require 'image_scraper'

module Odo

  module Assets

    def self.from url, target

      original = Nokogiri::HTML open url

      files = {
                stylesheet: original.css('link'),
                javascript: original.css('script'),
                image:      original.css('img')
              }

      image_scraper = ImageScraper::Client.new(url, { :include_css_images => true })
      files[:css_images] = image_scraper.image_urls.map { |x| x.sub url, '' }

      files.keys.each { |k| files[k] = files[k].map { |x| extract_ref_from x } }
      files.keys.each { |k| files[k] = files[k].select { |x| x.to_s != '' } }

      assets = files.map do |type, refs|
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


      assets.reject { |x| x[:replacement_for_original].start_with?('/') }.each do |file_to_download|
        file_to_download[:replacement_for_original] = "/" + file_to_download[:replacement_for_original]
      end

      assets.select { |x| x[:replacement_for_original] == "/" }.each do |file|
        uri = URI.parse file[:original]
        file[:replacement_for_original] = "/#{uri.host}/" + UUID.new.generate
        file[:download_location] = "#{target}/#{file[:replacement_for_original]}"
      end

      assets.each do |asset|
        asset[:download_location] = asset[:download_location].gsub('//', '/')
      end

      assets

    end

    def self.extract_ref_from element
      return element if element.is_a? String
      element['href'] || element['src']
    end

  end
end
