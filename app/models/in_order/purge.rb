
module InOrder
  # Removes unwanted subjects from a list.
  # Identified (i.e. keyed) by an Owner and/or Scope.
  class Purge
    include Aux::VarKeys

    # +keep_last+ determines whether the first or last occurrence remains
    def call(keep_last: false)
      elements = get_elements

      elements.reverse! if keep_last

      traverse elements do |element, found_subjects, subject|
        Remove.new(element).call if found_subjects.include?(subject)
      end
    end
    alias uniq call

    def remove(*subjects, elements: get_elements)
      did_remove = false

      subjects.flatten! if Array === subjects.first

      traverse elements do |element|
        if subjects.include?(element.subject)
          Remove.new(element).call

          did_remove = true
        end
      end

      did_remove
    end

    def exists?(subject)
      InOrder::Element.has_subject?(keys) { subject }
    end

    def self.delete_by_subject(subject)
      InOrder::Element.transaction do
        InOrder::Element.by_subject(subject).each do |element|
          Remove.new(element).call
        end
      end
    end

    protected

    def traverse(elements)
      found_subjects = []

      InOrder::Element.transaction do
        elements.each do |element|
          subject = element.subject

          yield element, found_subjects, subject

          found_subjects << subject
        end
      end
    end

    private

    def get_elements
      Fetch.new(keys).elements
    end
  end
end

