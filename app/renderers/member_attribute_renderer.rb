class MemberAttributeRenderer < ::Hyrax::Renderers::AttributeRenderer
  def render
    markup = ''
    results = []

    return markup if !values.present? && !options[:include_empty]

    component(values, options[:type], 0, results)
    results.each do |result|
      markup << result
    end
    markup.html_safe
  end

  private

    def contextual_path(presenter, parent_presenter)
      ::Hyrax::ContextualPath.new(presenter, parent_presenter).show
    end

    def member_value(file, type, values, level)
      case type.to_s
      when 'title'
        list(link_to(file.title.first, contextual_path(file, @presenter)), level)
      when 'permission'
        "#{file.permission_badge}<br/>"
      when 'filename'
        list(link_to(file.link_name, contextual_path(file, values)), level)
      end
    end

    def component(values, type, level, results = [])
      if values.class == FileSetPresenter || values.class == Hyrax::FileSetPresenter || values.member_presenters.blank?
        level += 1 if values.class == Hyrax::WorkShowPresenter
        results << member_value(values, options[:type], @presenter, level)
      else
        level += 1
        values.member_presenters.each do |file|
          case file
          when Hyrax::FileSetPresenter
            file = values if type == 'title'
            results << member_value(file, type, @presenter, level)
          else
            component(file, type, level, results)
          end
        end
      end
      results
    end

    def list(link_name, level)
      list_value = ''
      (1..level).each do
        list_value += '<ul class="component_list"><li>'
      end
      list_value += link_name.to_s
      (1..level).each do
        list_value += '</li></ul>'
      end
      list_value
    end
end
