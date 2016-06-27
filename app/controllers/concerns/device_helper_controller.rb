module DeviceHelperController
  extend ActiveSupport::Concern
  
  included do

    # Override the `device_path` and allow the user to be inferred from
    # the device.
    #
    # Example:
    #
    #     device_path @device # now works
    #     device_path @device.user, @device # still works
    #
    def device_path(user, device = nil, options = {})
      device = user if device.blank?
      super(device.user, device, options)
    end
    helper_method :device_path if respond_to? 'helper_method'

    # Override the `device_url` and allow the user to be inferred from
    # the device.
    #
    # Example:
    #
    #     device_url @device # now works
    #     device_url @device.user, @device # still works
    #
    def device_url(user, device = nil, options = {})
      playlist = user if playlist.blank?
      super(playlist.user, playlist, options)
    end
    helper_method :device_url if respond_to? 'helper_method'
  
  end
  
end