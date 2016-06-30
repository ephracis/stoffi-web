# frozen_string_literal: true
json.array!(@suggestions) do |suggestion|
  json.extract! suggestion, :value

  # include these keys if they exists
  [:id, :score].each do |k|
    json.extract! suggestion, k if suggestion[k].present?
  end
end
