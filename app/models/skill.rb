class Skill < ActiveRecord::Base
  validates :name, presence: true

  enum level: [:bad, :halfbad, :fantastic]
end
