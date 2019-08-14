
module Seed
  class Owners
    def call(max=nil)
      max ||= names.size

      owner = nil

      names.map.with_index do |name, index|
        break owner if index + 1 > max

        name = "Owner #{name}"

        owner = Owner.find_or_create_by name: name
      end
    end

    private

    def names
      %w(occupier driver)
    end
  end
end
