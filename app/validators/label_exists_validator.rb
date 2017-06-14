class LabelExistsValidator < ActiveModel::Validator
  def validate(record)
    return unless exists?(record, record.label, record.alternate_label)
    alt_label_message = record.alternate_label.blank? ? '' : ' with alternate_label ' + record.alternate_label
    record.errors[:label] << (options[:message] || "'#{record.label}'#{alt_label_message} already exists!")
  end

  def exists?(record, label, alt_label = nil)
    records = record.class.where(label: label)
    records = records.where(alternate_label: alt_label) if alt_label.present?
    records.where(id: record.id).count != records.count
  end
end
