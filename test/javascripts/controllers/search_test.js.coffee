describe "SearchController", ->
  
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
  
  describe '$scope.mode', ->
    it "should default to 'front'", ->
      controller = $controller('SearchController', { $scope: $scope })
      expect($scope.mode).to.equal 'front'
      
    it "should set to 'searchingDb'", ->
      controller = $controller('SearchController', { $scope: $scope })
      $scope.query = 'test'
      $scope.performSearch()
      expect($scope.mode).to.equal 'searchingDb'
      
    it "should set to 'error'", ->
      controller = $controller('SearchController', { $scope: $scope })
      $scope.displayError()
      expect($scope.mode).to.equal 'error'
      
    it "should set to 'searchingBackends'", ->
      controller = $controller('SearchController', { $scope: $scope })
      $scope.query = 'test'
      $scope.performSearch()
      $scope.loadResults { data: [] }
      expect($scope.mode).to.equal 'searchingBackends'
      
    it "should set to 'empty'", ->
      controller = $controller('SearchController', { $scope: $scope })
      $scope.query = 'test'
      $scope.performSearch()
      $scope.loadResults { data: [] }
      $scope.loadResults { data: [] }
      expect($scope.mode).to.equal 'empty'
      
    it "should set to 'results'", ->
      controller = $controller('SearchController', { $scope: $scope })
      $scope.loadResults { data: [1] }
      expect($scope.mode).to.equal 'results'
  
  describe '$scope.categories', ->
    it "should be initialized to 7", ->
      controller = $controller('SearchController', { $scope: $scope })
      expect(Object.keys($scope.categories).length).to.equal(7)
  
  describe '$scope.currentCategory', ->
    it "should default to 'all'", ->
      controller = $controller('SearchController', { $scope: $scope })
      expect($scope.currentCategory.name).to.equal('all')
      expect($scope.currentCategory.display).to.equal('Everything')
  
  describe '$scope.setCategory', ->
    it "should set category to 'artists'", ->
      controller = $controller('SearchController', { $scope: $scope })
      expect($scope.setCategory('artists').name).to.equal('artists')
      expect($scope.currentCategory.name).to.equal('artists')
      expect($scope.currentCategory.display).to.equal('Artists')
      
    it "should ignore invalid category", ->
      controller = $controller('SearchController', { $scope: $scope })
      expect($scope.currentCategory.name).to.equal('all')
      expect($scope.setCategory('foobar')).to.equal(undefined)
      expect($scope.currentCategory.name).to.equal('all')
      
    it "should ignore empty string", ->
      controller = $controller('SearchController', { $scope: $scope })
      expect($scope.currentCategory.name).to.equal('all')
      expect($scope.setCategory('')).to.equal(undefined)
      expect($scope.currentCategory.name).to.equal('all')
      
    it "should ignore empty null", ->
      controller = $controller('SearchController', { $scope: $scope })
      expect($scope.currentCategory.name).to.equal('all')
      expect($scope.setCategory()).to.equal(undefined)
      expect($scope.currentCategory.name).to.equal('all')
      
  describe 'submit', ->
    it 'should change URL', ->
      controller = $controller('SearchController', { $scope: $scope })
      $location.path('/not/search')
      $scope.searchPath = '/search'
      $scope.setCategory 'artists'
      $scope.query = 'my query'
      $scope.submit()
      expect($location.path()).to.equal '/search'
      expect($window.document.title).to.equal 'my query - Stoffi'
      
  describe 'searchUrl', ->
    it 'should construct a JS url', ->
      controller = $controller('SearchController', { $scope: $scope })
      $scope.searchPath = '/search'
      $scope.setCategory 'artists'
      $scope.query = 'my query'
      expect($scope.searchUrl()).to.equal('/search.js?c=artists&q=my query')