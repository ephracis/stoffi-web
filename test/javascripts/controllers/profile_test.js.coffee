describe "ProfileController", ->
  
  $controller = null
  $location = null
  $scope = null
  $window = null
  
  beforeEach module('Stoffi')
  
  beforeEach inject( (_$controller_, _$rootScope_, _$location_, _$window_) ->
    $controller = _$controller_
    $scope = _$rootScope_.$new()
    $location = _$location_
    $window = _$window_
  )
  
  describe '$scope.getTab', ->
    it "should default to 'playlists'", ->
      controller = $controller('ProfileController', { $scope: $scope })
      expect($scope.getTab()).to.equal('playlists')
      
    it "should parse /username/toplists to 'toplists'", ->
      controller = $controller('ProfileController', { $scope: $scope })
      $location.path '/username/toplists'
      expect($scope.getTab()).to.equal('toplists')
      
    it "should parse /username/activity to 'activity'", ->
      controller = $controller('ProfileController', { $scope: $scope })
      $location.path '/username/activity'
      expect($scope.getTab()).to.equal('activity')
      
    it "should parse /username/listens to 'listens'", ->
      controller = $controller('ProfileController', { $scope: $scope })
      $location.path '/username/listens'
      expect($scope.getTab()).to.equal('listens')
      
  describe '$scope.setTab', ->
      
    it "should set to 'playlists'", ->
      controller = $controller('ProfileController', { $scope: $scope })
      $scope.slug = 'username'
      $scope.name = 'Foo Bar'
      $scope.setTab 'playlists'
      expect($location.path()).to.equal '/username'
      expect($scope.tab).to.equal 'playlists'
      expect($window.document.title).to.equal 'Playlists - Foo Bar - Stoffi'
      
    it "should set to 'toplists'", ->
      controller = $controller('ProfileController', { $scope: $scope })
      $scope.slug = 'username'
      $scope.name = 'Foo Bar'
      $scope.setTab 'toplists'
      expect($location.path()).to.equal '/username/toplists'
      expect($scope.tab).to.equal 'toplists'
      expect($window.document.title).to.equal 'Toplist - Foo Bar - Stoffi'
      
    it "should not set to ''", ->
      controller = $controller('ProfileController', { $scope: $scope })
      $scope.slug = 'username'
      $scope.name = 'Foo Bar'
      $scope.setTab 'toplists'
      $scope.setTab ''
      expect($location.path()).to.equal '/username/toplists'
      expect($scope.tab).to.equal 'toplists'
      expect($window.document.title).to.equal 'Toplist - Foo Bar - Stoffi'
      
    it "should not set to 'foobar'", ->
      controller = $controller('ProfileController', { $scope: $scope })
      $scope.slug = 'username'
      $scope.name = 'Foo Bar'
      $scope.setTab 'toplists'
      $scope.setTab 'foobar'
      expect($location.path()).to.equal '/username/toplists'
      expect($scope.tab).to.equal 'toplists'
      expect($window.document.title).to.equal 'Toplist - Foo Bar - Stoffi'
      
    it "should not set to null", ->
      controller = $controller('ProfileController', { $scope: $scope })
      $scope.slug = 'username'
      $scope.name = 'Foo Bar'
      $scope.setTab 'toplists'
      $scope.setTab null
      expect($location.path()).to.equal '/username/toplists'
      expect($scope.tab).to.equal 'toplists'
      expect($window.document.title).to.equal 'Toplist - Foo Bar - Stoffi'
      
  describe 'info', ->
    it 'should get user info', ->
      controller = $controller('ProfileController', { $scope: $scope })
      response = {
        data: {
          name: 'Foo Bar',
          slug: 'foobar',
          admin: true,
          locked: false
        }
      }
      $scope.loadUser response
      expect($scope.name).to.equal 'Foo Bar'
      expect($scope.slug).to.equal 'foobar'
      expect($scope.isAdmin).to.equal true
      expect($scope.isLocked).to.equal false
      
    it 'should get user info without admin info', ->
      controller = $controller('ProfileController', { $scope: $scope })
      response = {
        data: {
          name: 'Foo Bar',
          slug: 'foobar'
        }
      }
      $scope.loadUser response
      expect($scope.name).to.equal 'Foo Bar'
      expect($scope.slug).to.equal 'foobar'
      expect($scope.isAdmin).to.equal undefined
      expect($scope.isLocked).to.equal undefined