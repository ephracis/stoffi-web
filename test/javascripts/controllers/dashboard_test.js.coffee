describe "DashboardController", ->
  
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
    it "should default to 'activity'", ->
      controller = $controller('DashboardController', { $scope: $scope })
      expect($scope.getTab()).to.equal('activity')
      
    it "should parse /dashboard/stats to 'stats'", ->
      controller = $controller('DashboardController', { $scope: $scope })
      $location.path '/dashboard/stats'
      expect($scope.getTab()).to.equal('stats')
      
    it "should parse /dashboard/rank to 'rank'", ->
      controller = $controller('DashboardController', { $scope: $scope })
      $location.path '/dashboard/rank'
      expect($scope.getTab()).to.equal('rank')
      
    it "should parse /devices to 'devices'", ->
      controller = $controller('DashboardController', { $scope: $scope })
      $location.path '/devices'
      expect($scope.getTab()).to.equal('devices')
  
  describe '$scope.setTab', ->
      
    it "should set to 'activity'", ->
      controller = $controller('DashboardController', { $scope: $scope })
      $scope.setTab 'activity'
      expect($location.path()).to.equal '/dashboard'
      expect($scope.tab).to.equal 'activity'
      expect($window.document.title).to.equal 'Activity - Stoffi'
      
    it "should set to 'stats'", ->
      controller = $controller('DashboardController', { $scope: $scope })
      $scope.setTab 'stats'
      expect($location.path()).to.equal '/dashboard/stats'
      expect($scope.tab).to.equal 'stats'
      expect($window.document.title).to.equal 'Statistics - Stoffi'
      
    it "should set to 'rank'", ->
      controller = $controller('DashboardController', { $scope: $scope })
      $scope.setTab 'rank'
      expect($location.path()).to.equal '/dashboard/rank'
      expect($scope.tab).to.equal 'rank'
      expect($window.document.title).to.equal 'Ranking - Stoffi'
      
    it "should set to 'devices'", ->
      controller = $controller('DashboardController', { $scope: $scope })
      $scope.setTab 'devices'
      expect($location.path()).to.equal '/devices'
      expect($scope.tab).to.equal 'devices'
      expect($window.document.title).to.equal 'Devices - Stoffi'
      
    it "should not set to ''", ->
      controller = $controller('DashboardController', { $scope: $scope })
      $scope.setTab 'stats'
      $scope.setTab ''
      expect($location.path()).to.equal '/dashboard/stats'
      expect($scope.tab).to.equal 'stats'
      expect($window.document.title).to.equal 'Statistics - Stoffi'
      
    it "should not set to 'foobar'", ->
      controller = $controller('DashboardController', { $scope: $scope })
      $scope.setTab 'stats'
      $scope.setTab 'foobar'
      expect($location.path()).to.equal '/dashboard/stats'
      expect($scope.tab).to.equal 'stats'
      expect($window.document.title).to.equal 'Statistics - Stoffi'
      
    it "should not set to null", ->
      controller = $controller('DashboardController', { $scope: $scope })
      $scope.setTab 'stats'
      $scope.setTab null
      expect($location.path()).to.equal '/dashboard/stats'
      expect($scope.tab).to.equal 'stats'
      expect($window.document.title).to.equal 'Statistics - Stoffi'