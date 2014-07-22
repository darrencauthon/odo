require_relative 'minitest_helper'

describe Odo do

  describe "stubbing things out" do

    it "should do something" do

      Odo.stubbing_things_out(url:    ENV['URL'],
                              target: ENV['target'])
        
    end

  end

end
