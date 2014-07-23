module Odo

  module Strategies

    class LocalStrategy

      def create_the_site options
        unless File.directory? options[:target]
          FileUtils.mkdir_p options[:target]
        end
      end

      def adjust_assets assets, options = {}
        depth = depth_considering options
        prefix = (0...depth).to_a.map { |_| './' }.join('')

        assets.each do |asset|
          asset[:replacement_for_original] = asset[:replacement_for_original].split('/')
                                               .reject { |x| x.to_s == '' }
                                               .join('/')
          asset[:replacement_for_original] = prefix + asset[:replacement_for_original]
        end
      end

      def depth_considering options
        uri = URI.parse(options[:page])
        uri.path == "" ? 0 : (uri.path.split('/').count - 1)
      rescue
        0
      end

    end

  end

end
