
module ControllerFunctions
  #JSON_HEADER = { 'CONTENT_TYPE' => 'application/json' }

  def json_parse(response)
    JSON.parse(response.respond_to?(:body) ? response.body : response)
  end

  def json_record(response, index=0, dig: nil)
    json_parse(response)[index].yield_self do |atts|
      dig ? atts.dig('value', *dig) : atts
    end
  end

  def assert_empty_array(json)
    assert_match(/^\s*\[\s*\]\s*/, json)
  end

  def request_options(**params)
    { as: :json, params: params }
  end
end
