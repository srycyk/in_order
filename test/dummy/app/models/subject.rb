
class Subject < ApplicationRecord
  def to_s
    name
  end

  alias value to_s

  def as_json(*)
    super except: %i(created_at updated_at),
          methods: :value
  end
end

