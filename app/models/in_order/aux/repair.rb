
module InOrder
  module Aux
    class Repair
      attr_accessor :dry_run, :owners, :elements
      alias dry_run? dry_run

      def initialize(_dry_run=false, dry_run: _dry_run)
        self.dry_run = dry_run

        self.owners = []
        self.elements = []
      end

      def call
        InOrder::Element.transaction do
          unreferenced :owner do |type_id|
            owners << type_id * '-'

            InOrder::Element.by_owner_keys(*type_id).delete_all unless dry_run?
          end

          unlinked :subject do |element|
            elements << element

            InOrder::Remove.new(element).call unless dry_run?
          end
        end

        return owners, elements
      end

      class << self
        def ic
          owners, elements = new(true).call

          puts show 'Owners', owners
          puts show 'Elements', elements
        end

        def show(name, list)
          out = name << ' ' << list.size.to_s << "\n"

          out << list.map(&:to_param) * " " << "\n"
        end
      end

      def unlinked(name)
        unreferenced(name).map do |type_id|
          InOrder::Element.by_subject_keys(*type_id).first.tap do |element|
            yield element if block_given?
          end
        end
      end

      def unreferenced(name)
        linked(name).reject do |(type, id)|
          type.constantize.where(id: id).exists?
        end
      end

      def linked(name)
        fields = [ :"#{name}_type", :"#{name}_id" ]

        InOrder::Element.select(*fields).distinct.pluck(*fields)
      end

    end
  end
end

