require 'rails_helper'

xdescribe HourOperation do
  it 'checks if the current time is within the hours of operation' do
    hour_operation = create(:greater_lesser_valid_hours)
    expect(hour_operation.is_open?).to be_truthy

    hour_operation = create(:greater_lesser_invalid_hours)
    expect(hour_operation.is_open?).to be_falsy

    hour_operation = create(:lesser_greater_valid_hours)
    expect(hour_operation.is_open?).to be_truthy

    hour_operation = create(:lesser_greater_invalid_hours)
    expect(hour_operation.is_open?).to be_falsy
  end
end
