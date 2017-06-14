# Class to provide select options language authority
class LanguageSelectService < Hyrax::QaSelectService
  def initialize
    super('languages')
  end

  def get_uri(label)
    auth = authority.all.select { |e| e[:label] == label }
    auth.first[:id] unless auth.empty?
  end

  def get_label(id)
    auth = authority.find(id)
    auth.nil? ? id : auth[:label]
  end
end
