FactoryGirl.define do
  factory :location_image do
    image Rack::Test::UploadedFile.new(File.open(File.join(Rails.root, '/spec/fixtures/images/test_img.jpg')))
    association :location, factory: :location_test, timezone: 'America/Chicago', country: 'USA', state: 'Texas'
    # association :user, factory: :create_user # TODO check if there has to be an association
  end
end
