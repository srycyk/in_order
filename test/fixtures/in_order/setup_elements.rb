
require 'seed/owners'
require 'seed/subjects'

#require_relative 'fixtures/setup_functions'
require_relative 'setup_functions'

module SetupElements
  include SetupFunctions

  def self.included(base)
    base.instance_eval do
      let(:owner) { Seed::Owners.new.call 1 }

      let(:subjects) { Seed::Subjects.new.call }

      let(:scope) { 'tele' }
    end
  end
end

