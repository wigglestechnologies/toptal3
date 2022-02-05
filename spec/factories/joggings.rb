FactoryBot.define do
  factory :jogging do
    date {DateTime.now.to_date.strftime("%d/%m/%Y")}
    lon {13}
    lat {13}
    distance {3000}
    duration {"01:00"}
  end
end
