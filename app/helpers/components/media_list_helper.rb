module Components::MediaListHelper
  
  # Construct a list of media resources.
  #
  # Options:
  #
  # `:show_empty`
  #
  # If `true` then the list will be displayed even if `collection` is empty,
  # though with a message. Default: `true`.
  #
  # `:empty_message`
  #
  # The message to display if the collection is empty and `:show_empty` is set
  # to `true`.
  #
  def media_list(collection, title = nil, options = {})
    
    # default options
    options = {
      show_empty: true,
      empty_message: t('components.media_list.empty'),
      collection: collection,
      title: title,
      heading: :outside
    }.merge(options)
    
    return unless collection.present? or options[:show_empty]
    
    render partial: 'shared/media_list', locals: options
  end
  
  # Construct a media resource that is to be housed inside a media list.
  # 
  # Options:
  #
  # `:badge` 
  # If set to true then a badge will be displayed next to the heading.
  #
  # Helpers:
  #
  # `title`
  # Set the title of the media object.
  #
  # `buttons`
  # Set the buttons block.
  #
  # Example:
  #
  #     = media_list_item @song do |m|
  #       - m.title @song.title, badge: true
  #    
  #       - m.buttons do
  #         = %span.btn.btn-link My Button
  #         = %span.btn.btn-link Another Button
  #     
  #       This is my content, displayed under the title.
  #
  def media_list_item(record, options = {}, &block)
    raise ArgumentError, "Missing block" unless block_given?
    options[:class] ||= ''
    options[:class] += ' media resource'
    builder = MediaListItemBuilder.new(self, record, options)
    builder.content = capture(builder, &block)
    content_tag :div, options do
      thumbnail = media_list_item_thumbnail builder
      body = media_list_item_body builder
      buttons = media_list_item_buttons builder
      (thumbnail + body + buttons)
    end
  end
  
  private
  
  # Construct the thumbnail for a media object.
  def media_list_item_thumbnail(builder)
    # TODO: move into models as #symbol.
    symbol = case builder.record
    when Media::Playlist then 'bars'
    when Media::Song then 'music'
    else 'music' end
    
    content_tag :div, class: 'media-left' do
      
      a_options = { target: '_self' }.merge(builder.image_link_options || {})
      img_options = builder.image_options || {}
      img_options[:class] = "#{img_options[:class]} media-object"
      
      link_to builder.url, a_options do
        if builder.image_url.present?
          image_tag builder.image_url, img_options
        else
          image_tag_for builder.record, symbol, img_options
        end
      end
    end
  end
  
  # Construct the body of a media object.
  def media_list_item_body(builder)
    content_tag :div, class: 'media-body' do
      heading = media_list_item_heading(builder)
      (heading + builder.content).html_safe
    end
  end
  
  # Construct the buttons panel for a media object.
  def media_list_item_buttons(builder)
    content_tag :div, class: 'media-right' do
      content_tag :div, class: 'buttons' do
        builder.buttons
      end
    end
  end
  
  # Construct the heading, with an optional badge, for a media object.
  def media_list_item_heading(builder)
    content_tag :h5, class: 'media-heading' do
      link = link_to builder.title, builder.url,
        target: '_self', class: 'media-title'
      
      if builder.badge
        resource_name = builder.record.class.name.demodulize.tableize
        badge_str = "media.#{resource_name}.badge"
        badge_class = "badge badge-#{resource_name.singularize}"
        link += (" "+content_tag(:span, t(badge_str), class: badge_class)).
          html_safe
      end
      
      link.html_safe
    end
  end
  
  # The builder of a media list item.
  #
  # This is yielded to the block of `media_list_item`. Example:
  #
  #     = media_list_item do |m|
  #       / m is a MediaListItemBuilder
  #
  class MediaListItemBuilder
    
    attr_accessor :record, :badge, :title, :buttons, :content, :parent, :url,
      :image_url, :image_options, :image_link_options
  
    delegate :capture, :content_tag, :url_for, to: :parent
    
    # Create a new builder.
    def initialize(parent, record, options = {})
      self.parent = parent
      self.record = record
      self.url = options[:url] || url_for(record)
      self.title = record.to_s
    end
    
    # Set the title of the media object.
    #
    # Options:
    #
    # `:badge`
    # If set to `true` then a badge will be displayed next to the title.
    #
    def title(title = nil, options = {})
      return @title unless title.present?
      self.badge = options[:badge]
      self.title = title
    end
    
    # Set the buttons block.
    def buttons(&block)
      return @buttons unless block_given?
      @buttons = capture(&block)
    end
    
    # Set the image of the media object.
    def image(image_url, options = {})
      self.image_url = image_url
      self.image_link_options = options.delete(:link)
      self.image_options = options
    end
    
  end
  
end