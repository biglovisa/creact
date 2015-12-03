require "rails_helper"

RSpec.describe "Skill", type: :model do
  it "should have a level that defaults to 0" do
    skill = Skill.new(name: "programming", details: "coding and such")
    expect(skill.level).to eq "bad"
  end

  it "is invalid without a name" do
    skill = Skill.new(details: "coding and such")
    expect(skill).to_not be_valid
  end
end
