require "test_helper"

class ParentForm < OnForm::Form
  expose :customer => %i(name phone_number)

  def initialize(customer)
    @customer = customer
  end
end

class ChildForm < ParentForm
  expose :customer => %i(email)
  expose :dummy => %i(dummyattr)
end

class CustomerHouseListingForm < OnForm::Form
  expose :house => %i(street_number street_name city),
         :vendor => %i(name phone_number)

  def initialize(house)
    @house = house
    @vendor = house.vendor
  end
end

class AdminHouseListingForm < CustomerHouseListingForm
  expose :house => %i(listing_approved)
end

describe "form inheritance" do
  it "exposes parent attributes and new attributes in the child" do
    ChildForm.exposed_attributes.keys.must_equal %i(customer dummy)
    ChildForm.exposed_attributes[:customer].sort.must_equal %i(name phone_number email).sort
    ChildForm.exposed_attributes[:dummy].sort.must_equal %i(dummyattr)
  end

  it "doesn't exposes new child attributes in the parent" do
    ParentForm.exposed_attributes.keys.must_equal %i(customer)
    ParentForm.exposed_attributes[:customer].sort.must_equal %i(name phone_number).sort
  end

  it "saves attributes exposed in both parent and child forms" do
    Customer.delete_all
    House.delete_all
    @vendor = Customer.create!(name: "Test User", email: "test@example.com", phone_number: "123-4567")
    @house = House.create!(:vendor => @vendor, :street_number => "8/90", :street_name => "Main Street", :city => "Townsville")
    @house_listing_form = AdminHouseListingForm.new(@house)
    @house_listing_form.update!(:street_number => "90/8", :listing_approved => true)
    @house.reload.street_number.must_equal "90/8"
    @house.reload.listing_approved.must_equal true
  end
end
