require "rails_helper"

RSpec.describe JsonApiSortParams do
  let!(:controller) { Class.new { include JsonApiSortParams }.new }

  it "returns a default sort order if there are no sorting params" do
    params = controller.sort_params(
      "",
      allowed_params: [:created_at],
      default_sort: { created_at: :desc },
    )
    expect(params).to eq({ created_at: :desc })
  end

  it "filters out non-allowed params", :aggregate_failures do
    params = controller.sort_params(
      "-created_at,updated_at",
      allowed_params: [:updated_at],
      default_sort: { created_at: :desc },
    )
    expect(params).not_to have_key(:created_at)
    expect(params).to have_key(:updated_at)
  end

  it "generates a sort params hash" do
    params = controller.sort_params(
      "created_at,-updated_at",
      allowed_params: %i[created_at updated_at],
      default_sort: { created_at: :desc },
    )
    expect(params).to eq({ created_at: :asc, updated_at: :desc })
  end

  it "sorts the params in the correct order" do
    params = controller.sort_params(
      "-updated_at,created_at",
      allowed_params: %i[created_at updated_at],
      default_sort: { created_at: :desc },
    )
    expect(params.to_a).to eq([%i[created_at asc], %i[updated_at desc]])
  end
end