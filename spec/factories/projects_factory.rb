FactoryGirl.define do
  factory :project do
    sequence(:name) {|i| "Sample project nr #{i}"}
    source_name 'Pivotal Tracker'
    sequence(:source_identifier) {|i| i.to_s * 8}
  end
end