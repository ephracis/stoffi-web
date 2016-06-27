@app.controller 'SongController', ($scope, $http) ->
  
  # An array of artist names.
  $scope.artists = []
  
  # An array of genre names.
  $scope.genres = []
  
  # An array of IDs of duplicates.
  $scope.duplicates = []
  
  # The songs genres, concatenated using a comma.
  $scope.genreParam = ->
    return '' unless $scope.genres
    $scope.genres.join(', ')
  
  # Fetch meta data for a song given its URL.
  $scope.fetch = (url) ->
    $http.get(url).then (response) ->
      $scope.id = response.data.id
      $scope.artists.length = 0
      for artist in response.data.artists
        $scope.artists.push artist.name
      $scope.genres.length = 0
      for genre in response.data.genres
        $scope.genres.push genre.name
      if response.data.duplicates
        $scope.duplicates.length = 0
        for duplicate in response.data.duplicates
          $scope.duplicates.push duplicate.id
    , ->
      alert("There was an error fetching meta data for the song.")
      
  # Callback which is called when new artists are added.
  # `data` contains a list of the artists that are to be added.
  $scope.addArtist = (data) ->
    $scope.artists.push data.value
      
  # Callback which is called when artists are removed.
  # `data` contains a list of the artists that are to be removed.
  $scope.removeArtist = (data) ->
    if $.inArray(data.value, $scope.artists) != -1
      $scope.artists.splice $.inArray(data.value, $scope.artists), 1
      
  # Callback which is called when new genres are added.
  # `data` contains a list of the genres that are to be added.
  $scope.addGenre = (data) ->
    $scope.genres.push data.value
      
  # Callback which is called when genres are removed.
  # `data` contains a list of the genres that are to be removed.
  $scope.removeGenre = (data) ->
    if $.inArray(data.value, $scope.genres) != -1
      $scope.genres.splice $.inArray(data.value, $scope.genres), 1
      
  # Check whether a song, given its ID, is a duplicate of the current song.
  $scope.isDup = (song_id) ->
    $.inArray(song_id, $scope.duplicates) != -1
      
  # Toggle whether a song, given its ID, is a duplicate of the current song.
  $scope.toggleDup = (song_id) ->
    if $scope.isDup(song_id)
      $scope.duplicates.splice $.inArray(song_id, $scope.duplicates), 1
      arch = ''
    else
      $scope.duplicates.push song_id
      arch = $scope.id
    
    $http.patch("/songs/#{song_id}.json?song[archetype]=#{arch}").then null, ->
      if $scope.isDup(song_id)
        $scope.duplicates.splice $.inArray(song_id, $scope.duplicates), 1
      else
        $scope.duplicates.push song_id