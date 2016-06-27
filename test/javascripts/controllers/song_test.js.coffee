describe "SongController", ->
  
  $controller = null
  $scope = null
  $httpBackend = null
  
  beforeEach module('Stoffi')
  
  beforeEach inject( (_$controller_, _$rootScope_, _$httpBackend_) ->
    $controller = _$controller_
    $scope = _$rootScope_.$new()
    $httpBackend = _$httpBackend_
    controller = $controller('SongController', { $scope: $scope })
  )
  
  describe '$scope.genreParam()', ->
    it "should concatenate genres", ->
      $scope.genres = ['rock', 'ska']
      expect($scope.genreParam()).to.equal('rock, ska')
      
    it "should handle empty array", ->
      $scope.genres = []
      expect($scope.genreParam()).to.equal('')
      
    it "should handle null array", ->
      $scope.genres = null
      expect($scope.genreParam()).to.equal('')
      
  describe '$scope.fetch()', ->
    it "should fetch song", ->
      url = '/songs/my-song.json'
      $httpBackend.expectGET(url).respond({
        artists: [ { name: 'artist1' }, { name: 'artist2' } ],
        genres: [ { name: 'rock' } ],
        duplicates: [ { id: 123 }, { id: 321 } ]
      })
      
      $scope.fetch(url)
      
      $httpBackend.flush()
      
      expect($scope.artists.length).to.equal 2
      expect($scope.artists[0]).to.equal 'artist1'
      expect($scope.artists[1]).to.equal 'artist2'
      expect($scope.genres.length).to.equal 1
      expect($scope.genres[0]).to.equal 'rock'
      
    it "should handle no duplicates in response", ->
      url = '/songs/my-song.json'
      $httpBackend.expectGET(url).respond({
        artists: [ { name: 'artist1' }, { name: 'artist2' } ],
        genres: [ { name: 'rock' } ]
      })
      $scope.fetch(url)
      $httpBackend.flush()
      expect($scope.artists.length).to.equal 2
      expect($scope.artists[0]).to.equal 'artist1'
      expect($scope.artists[1]).to.equal 'artist2'
      expect($scope.genres.length).to.equal 1
      expect($scope.genres[0]).to.equal 'rock'
      
  describe '$scope.addArtist()', ->
    it 'should add an artist', ->
      $scope.artists = ['artist1', 'artist2']
      $scope.addArtist { value: 'artist3' }
      expect($scope.artists.length).to.equal 3
      expect($scope.artists[2]).to.equal 'artist3'
      
  describe '$scope.removeArtist()', ->
    it 'should remove an artist', ->
      $scope.artists = ['artist1', 'artist2']
      $scope.removeArtist { value: 'artist2' }
      expect($scope.artists.length).to.equal 1
      expect($scope.artists[0]).to.equal 'artist1'
      
    it 'should handle non-existing artist', ->
      $scope.artists = ['artist1', 'artist2']
      $scope.removeArtist { value: 'artist3' }
      expect($scope.artists.length).to.equal 2
      
  describe '$scope.addGenre()', ->
    it 'should add a genre', ->
      $scope.genres = ['genre1', 'genre2']
      $scope.addGenre { value: 'genre3' }
      expect($scope.genres.length).to.equal 3
      expect($scope.genres[2]).to.equal 'genre3'
      
  describe '$scope.removeGenre()', ->
    it 'should remove a genre', ->
      $scope.genres = ['genre1', 'genre2']
      $scope.removeGenre { value: 'genre2' }
      expect($scope.genres.length).to.equal 1
      expect($scope.genres[0]).to.equal 'genre1'
      
    it 'should handle non-existing genre', ->
      $scope.genres = ['genre1', 'genre2']
      $scope.removeGenre { value: 'genre3' }
      expect($scope.genres.length).to.equal 2
      
  describe '$scope.isDup()', ->
    it "should return true for dups", ->
      $scope.duplicates = [123, 42]
      expect($scope.isDup(123)).to.equal true
      
    it "should return false for non-dups", ->
      $scope.duplicates = [123, 42]
      expect($scope.isDup(1337)).to.equal false
            
  describe '$scope.toggleDup()', ->
    it "should mark song as dup", ->
      $httpBackend.expectPATCH("/songs/123.json?song[archetype]=42").respond({})
      $scope.id = 42
      $scope.duplicates = [1337]
      $scope.toggleDup(123)
      $httpBackend.flush()
      expect($scope.duplicates.length).to.equal 2
      expect($scope.duplicates[1]).to.equal 123
      
    it "should unmark song as dup", ->
      $httpBackend.expectPATCH("/songs/123.json?song[archetype]=").respond({})
      $scope.id = 42
      $scope.duplicates = [1337, 123]
      $scope.toggleDup(123)
      $httpBackend.flush()
      expect($scope.duplicates.length).to.equal 1
      expect($scope.duplicates[0]).to.equal 1337