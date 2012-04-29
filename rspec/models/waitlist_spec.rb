require File.dirname(__FILE__) + '/../spec_helper'

describe Waitlist do
  describe "as a model" do
    it "should belong to a location" do
      Waitlist.reflect_on_association(:location).should_not be_nil
    end
    
    it "should have many guests" do
      Waitlist.reflect_on_association(:guests).should_not be_nil
    end
  end

  describe 'being created' do
    it "should not be valid without a location" do
      Waitlist.new(:location_id => nil).valid?.should_not be_true
    end
  end
end