
require 'test_helper'

describe InOrder::Aux::PolyFind do
  def find(*args)
    InOrder::Aux::PolyFind.new(*args).call
  end

  def model_key(model)
    return model.class, model.to_param
  end

  def models(count=1)
    @models ||= begin
      (1..count).map {|number| Subject.create name: "Model #{number}" }
    end
  end

  it "finds model" do
    model = find(model_key models.first)

    assert_equal models.first, model
  end

  it "finds models" do
    models = models(2)

    found_models = models.map {|model| find(model_key model) }

    assert_equal models, found_models
  end
end

