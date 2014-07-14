require 'image_scraper'

module Odo

  module Assets

    def self.from(options = {})

      url, target = options[:url], options[:target]

      original = Nokogiri::HTML open url

      image_scraper = ImageScraper::Client.new(url, { :include_css_images => true })

      files = [
                original.css('link').map { |x| extract_ref_from x },
                original.css('script').map { |x| extract_ref_from x },
                original.css('img').map { |x| extract_ref_from x },
                image_scraper.image_urls.map { |x| x.sub url, '' }
              ].flatten.reject { |f| f.to_s == '' }

      assets = files.map do |file|
                 uri = URI.parse(file)
                 download_location = "#{target}/" + (uri.host ? "#{uri.host}#{uri.path}" : uri.path).to_s
                 {
                   original:                 file,
                   source:                   uri.host ? file : "#{url}/#{uri.path}",
                   download_location:        download_location,
                   replacement_for_original: uri.path.to_s
                 }
               end.flatten


      assets.reject { |x| x[:replacement_for_original].start_with?('/') }.each do |file_to_download|
        file_to_download[:replacement_for_original] = "/" + file_to_download[:replacement_for_original]
      end

      assets.select { |x| URI.parse x[:original] }.each do |asset|
        uri = URI.parse asset[:original]
        sigh = asset[:replacement_for_original] == '/' ? UUID.new.generate : uri.path
        asset[:download_location] = "#{target}/#{uri.host}/#{sigh}"
        asset[:replacement_for_original] = "/#{uri.host}/" + sigh
      end

      assets.each do |asset|
        asset[:download_location] = asset[:download_location].gsub('//', '/')
        asset[:replacement_for_original] = asset[:replacement_for_original].gsub('//', '/')
      end

      assets

    end

    def self.download assets
      assets.each do |asset|
        asset_directory = asset[:download_location].split('/')
        asset_directory.pop
        asset_directory = asset_directory.join('/')
        unless File.directory? asset_directory
          FileUtils.mkdir_p asset_directory
        end
        `wget \"#{asset[:source]}\" -O \"#{asset[:download_location]}\"`
      end
    end

    def self.extract_ref_from element
      return element if element.is_a? String
      element['href'] || element['src']
    end

  end
end
