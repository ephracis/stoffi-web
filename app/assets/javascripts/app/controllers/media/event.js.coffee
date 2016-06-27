@app.controller 'EventController', ($scope, $http) ->
  
  # Fetch meta data for an event given its URL.
  $scope.fetch = (url) ->
    $http.get(url).then (response) ->
      $scope.id = response.data.id
    , ->
      console.log("There was an error fetching meta data for the event.")