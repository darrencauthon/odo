require 'image_scraper'
require 'spidr'

module Odo

  module Assets

    def self.from(options = {})
      nokogiri = Nokogiri::HTML open options[:url]
      from_nokogiri(nokogiri, options) + from_image_scraper(options) + from_spidr(options)
    end

    def self.from_spidr options
      url = options[:url]
      uri = URI.parse(url)
      files = Spidr.start_at(url, hosts: [uri.host])
                .visited_links
                .select do |x|
                  uri = URI.parse x
                  ['.js', '.css', '.jpg', '.gif', '.jpeg', '.swf', '.png'].reduce(false) do |t, i|
                    t || uri.path.downcase.include?(i)
                  end
                end
                .map do |u|
                       begin
                         URI.parse(u).path
                       rescue
                         nil
                       end
                     end
                .select { |x| x }

      from_files files, options
    end

    def self.from_image_scraper options
      image_scraper = ImageScraper::Client.new(options[:url], { :include_css_images => true })

      files = image_scraper.image_urls
                .map { |x| x.sub options[:url], '' }
                .reject { |f| f.to_s == '' }

      from_files files, options
    end

    def self.from_nokogiri nokogiri, options

      files = [
                nokogiri.css('link').map   { |x| extract_ref_from x },
                nokogiri.css('script').map { |x| extract_ref_from x },
                nokogiri.css('img').map    { |x| extract_ref_from x },
              ].flatten.reject { |f| f.to_s == '' }

      from_files files, options

    end

    def self.from_files files, options

      url, target = options[:url], options[:target]

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
        asset[:download_location] = asset[:download_location].gsub('//', '/')
        asset[:replacement_for_original] = asset[:replacement_for_original].gsub('//', '/')
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
