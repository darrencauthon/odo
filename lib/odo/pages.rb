module Odo

  module Pages

    def self.from options

      url = options[:url]
      uri = URI.parse(url)
      files = Spidr.start_at(url, hosts: [uri.host])
                .visited_links
                .select do |x|
                  uri = URI.parse x
                  ['.js', '.css', '.jpg', '.gif', '.jpeg', '.swf', '.png'].reduce(false) do |t, i|
                    t || uri.path.downcase.include?(i)
                  end == false
                end
                .select { |x| x }
    end

  end

end
