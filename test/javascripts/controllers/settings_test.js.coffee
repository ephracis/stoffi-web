describe "SettingsController", ->
  
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
    it "should default to 'general'", ->
      controller = $controller('SettingsController', { $scope: $scope })
      expect($scope.getTab()).to.equal('general')
      
    it "should parse /settings/accounts to 'accounts'", ->
      controller = $controller('SettingsController', { $scope: $scope })
      $location.path '/settings/accounts'
      expect($scope.getTab()).to.equal('accounts')
  
  describe '$scope.setTab', ->
      
    it "should set to 'general'", ->
      controller = $controller('SettingsController', { $scope: $scope })
      $scope.setTab 'general'
      expect($location.path()).to.equal '/settings'
      expect($scope.tab).to.equal 'general'
      expect($window.document.title).to.equal 'General settings - Stoffi'
      
    it "should set to 'accounts'", ->
      controller = $controller('SettingsController', { $scope: $scope })
      $scope.setTab 'accounts'
      expect($location.path()).to.equal '/settings/accounts'
      expect($scope.tab).to.equal 'accounts'
      expect($window.document.title).to.equal 'Connected accounts - Stoffi'
      
    it "should not set to ''", ->
      controller = $controller('SettingsController', { $scope: $scope })
      $scope.setTab 'accounts'
      $scope.setTab ''
      expect($location.path()).to.equal '/settings/accounts'
      expect($scope.tab).to.equal 'accounts'
      expect($window.document.title).to.equal 'Connected accounts - Stoffi'
      
    it "should not set to 'foobar'", ->
      controller = $controller('SettingsController', { $scope: $scope })
      $scope.setTab 'accounts'
      $scope.setTab 'foobar'
      expect($location.path()).to.equal '/settings/accounts'
      expect($scope.tab).to.equal 'accounts'
      expect($window.document.title).to.equal 'Connected accounts - Stoffi'
      
    it "should not set to null", ->
      controller = $controller('SettingsController', { $scope: $scope })
      $scope.setTab 'accounts'
      $scope.setTab null
      expect($location.path()).to.equal '/settings/accounts'
      expect($scope.tab).to.equal 'accounts'
      expect($window.document.title).to.equal 'Connected accounts - Stoffi'
    
  describe 'hashPasswords', ->
     
    it 'should hash password', ->
      controller = $controller('SettingsController', { $scope: $scope })
      $scope.password = 'supersecret'
      $scope.email = 'test@mail.com'
      hashed = CryptoJS.SHA256($scope.email + $scope.password).toString()
      $scope.hashPasswords()
      expect($scope.password).to.equal(hashed)
       
    it 'should not hash empty password', ->
      controller = $controller('SettingsController', { $scope: $scope })
      $scope.password = ''
      $scope.email = 'test@mail.com'
      $scope.hashPasswords()
      expect($scope.password).to.equal('')
      
  describe 'name', ->
    it 'should get facebook as name source', ->
      controller = $controller('SettingsController', { $scope: $scope })
      response = {
        data: {
          links: [
            {
              provider: 'facebook',
              display: 'Facebook',
              enable_listens: true,
              enable_shares: true,
              enable_playlists: true,
              enable_button: true,
              name: 'Facebook Name'
            },
            {
              provider: 'twitter',
              display: 'Twitter',
              enable_shares: true,
              enable_button: true,
              name: 'Twitter Name'
            }
          ],
          name: 'Custom Name',
          name_source: { provider: 'facebook' }
        }
      }
      $scope.loadLinks response
      expect(Object.keys($scope.links).length).to.equal 2
      expect($scope.nameSource.name).to.equal 'Facebook Name'
      
    it 'should get a custom name source', ->
      controller = $controller('SettingsController', { $scope: $scope })
      response = {
        data: {
          links: [
            {
              provider: 'facebook',
              display: 'Facebook',
              enable_listens: true,
              enable_shares: true,
              enable_playlists: true,
              enable_button: true,
              name: 'Facebook Name'
            },
            {
              provider: 'twitter',
              display: 'Twitter',
              enable_shares: true,
              enable_button: true,
              name: 'Twitter Name'
            }
          ],
          name: 'Custom Name'
        }
      }
      $scope.loadLinks response
      expect($scope.nameSource.name).to.equal 'Custom Name'
      
    it 'should set facebook as name source', ->
      controller = $controller('SettingsController', { $scope: $scope })
      $scope.links = {
        facebook: {
          provider: 'facebook',
          display: 'Facebook',
          enable_listens: true,
          enable_shares: true,
          enable_playlists: true,
          enable_button: true,
          name: 'Facebook Name'
        },
        twitter: {
          provider: 'twitter',
          display: 'Twitter',
          enable_shares: true,
          enable_button: true,
          name: 'Twitter Name'
        }
      }
      $scope.setNameSource 'facebook'
      expect($scope.nameSource.name).to.equal 'Facebook Name'
      
    it 'should set a custom name source', ->
      controller = $controller('SettingsController', { $scope: $scope })
      $scope.links = {
        facebook: {
          provider: 'facebook',
          display: 'Facebook',
          enable_listens: true,
          enable_shares: true,
          enable_playlists: true,
          enable_button: true,
          name: 'Facebook Name'
        },
        twitter: {
          provider: 'twitter',
          display: 'Twitter',
          enable_shares: true,
          enable_button: true,
          name: 'Twitter Name'
        }
      }
      $scope.customName.name = 'Custom Name'
      $scope.setNameSource ''
      expect($scope.nameSource.name).to.equal 'Custom Name'
      
  describe 'links', ->
    it 'should get link settings', ->
      controller = $controller('SettingsController', { $scope: $scope })
      response = {
        data: {
          links: [
            {
              provider: 'facebook',
              display: 'Facebook',
              enable_listens: true,
              enable_shares: false,
              enable_playlists: true,
              enable_button: true,
              name: 'Facebook Name'
            },
            {
              provider: 'twitter',
              display: 'Twitter',
              enable_shares: true,
              enable_button: false,
              name: 'Twitter Name'
            }
          ],
          name: 'Custom Name'
        }
      }
      $scope.loadLinks response
      expect($scope.linkSetting('facebook', 'button')).to.equal 'on'
      expect($scope.linkSetting('facebook', 'shares')).to.equal 'off'
      expect($scope.linkSetting('twitter', 'shares')).to.equal 'on'
      expect($scope.linkSetting('twitter', 'button')).to.equal 'off'
      
    it 'should get link settings', ->
      controller = $controller('SettingsController', { $scope: $scope })
      response = {
        data: {
          links: [
            {
              provider: 'facebook',
              display: 'Facebook',
              enable_listens: true,
              enable_shares: false,
              enable_playlists: true,
              enable_button: true,
              name: 'Facebook Name'
            },
            {
              provider: 'twitter',
              display: 'Twitter',
              enable_shares: true,
              enable_button: false,
              name: 'Twitter Name'
            }
          ],
          name: 'Custom Name'
        }
      }
      $scope.loadLinks response
      $scope.toggleLinkSetting 'facebook', 'button'
      $scope.toggleLinkSetting 'facebook', 'shares'
      $scope.toggleLinkSetting 'twitter', 'shares'
      $scope.toggleLinkSetting 'twitter', 'button'
      expect($scope.linkSetting('facebook', 'button')).to.equal 'loading'
      expect($scope.linkSetting('facebook', 'shares')).to.equal 'loading'
      expect($scope.linkSetting('twitter', 'shares')).to.equal 'loading'
      expect($scope.linkSetting('twitter', 'button')).to.equal 'loading'