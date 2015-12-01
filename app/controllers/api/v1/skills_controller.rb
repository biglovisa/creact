class Api::V1::SkillsController < Api::V1::BaseController
  def index
    respond_with Skill.all
  end

  def create
    respond_with :api, :v1, Skill.create(skill_params)
  end

  def destroy
    respond_with Skill.destroy(params[:id])
  end

  def update
    respond_with Skill.update(params[:id], skill_params)
  end

 private

  def skill_params
    params.require(:skill).permit(:name, :details, :level)
  end
end
