require File.dirname(__FILE__) + '/../spec_helper'

describe Guest do
  describe "as a model" do
    it "should belong to a waitlist" do
      Guest.reflect_on_association(:waitlist).should_not be_nil
    end

    it "should have defined states as: waiting, paged, arrived, noshow" do
      defined_states = [:waiting, :paged, :arrived, :noshow]
      Guest.aasm_states.map(&:name).should eql(defined_states)
    end
  end

  describe "being created" do
    it "requires waitlist" do
      lambda do
        g = create_guest(:waitlist_id => nil)
        g.errors.on(:waitlist_id).should_not be_nil
      end.should_not change(Guest, :count)
    end
    
    it "requires note" do
      lambda do
        g = create_guest(:note => nil)
        g.errors.on(:note).should_not be_nil
      end.should_not change(Guest, :count)
    end
    
    it "requires wait_hours" do
      lambda do
        g = create_guest(:wait_hours => nil)
        g.errors.on(:wait_hours).should_not be_nil
      end.should_not change(Guest, :count)
    end
    
    it "requires wait_minutes" do
      lambda do
        g = create_guest(:wait_minutes => nil)
        g.errors.on(:wait_minutes).should_not be_nil
      end.should_not change(Guest, :count)
    end
    
    it "requires phone number" do
      lambda do
        g = create_guest(:phone => nil)
        g.errors.on(:phone).should_not be_nil
      end.should_not change(Guest, :count)
    end
    
    it "requires phone number as a numeric value" do
      lambda do
        g = create_guest(:phone => 'NUMBER1234')
        g.errors.on(:phone).should_not be_nil
      end.should_not change(Guest, :count)
    end
  end

  protected
  def create_guest(options={})
    @guest = Guest.create({ :note => "Bob's birthday", :wait_hours => 0, :wait_minutes => 10, :phone => '12345678910' }.merge(options))
  end
end