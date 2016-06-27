describe "MusicController", ->
  
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
  
  describe '$scope.getList', ->
    it "should default to 'playlists'", ->
      controller = $controller('MusicController', { $scope: $scope })
      expect($scope.getList()).to.equal('playlists')
      
    it "should parse /artists to 'artists'", ->
      controller = $controller('MusicController', { $scope: $scope })
      $location.path '/artists'
      expect($scope.getList()).to.equal('artists')
      
    it "should parse /albums/foobar to 'albums'", ->
      controller = $controller('MusicController', { $scope: $scope })
      $location.path '/albums'
      expect($scope.getList()).to.equal('albums')
      
    it "should parse /songs to 'songs'", ->
      controller = $controller('MusicController', { $scope: $scope })
      $location.path '/songs'
      expect($scope.getList()).to.equal('songs')
      
    it "should parse /events to 'events'", ->
      controller = $controller('MusicController', { $scope: $scope })
      $location.path '/events'
      expect($scope.getList()).to.equal('events')
      
    it "should parse /genres to 'genres'", ->
      controller = $controller('MusicController', { $scope: $scope })
      $location.path '/genres'
      expect($scope.getList()).to.equal('genres')
      
    it "should parse /playlists to 'playlists'", ->
      controller = $controller('MusicController', { $scope: $scope })
      $location.path '/playlists'
      expect($scope.getList()).to.equal('playlists')
      
    it "should parse /foobar to 'playlists'", ->
      controller = $controller('MusicController', { $scope: $scope })
      $location.path '/foobar'
      expect($scope.getList()).to.equal('playlists')
      
    it "should parse / to 'playlists'", ->
      controller = $controller('MusicController', { $scope: $scope })
      $location.path '/'
      expect($scope.getList()).to.equal('playlists')
      
    it "should parse '' to 'playlists'", ->
      controller = $controller('MusicController', { $scope: $scope })
      $location.path ''
      expect($scope.getList()).to.equal('playlists')
  
  describe '$scope.setList', ->
      
    it "should set to 'artists'", ->
      controller = $controller('MusicController', { $scope: $scope })
      $scope.setList 'artists'
      expect($location.path()).to.equal '/artists'
      expect($scope.list).to.equal 'artists'
      expect($window.document.title).to.equal 'Popular artists - Stoffi'
      
    it "should set to 'albums'", ->
      controller = $controller('MusicController', { $scope: $scope })
      $scope.setList 'albums'
      expect($location.path()).to.equal '/albums'
      expect($scope.list).to.equal 'albums'
      expect($window.document.title).to.equal 'Popular albums - Stoffi'
      
    it "should set to 'songs'", ->
      controller = $controller('MusicController', { $scope: $scope })
      $scope.setList 'songs'
      expect($location.path()).to.equal '/songs'
      expect($scope.list).to.equal 'songs'
      expect($window.document.title).to.equal 'Popular songs - Stoffi'
      
    it "should set to 'events'", ->
      controller = $controller('MusicController', { $scope: $scope })
      $scope.setList 'events'
      expect($location.path()).to.equal '/events'
      expect($scope.list).to.equal 'events'
      expect($window.document.title).to.equal 'Upcoming events - Stoffi'
      
    it "should set to 'genres'", ->
      controller = $controller('MusicController', { $scope: $scope })
      $scope.setList 'genres'
      expect($location.path()).to.equal '/genres'
      expect($scope.list).to.equal 'genres'
      expect($window.document.title).to.equal 'Popular genres - Stoffi'
      
    it "should set to 'playlists'", ->
      controller = $controller('MusicController', { $scope: $scope })
      $scope.setList 'playlists'
      expect($location.path()).to.equal '/playlists'
      expect($scope.list).to.equal 'playlists'
      expect($window.document.title).to.equal 'Popular playlists - Stoffi'
      
    it "should set to 'songs'", ->
      controller = $controller('MusicController', { $scope: $scope })
      $scope.setList 'songs'
      expect($location.path()).to.equal '/songs'
      expect($scope.list).to.equal 'songs'
      expect($window.document.title).to.equal 'Popular songs - Stoffi'
      
    it "should not set to ''", ->
      controller = $controller('MusicController', { $scope: $scope })
      $scope.setList 'songs'
      $scope.setList ''
      expect($location.path()).to.equal '/songs'
      expect($scope.list).to.equal 'songs'
      expect($window.document.title).to.equal 'Popular songs - Stoffi'
      
    it "should not set to 'foobar'", ->
      controller = $controller('MusicController', { $scope: $scope })
      $scope.setList 'songs'
      $scope.setList 'foobar'
      expect($location.path()).to.equal '/songs'
      expect($scope.list).to.equal 'songs'
      expect($window.document.title).to.equal 'Popular songs - Stoffi'
      
    it "should not set to null", ->
      controller = $controller('MusicController', { $scope: $scope })
      $scope.setList 'songs'
      $scope.setList null
      expect($location.path()).to.equal '/songs'
      expect($scope.list).to.equal 'songs'
      expect($window.document.title).to.equal 'Popular songs - Stoffi'