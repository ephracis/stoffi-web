describe "LoginController", ->
  
  $controller = null
  $location = null
  
  beforeEach module('Stoffi')
  
  beforeEach inject( (_$controller_, _$rootScope_, _$location_) ->
    $controller = _$controller_
    $location = _$location_
  )
  
  describe '$scope.mode', ->
    it "should default to 'unknown'", ->
      sinon.stub($location, 'path').returns('/non-existant')
      $scope = {}
      controller = $controller('LoginController', { $scope: $scope })
      expect($scope.mode).to.equal('unknown')
      
    it "should parse /login as 'login'", ->
      sinon.stub($location, 'path').returns('/login')
      $scope = {}
      controller = $controller('LoginController', { $scope: $scope })
      expect($scope.mode).to.equal('login')
      
    it "should parse /join as 'join'", ->
      sinon.stub($location, 'path').returns('/join')
      $scope = {}
      controller = $controller('LoginController', { $scope: $scope })
      expect($scope.mode).to.equal('join')
      
  describe 'showStrengthIndicator', ->
    it 'should not show without password', ->
      $scope = {}
      controller = $controller('LoginController', { $scope: $scope })
      expect($scope.showStrengthIndicator()).to.equal(false)
      
    it 'should show with password', ->
      sinon.stub($location, 'path').returns('/join')
      $scope = {}
      controller = $controller('LoginController', { $scope: $scope })
      $scope.password = 'foo'
      expect($scope.showStrengthIndicator()).to.equal(true)
      
    it 'should not show on login', ->
      sinon.stub($location, 'path').returns('/login')
      $scope = {}
      controller = $controller('LoginController', { $scope: $scope })
      $scope.password = 'foo'
      expect($scope.showStrengthIndicator()).to.equal(false)
    
  describe 'hashPasswords', ->
     
    it 'should hash password', ->
      $scope = {}
      controller = $controller('LoginController', { $scope: $scope })
      $scope.password = 'supersecret'
      $scope.email = 'test@mail.com'
      hashed = CryptoJS.SHA256($scope.email + $scope.password).toString()
      $scope.hashPasswords()
      expect($scope.password).to.equal(hashed)
       
    it 'should not hash empty password', ->
      $scope = {}
      controller = $controller('LoginController', { $scope: $scope })
      $scope.password = ''
      $scope.email = 'test@mail.com'
      $scope.hashPasswords()
      expect($scope.password).to.equal('')
       
    it 'should not hash with empty email', ->
      $scope = {}
      controller = $controller('LoginController', { $scope: $scope })
      $scope.password = 'supersecret'
      $scope.email = ''
      $scope.hashPasswords()
      expect($scope.password).to.equal('supersecret')
      