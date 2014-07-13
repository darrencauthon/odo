module Odo

  module Strategies

    class LocalStrategy

      def create_the_site options
        unless File.directory? options[:target]
          FileUtils.mkdir_p options[:target]
        end
      end

      def adjust_assets assets
        assets.each do |asset|
          asset[:replacement_for_original] = asset[:replacement_for_original].split('/')
                                               .reject { |x| x.to_s == '' }
                                               .join('/')
        end
      end

    end

  end

end
