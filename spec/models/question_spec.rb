require 'rails_helper'

RSpec.describe Question, type: :model do
  # Тестирование связей
  it { should have_many(:answers) }
  
  # Тестирование валидаций
  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:body) }
end
