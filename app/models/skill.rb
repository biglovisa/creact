class Skill < ActiveRecord::Base
  enum level: [:bad, :halfbad, :fantastic]
end
