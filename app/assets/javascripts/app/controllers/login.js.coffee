@app.controller 'LoginController', ['$scope', '$location', 'evaluateStrength', ($scope, $location, evaluateStrength) ->
  $scope.mode = currentMode $location.path()
  $scope.password = ''
  $scope.passwordConfirmation = ''
  $scope.strengthTooltip = PW_CRACKING_TOOLTIP
    
  $scope.showStrengthIndicator = ->
    $scope.mode != 'login' and !!$scope.password
  
  $scope.passwordStrength = ->
    evaluateStrength $scope.password
    
  $scope.hashPasswords = ->
    return unless $scope.email and $scope.password
    hash = CryptoJS.SHA256
    $scope.password = hash($scope.email + $scope.password).toString()
    $scope.passwordConfirmation = hash(
      $scope.email + $scope.passwordConfirmation).toString()
]

#
# Get the current mode from the URL.
# Returns either `join`, `login` or `unknown`.
#
currentMode = (path) ->
  join_pattern = /^\/(join|user\/sign_up)$/
  login_pattern = /^\/(login|user\/sign_in)$/
  if path.match(join_pattern)
    mode = 'join'
  else if path.match(login_pattern) or path == '/'
    mode = 'login'
  else
    mode = 'unknown'