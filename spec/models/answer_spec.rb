require 'rails_helper'

RSpec.describe Answer, type: :model do
  # Тестирование связей
  it { should belong_to(:question) }
  
  # Тестирование валидаций
  it { should validate_presence_of(:body) }
end
