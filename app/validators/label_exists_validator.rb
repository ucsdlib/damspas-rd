class LabelExistsValidator < ActiveModel::Validator
  def validate(record)
    record.label.each do |value|
      record.errors[:label] << (options[:message] || "'#{value}' already exists!") unless !exists?(record, value) 
    end
  end

  def exists?(record, value)
    records = record.class.where(label: value)
    records.where(id: record.id).count != records.count
  end 
end
