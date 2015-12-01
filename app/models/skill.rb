class Skill < ActiveRecord::Base
  enum status: %w(Bad Half-bad Fantastic)
end
