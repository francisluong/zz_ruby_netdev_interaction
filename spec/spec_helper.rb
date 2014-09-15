require 'rspec'

RSpec.configure do |config|
  def random_name
    ('a'..'z').to_a.sample(5).join
  end
end