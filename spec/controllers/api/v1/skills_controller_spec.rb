require "rails_helper"

RSpec.describe Api::V1::SkillsController do
  fixtures :skills

  it "responds with json" do
    get :index, format: :json
    expect(response.status).to eq 200
  end

  describe "#index" do
    it "returns all skills" do
      get :index, format: :json

      expect(json_response.count).to eq Skill.all.count
    end
  end

  describe "#create" do
    it "creates a new skill" do
      skill = {name: "Playing piano", details: "Every day"}
      post :create, skill: skill, format: :json

      expect(response.status).to eq 201
      expect(json_response["id"]).to eq Skill.last.id
      expect(json_response["name"]).to eq Skill.last.name
    end
  end

  describe "#destroy" do
    it "deletes a skill" do
      count = Skill.all.count
      delete :destroy, id: Skill.last.id, format: :json

      expect(response.status).to eq 204
      expect(count - 1).to eq Skill.all.count
    end
  end

  describe "#update" do
    it "updates a skill" do
      skill = {name: "Updated name"}
      put :update, id: Skill.first.id, skill: skill, format: :json

      expect(response.status).to eq 200
      expect(Skill.first.name).to eq "Updated name"
    end
  end
end
