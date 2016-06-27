@app.controller 'PlaylistController', ($scope, $http, $sce, $compile) ->
  
  # Holds a list of rendered songs of the playlist.
  $scope.songs = []
  
  # A saved state of songs when attempting to reorder, used to rollback
  # to in case of a failure.
  $scope.savedSongsState = []
  
  # Holds the concatenated list of rendered songs
  # TODO: bind this to `$scope.songs`.
  $scope.songsHtml = ''
  
  # The value of the parameter `playlist[songs]`.
  $scope.songIds = []
  
  # The current mode, can be any of:
  # - loading
  # - error
  # - ready
  $scope.mode = 'loading'
  
  # Options for the sortable plugin when showing the playlist.
  #
  # Will save changes immediately.
  $scope.sortableOptions = {
    update: (e, ui) ->
      # save previous state so we can revert if sort fails
      $scope.savedSongsState.length = 0
      for i in $scope.songs
        $scope.savedSongsState.push i
      
    stop: (e, ui) ->
      $scope.refreshSongs()
      song_ids = $scope.songs.map( (song) ->
        $(song).attr('data-resource-id')
      )
      $http.patch("/#{$scope.user_slug}/#{$scope.slug}/sort.json", {
        song: song_ids
      }).then(null, $scope.rollbackSort)
  }
  
  # Options for the sortable plugin when editing or creating a playlist.
  #
  # Will not save changes, this has to be done later when submitting the form.
  $scope.sortableFormOptions = {
    stop: (e, ui) ->
      $scope.refreshSongs()
  }
    
  # Initialize playlist meta data.
  $scope.init = (params) ->
    $scope.followed = params.followed || false
    $scope.slug = params.slug
    $scope.user_slug = params.user_slug
    
  # Initialize a new playlist, possibly with some songs added to it
  $scope.new = (songs) ->
    url = "/songs.js?ids=#{songs}"
    $http.get(url).then $scope.loadSongs, $scope.displayError
  
  # Will fetch playlist meta data from a JSON url.
  $scope.fetch = (url) ->
    $scope.mode = 'loading'
    $http.get(url).then $scope.load, $scope.displayError
    
  # Will load the JSON response for a playlist.
  $scope.load = (response) ->
    $scope.slug = response.data.slug
    $scope.id = response.data.id
    $scope.user_slug = response.data.owner.slug
    url = "/#{$scope.user_slug}/#{$scope.slug || $scope.id}.js"
    $http.get(url).then $scope.loadSongs, $scope.displayError
  
  # Build the HTML of songs.
  $scope.refreshSongs = ->
    $scope.songsHtml = $sce.trustAsHtml $scope.songs.join('')
    $scope.prepareSongs()
    
  # Callback that is called when autocomplete search for songs is started.
  $scope.beforeSongSearch = ->
    $scope.searchingForSongs = true
    
  # Callback that is called when autocomplete search for songs is completed.
  $scope.afterSongSearch = ->
    $scope.searchingForSongs = false
    
  # Callback that is called when the user selects a hit from search
  # autocomplete.
  $scope.selectSongSearch = (event, ui) ->
    $scope.songs.unshift parseSong(ui.item.value)
    $scope.refreshSongs()
    $scope.mode = 'ready'
    
  # Called when the close button on a song is clicked by the user.
  $scope.removeSong = (song_id) ->
    songHtml = ''
    for song in $scope.songs
      if $(song).find('.media.resource').attr("data-resource-id") ==
          "#{song_id}"
        songHtml = song
        break
    $scope.songs = $.grep $scope.songs, (v) ->
      v != songHtml
    $scope.refreshSongs()
    
  # Parse the HTML of a song and inject the proper JS hooks into it.
  parseSong = (songHtml) ->
    song = $(songHtml)
    song_id = song.find('.media.resource').attr 'data-resource-id'
    song.find('button.close').attr 'data-ng-click', "removeSong(#{song_id})"
    song.wrap('<div/>').parent().html()
    
  # Will load the JavaScript response for a playlist.
  $scope.loadSongs = (response) ->
    items = eval(response.data)
    if items.length > 0
      $scope.songs.length = 0
      for songHtml in items
        $scope.songs.push parseSong(songHtml)
      $scope.refreshSongs()
      $scope.mode = 'ready'
    else
      $scope.mode = 'empty'
    
  # Displays an error instead of loaded songs.
  $scope.displayError = (response) ->
    $scope.mode = 'error'
    
  # Revert the sorting back to the state before an attempted sort, rolling back
  # to the state saved in `previousSongList`.
  $scope.rollbackSort = (response) ->
    $scope.songs.length = 0
    for i in $scope.savedSongsState
      $scope.songs.push i
    $scope.refreshSongs()
    
  # Follow and unfollow the playlist.
  $scope.toggleFollow = () ->
    $scope.togglingFollow = true
    if $scope.followed
      url = "/#{$scope.user_slug}/#{$scope.slug}.json"
      method = 'delete'
    else
      url = "/#{$scope.user_slug}/#{$scope.slug}/follow.json"
      method = 'put'
     
    $http({method: method, url: url}).then ->
      $scope.followed = !$scope.followed
      $scope.togglingFollow = false
    , ->
      $scope.togglingFollow = false
      
  
  # Prepare the list of songs as a parameter for the request of a submitted
  # form.
  $scope.prepareSongs = ->
    $scope.songIds = []
    for song in $scope.songs
      songId = $(song).find('.media.resource').attr('data-resource-id')
      $scope.songIds.push songId