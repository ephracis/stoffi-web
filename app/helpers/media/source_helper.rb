module Media::SourceHelper
  
  def source_types_for_select(selected)
    array = %w(youtube soundcloud lastfm url).map do |type|
      [Media::Source.human_name(type), type]
    end
    options_for_select array, selected
  end
  
end