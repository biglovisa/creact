class SiteController < ApplicationController
  def index
    @skills = Skill.all
  end
end
