
module ModelsFunctions
  NAME_TEMPLATE = 'Subject %s'

  def owner(refresh: false)
    @owner = nil if refresh

    @owner ||= create_owner
  end

  def subjects(count=2, start: 1)
    (start .. start+count).map do |number|
      Subject.create name: NAME_TEMPLATE % number
    end
  end

  def scope
    'stethe'
  end
end

