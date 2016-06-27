@app.controller 'SettingsController', ['$scope', '$location', '$window', '$http', 'evaluateStrength', ($scope, $location, $window, $http, evaluateStrength) ->
  
  available = ['general', 'accounts']
  default_tab = 'general'

  # Get the currently active tab.
  $scope.getTab = ->
    paths = $location.path().split('/')
    if paths.length > 2 and paths[2] in available
      return paths[2]
    return default_tab

  # Change the currently active tab.
  $scope.setTab = (tab) ->
    return unless tab in available
    if tab == default_tab
      $location.path '/settings'
    else
      $location.path("/settings/#{tab}")
    updateTitle()
    $scope.tab = tab

  # Update the title on the page according to the currently selected tab.
  updateTitle = ->
    title = I18n.t("accounts.edit.#{$scope.getTab()}.title")
    $window.document.title = "#{title} - Stoffi"
    
  updateTitle()
    
  $scope.$watch () ->
    $location.absUrl()
  , () ->
    $scope.tab = $scope.getTab()

  $scope.links = null
  $scope.customName = { provider: '', name: '', display: I18n.t('accounts.edit.general.name.custom') }
  $scope.editPassword = false
  $scope.currentPassword = ''
  $scope.password = ''
  $scope.passwordConfirmation = ''
  $scope.strengthTooltip = PW_CRACKING_TOOLTIP
  $scope.linkSettingState = {}

  # Whether or not to show the password strength indicator.
  $scope.showStrengthIndicator = ->
    !!$password

  # Evaluate the password strength of the new password.
  $scope.passwordStrength = ->
    evaluateStrength $scope.password

  # Hash all passwords before submitting them over the network.
  $scope.hashPasswords = ->
    return unless $scope.email and $scope.password
    hash = CryptoJS.SHA256
    $scope.currentPassword = hash($scope.email + $scope.currentPassword).toString()
    $scope.password = hash($scope.email + $scope.password).toString()
    $scope.passwordConfirmation = hash(
      $scope.email + $scope.passwordConfirmation).toString()

  # Fetch info for the current user.
  $scope.fetchLinks = (source) ->
    $http( { method: 'GET', url: '/me.json' }).then($scope.loadLinks, (response) -> nil)

  # Set the source for the user's name.
  $scope.setNameSource = (provider) ->
    if provider and $scope.links[provider]
      $scope.nameSource = $scope.links[provider]
    else
      $scope.nameSource = $scope.customName

  # Get the value of a link setting.
  $scope.linkSetting = (provider, setting) ->
    if $scope.linkSettingState[provider]
      if $scope.linkSettingState[provider][setting] == true
        return 'on'
      else if $scope.linkSettingState[provider][setting] == false
        return 'off'
    return 'loading'

  # Turns a boolean link setting on and off.
  $scope.toggleLinkSetting = (provider, setting) ->
    return unless $scope.linkSettingState[provider]
    state = $scope.linkSettingState[provider][setting]
    $scope.linkSettingState[provider][setting] = 'loading'
    link = $scope.links[provider]
    data = {}
    data["enable_#{setting}"] = !state
    req = {
      link: { "enable_#{setting}": !state }
    }
    $http.patch("/links/#{link.id}.json", req).then((response) ->
      $scope.linkSettingState[provider][setting] = !state
    , (response) ->
      $scope.linkSettingState[provider][setting] = state
    )

  # Load links using the response from a request to /me.json
  # 
  # Parses all linked accounts, the state of their settings,
  # and initializes the current name source.   
  $scope.loadLinks = (response) ->
    $scope.links = null
    $scope.links = {} if response.data.links
    $scope.linkSettingState = {}
    for link in response.data.links
      $scope.links[link.provider] = link
      $scope.linkSettingState[link.provider] = {}
      for resource in ['listens', 'shares', 'playlists', 'button']
        if link["enable_#{resource}"] != undefined
          $scope.linkSettingState[link.provider][resource] =
           link["enable_#{resource}"]
        
    $scope.customName.name = response.data.name
    if response.data.name_source
      $scope.setNameSource response.data.name_source.provider
    else
      $scope.setNameSource null

  $scope.fetchLinks()
]
