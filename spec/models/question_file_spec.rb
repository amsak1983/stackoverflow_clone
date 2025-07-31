require 'rails_helper'

RSpec.describe Question, type: :model do
  describe 'file attachments' do
    let(:user) { create(:user) }
    let(:question) { build(:question, user: user) }
    let(:pdf_file) { fixture_file_upload("#{Rails.root}/spec/fixtures/files/test.pdf", 'application/pdf') }
    let(:text_file) { fixture_file_upload("#{Rails.root}/spec/fixtures/files/test.txt", 'text/plain') }
    let(:large_file) { fixture_file_upload("#{Rails.root}/spec/fixtures/files/large_file.pdf", 'application/pdf') }
    let(:invalid_file) { fixture_file_upload("#{Rails.root}/spec/fixtures/files/invalid.exe", 'application/octet-stream') }

    before do
      # Stub blob.byte_size method to simulate large files
      allow_any_instance_of(ActiveStorage::Blob).to receive(:byte_size).and_return(1.megabyte)
      allow_any_instance_of(ActiveStorage::Blob).to receive(:byte_size).with(no_args) do |blob|
        if blob.filename.to_s =~ /large_file/
          11.megabytes # Exceeds 10MB limit
        else
          1.megabytes # Valid size
        end
      end
    end

    it 'can have attached files' do
      question.files.attach(pdf_file)
      question.files.attach(text_file)
      expect(question.files).to be_attached
      expect(question.files.count).to eq(2)
    end

    it 'validates file type' do
      question.files.attach(invalid_file)
      expect(question).not_to be_valid
      expect(question.errors[:files]).to include('must be images, PDFs, text or office documents')
    end

    it 'validates file size' do
      question.files.attach(large_file)
      expect(question).not_to be_valid
      expect(question.errors[:files]).to include('must not exceed 10MB')
    end
  end
end
