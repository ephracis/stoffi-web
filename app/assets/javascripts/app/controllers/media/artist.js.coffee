@app.controller 'ArtistController', ($scope, $http) ->
  
  # Fetch meta data for an artist given its URL.
  $scope.fetch = (url) ->
    $http.get(url).then (response) ->
      $scope.id = response.data.id
    , ->
      console.log("There was an error fetching meta data for the artist.")
