module Odo

  module Strategies

    class LocalStrategy

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
