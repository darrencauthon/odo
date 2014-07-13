module Odo

  module Html

    def self.for url, options

      assets = options[:considering][:assets]

      original = Nokogiri::HTML open url
      original.elements.each do |element|
        correct_element_with element, assets
      end

      original.to_html
    end

    def self.correct_element_with element, assets
      if thing = assets.select { |x| x[:original] == element['href'] }.first
        element['href'] = thing[:replacement_for_original]
      end
      if thing = assets.select { |x| x[:original] == element['src'] }.first
        element['src'] = thing[:replacement_for_original]
      end
      element.elements.each do |sub_element|
        correct_element_with sub_element, assets
      end
    end

  end

end
