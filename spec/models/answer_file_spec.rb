require 'rails_helper'

RSpec.describe Answer, type: :model do
  describe 'файловые вложения' do
    let(:user) { create(:user) }
    let(:question) { create(:question, user: user) }
    let(:answer) { build(:answer, question: question, user: user) }
    let(:pdf_file) { fixture_file_upload("#{Rails.root}/spec/fixtures/files/test.pdf", 'application/pdf') }
    let(:text_file) { fixture_file_upload("#{Rails.root}/spec/fixtures/files/test.txt", 'text/plain') }
    let(:large_file) { fixture_file_upload("#{Rails.root}/spec/fixtures/files/large_file.pdf", 'application/pdf') }
    let(:invalid_file) { fixture_file_upload("#{Rails.root}/spec/fixtures/files/invalid.exe", 'application/octet-stream') }

    before do
      # Stub для метода blob.byte_size чтобы имитировать большой файл
      allow_any_instance_of(ActiveStorage::Blob).to receive(:byte_size).and_return(1.megabyte)
      allow_any_instance_of(ActiveStorage::Blob).to receive(:byte_size).with(no_args) do |blob|
        if blob.filename.to_s =~ /large_file/
          11.megabytes # Больше лимита в 10 МБ
        else
          1.megabytes # Подходящий размер
        end
      end
    end

    it 'может иметь прикрепленные файлы' do
      answer.files.attach(pdf_file)
      answer.files.attach(text_file)
      expect(answer.files).to be_attached
      expect(answer.files.count).to eq(2)
    end

    it 'проверяет тип файла' do
      answer.files.attach(invalid_file)
      expect(answer).not_to be_valid
      expect(answer.errors[:files]).to include('должны быть изображениями, PDF, текстом или офисными документами')
    end

    it 'проверяет размер файла' do
      answer.files.attach(large_file)
      expect(answer).not_to be_valid
      expect(answer.errors[:files]).to include('не должны превышать 10MB')
    end
  end
end
