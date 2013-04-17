FactoryGirl.define do
  factory :identity do
    name 'Identity'
    type 'PivotalTrackerIdentity'
    sequence(:api_key) {|i| i.to_s}
    sequence(:source_id) {|i| i.to_s}
    user { User.last || create(:user) }

    factory :git_hub_identity do
      type 'GitHubIdentity'
    end
  end
end
