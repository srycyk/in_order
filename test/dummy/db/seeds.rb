
require 'seed/owners'
require 'seed/subjects'

  ActiveRecord::Base.transaction do
    Seed::Owners.new.call

    Seed::Subjects.new.call
  end

