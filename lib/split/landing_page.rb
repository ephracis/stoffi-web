# frozen_string_literal: true
# Decides on the landing page for a given request.
class ABTestLanding
  def self.page_for(request)
    return 'about' if Rails.env.test?
    trial = Split::Trial.new(
      experiment: Split::ExperimentCatalog.find_or_create('landing_page',
                                                          'about',
                                                          'music',
                                                          'search',
                                                          'dashboard'),
      user: Split::Persistence::RedisAdapter.new(nil, request.remote_ip)
    )
    trial.choose!
    raise trial.alternative.name.to_s
  end
end

# Wrapper around `ABTestLanding` for constraining a route in `routes.rb`.
class RootConstraintAbout
  def matches?(request)
    ABTestLanding.page_for(request) == 'about'
  end
end

# Wrapper around `ABTestLanding` for constraining a route in `routes.rb`.
class RootConstraintMusic
  def matches?(request)
    ABTestLanding.page_for(request) == 'music'
  end
end

# Wrapper around `ABTestLanding` for constraining a route in `routes.rb`.
class RootConstraintSearch
  def matches?(request)
    ABTestLanding.page_for(request) == 'search'
  end
end

# Wrapper around `ABTestLanding` for constraining a route in `routes.rb`.
class RootConstraintDashboard
  def matches?(request)
    ABTestLanding.page_for(request) == 'dashboard'
  end
end
