# Copyright (c) 2015 Simplare

# Helper methods for the tests of backends.
module Backends::TestHelpers
  
  # Remove the keys from the hash which are used to create or update a source
  # association.
  def clean_resource_hash!(hash)
    hash = clean_resource_hash(hash)
  end
  
  # Remove the keys from the hash which are used to create or update a source
  # association.
  def clean_resource_hash(hash)
    hash.reject { |k,v| k == :source }
  end
  
  # Stub an OAuth request.
  #
  # - `path`  
  #   The path of the URL request as a string.
  # 
  # - `response`  
  #   The returned value when `#parsed` is called on the object
  #   that is returned from the request.
  #
  # - `options`  
  #   A hash of optional parameters:
  #   `:method` (the http verb), `:params` (query parameters).
  def stub_oauth(path, response, options = {})
    options[:method] ||= :get
    resp = Object.new
    
    # expect method
    meth = OAuth2::AccessToken.any_instance.expects(options[:method])
    
    # expect arguments
    if options[:params]
      meth = meth.with(path, { params: options[:params] })
    else
      meth = meth.with(path)
    end
    
    # return response and expect it to be parsed
    meth.returns(resp)
    resp.expects(:parsed).returns(response)
  end
  
end