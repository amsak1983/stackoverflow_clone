class FileAttachmentValidator < ActiveModel::Validator
  ALLOWED_TYPES = %w[
    image/jpeg image/png image/gif
    application/pdf
    text/plain
    application/msword application/vnd.openxmlformats-officedocument.wordprocessingml.document
    application/vnd.ms-excel application/vnd.openxmlformats-officedocument.spreadsheetml.sheet
  ].freeze

  MAX_SIZE = 10.megabytes

  def validate(record)
    return unless record.files.attached?

    record.files.each do |file|
      validate_file_type(record, file)
      validate_file_size(record, file)
    end
  end

  private

  def validate_file_type(record, file)
    return if file.content_type.in?(ALLOWED_TYPES)
    file.purge
    record.errors.add(:files, "must be images, PDFs, text or office documents")
  end

  def validate_file_size(record, file)
    return if file.blob.byte_size <= MAX_SIZE
    file.purge
    record.errors.add(:files, "must not exceed 10MB")
  end
end
