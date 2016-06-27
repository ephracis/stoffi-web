describe "PlaylistController", ->
  
  $controller = null
  $scope = null
  $httpBackend = null
  
  fixture = [
    "<li><div class='media resource' data-resource-id='2'>song1</div></li>",
    "<li><div class='media resource' data-resource-id='3'>song2</div></li>",
    "<li><div class='media resource' data-resource-id='5'>song3</div></li>",
  ]
  
  beforeEach module('Stoffi')
  
  beforeEach inject( (_$controller_, _$rootScope_, _$httpBackend_) ->
    $controller = _$controller_
    $scope = _$rootScope_.$new()
    $httpBackend = _$httpBackend_
    controller = $controller('PlaylistController', { $scope: $scope })
  )
  
  describe '$scope.refreshSongs', ->
    it "should concatenate songs", ->
      $scope.songs = ['song1', 'song2']
      $scope.refreshSongs()
      # TODO: check html in $scope.songsHtml
      
  describe '$scope.beforeSongSearch', ->
    it "should set 'searchingForSongs'", ->
      $scope.beforeSongSearch()
      expect($scope.searchingForSongs).to.equal(true)
      
  describe '$scope.afterSongSearch', ->
    it "should unset 'searchingForSongs'", ->
      $scope.afterSongSearch()
      expect($scope.searchingForSongs).to.equal(false)
      
  describe '$scope.selectSongSearch', ->
    it "should add a song", ->
      song = "<div>mySong</div>"
      $scope.selectSongSearch(null, { item: { value: song }})
      expect($scope.songs[0]).to.equal(song)
      
  describe '$scope.removeSong', ->
    it "should remove a song", ->
      $scope.songs = fixture
      $scope.removeSong(2)
      expect($scope.songs.length).to.equal(2)
      expect($scope.songs[1]).to.equal(fixture[2])
      
  describe '$scope.init', ->
    it "should init followed, slug and user_slug", ->
      $scope.init { followed: true, slug: 'my-playlist', user_slug: 'alice' }
      expect($scope.followed).to.equal(true)
      expect($scope.slug).to.equal('my-playlist')
      expect($scope.user_slug).to.equal('alice')
      
    it "should set 'followed' to false by default", ->
      $scope.init { slug: 'my-playlist', user_slug: 'alice' }
      expect($scope.followed).to.equal(false)
      expect($scope.slug).to.equal('my-playlist')
      expect($scope.user_slug).to.equal('alice')
      
  describe '$scope.load', ->
    it "should load playlist", ->
      url = '/alice/my-playlist.js'
      $httpBackend.expectGET(url).respond({})
      $scope.load { data: { slug: 'my-playlist', owner: { slug: 'alice' } }}
      expect($scope.slug).to.equal('my-playlist')
      expect($scope.user_slug).to.equal('alice')
      $httpBackend.flush()
      
  describe '$scope.loadSongs', ->
    it "should load songs", ->
      response = JSON.stringify fixture
      $scope.loadSongs { data: response }
      expect($scope.songs.length).to.equal(3)
      expect($scope.mode).to.equal('ready')
      
  describe '$scope.displayError', ->
    it "should switch mode to 'error'", ->
      $scope.displayError()
      expect($scope.mode).to.equal 'error'
      
  describe '$scope.rollbackSort', ->
    it "should rollback to savedSongsState", ->
      $scope.savedSongsState = ['song1', 'song2', 'song3']
      $scope.songs = ['song3', 'song1', 'song2']
      $scope.rollbackSort()
      expect($scope.songs.length).to.equal 3
      expect($scope.songs[0]).to.equal 'song1'
      expect($scope.songs[1]).to.equal 'song2'
      expect($scope.songs[2]).to.equal 'song3'
      
  describe '$scope.toggleFollow', ->
    it "should follow playlist", ->
      $scope.followed = false
      $scope.user_slug = 'alice'
      $scope.slug = 'my-playlist'
      $httpBackend.expectPUT('/alice/my-playlist/follow.json').respond({})
      
      $scope.toggleFollow()
      
      $httpBackend.flush()
      expect($scope.followed).to.equal true
      
    it "should unfollow playlist", ->
      $scope.followed = true
      $scope.user_slug = 'alice'
      $scope.slug = 'my-playlist'
      $httpBackend.expectDELETE('/alice/my-playlist.json').respond({})
      
      $scope.toggleFollow()
      
      $httpBackend.flush()
      expect($scope.followed).to.equal false
      
    it "should handle failure trying to follow playlist", ->
      $scope.followed = false
      $scope.user_slug = 'alice'
      $scope.slug = 'my-playlist'
      $httpBackend.expectPUT('/alice/my-playlist/follow.json').respond(500, {})
      
      $scope.toggleFollow()
      
      $httpBackend.flush()
      expect($scope.followed).to.equal false
      
    it "should handle failure trying to unfollow playlist", ->
      $scope.followed = true
      $scope.user_slug = 'alice'
      $scope.slug = 'my-playlist'
      $httpBackend.expectDELETE('/alice/my-playlist.json').respond(500, {})
      
      $scope.toggleFollow()
      
      $httpBackend.flush()
      expect($scope.followed).to.equal true
      
  describe '$scope.prepareSongs', ->
    it "should setup params", ->
      $scope.songs = fixture
      $scope.prepareSongs()
      expect($scope.songIds.length).to.equal 3
      expect($scope.songIds[0]).to.equal '2'
      expect($scope.songIds[1]).to.equal '3'
      expect($scope.songIds[2]).to.equal '5'