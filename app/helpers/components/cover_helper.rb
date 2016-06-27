module Components::CoverHelper
  
  # Construct a cover. Used on resource pages to display image, heading and
  # some meta data for the resource.
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
  def cover_for(record, options = {}, &block)
    
    raise ArgumentError, "Missing block" unless block_given?
    
    # default options
    options = {
      
    }.merge(options)
    
    builder = CoverBuilder.new(self, record, options)
    builder.content = capture(builder, &block)
    
    content_tag :div, class: :cover do
      
      image = cover_image builder
      content = cover_content builder
      buttons = cover_buttons builder
      
      (image+content+buttons).html_safe
      
    end
  end
  
  def cover_image(builder)
    
    klass = builder.record.class.name.demodulize.parameterize
    
    content_tag :div, class: 'cover-image' do
      content_tag :div, class: 'cover-image-wrapper' do
        image = image_tag image_for(builder.record), data: { thumbnail: '' }
        if current_user.admin?
          edit = content_tag :div, class: :edit do
            link_to send("#{klass}_images_path", builder.record),
                         target: '_self' do
              icon = content_tag :span, '', class: 'fa fa-fw fa-pencil'
              text = t('media.images.edit.link')
              (icon + text).html_safe
            end
          end
          image = (image + edit).html_safe
        end
      end
    end
  end
  
  def cover_content(builder)
    content_tag :div, class: 'cover-content' do
      subheading = if builder.subheading.present?
        content_tag :h4, class: 'cover-subtitle' do
          builder.subheading
        end
      else
        ''
      end
      heading = content_tag :h1, builder.title, class: 'cover-title'
      (subheading + heading + builder.content).html_safe
    end
  end
  
  def cover_buttons(builder)
    content_tag :div, class: 'cover-buttons' do
      builder.buttons
    end
  end
  
  # The builder of a cover.
  #
  # This is yielded to the block of `cover_for`. Example:
  #
  #     = cover_for resource do |m|
  #       / m is a CoverBuilder
  #
  class CoverBuilder
    
    attr_accessor :buttons, :parent, :record, :content, :title, :subheading
  
    delegate :capture, :content_tag, :url_for, to: :parent
    
    # Create a new builder.
    def initialize(parent, record, options = {})
      self.parent = parent
      self.record = record
      self.title = record.to_s
    end
    
    # Set the buttons block.
    def buttons(&block)
      return @buttons unless block_given?
      @buttons = capture(&block)
    end
    
    # Set the subheading block.
    def subheading(&block)
      return @subheading unless block_given?
      @subheading = capture(&block)
    end
    
  end
  
end