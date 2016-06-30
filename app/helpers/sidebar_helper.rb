# frozen_string_literal: true
module SidebarHelper
  def section_block(title, options = {})
    content_tag 'section', options[:section] do
      concat content_tag('h2', title, options[:title])
      concat yield
    end
  end

  def toplist_section(resource, limit = 5)
    top = resource.top(limit: limit)
    return unless top && !top.empty?
    r = resource.table_name
    section_block t("side.#{r}") do
      content_tag('ul', class: 'vertical', data: { field: r }) do
        top.each do |x|
          concat content_tag('li', link_to(x.to_s, x), data:
            { resource: "#{r}_#{x.id}" })
        end
        concat content_tag('li', t("#{r}.empty"), data:
          { message: 'empty', field: r })
      end
    end
  end
end
