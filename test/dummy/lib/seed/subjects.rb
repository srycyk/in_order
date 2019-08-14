
module Seed
  class Subjects
    MAX = Rails.env.test? ? 6 : 12

    def call(max=nil)
      max ||= MAX

      subject = nil

      ordinals.map.with_index do |ordinal, index|
        break subject if index + 1 > max

        name = "#{ordinal} subject"

        subject = Subject.find_or_create_by name: name
      end
    end

    private

    def ordinals
      (1..MAX).map {|int| int.to_s + int.ordinal }
    end
  end
end

