class AddPhysicalStateAndMailingStateToProfiles < ActiveRecord::Migration
  def change
    add_column :profiles, :physical_state, :string
    add_column :profiles, :mailing_state, :string
  end
end
