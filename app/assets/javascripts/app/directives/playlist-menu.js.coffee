@app.directive 'playlistMenu', ($compile, $parse, $http) ->
  {
    restrict: 'A',
    scope: {
      songs: '=playlistMenuSongs' # array of IDs
    },
    link: (scope, element, attr) ->
      scope.playlist_url = $parse(attr.ngPlaylistMenuPath)
      
      element.find("[data-playlist-menu-playlist-loading]").hide()
      refreshChecks()
      
      # item
      element.find('[data-playlist-menu-playlist]').on 'click', (event) ->
        playlist = $(@).attr 'data-playlist-menu-playlist'
        $(@).find("[data-playlist-menu-playlist-added]").hide()
        $(@).find("[data-playlist-menu-playlist-loading]").show()
        isAdded = $(@).find("[data-playlist-menu-playlist-added]").
          attr 'data-playlist-menu-playlist-added'
        if isAdded == 'true'
          remove $http, scope.songs, playlist
        else
          add $http, scope.songs, playlist
        event.stopPropagation()
        false
        
      # input
      element.find('[data-playlist-menu-new]').on 'keyup', (e) ->
        return unless e.keyCode == 13
        name = $(@).val()
        add_new $http, scope.songs, name
  }
  
# Add songs to a playlist.
add = ($http, songs, playlist) ->
  toggle 'add', $http, songs, playlist


# Remove songs from a playlist.
remove = ($http, songs, playlist) ->
  toggle 'remove', $http, songs, playlist
  
toggle = (action, $http, songs, playlist) ->
  url = "#{playlist}.json?songs=[#{songs}]"
  menu = $("[data-playlist-menu-songs='[#{songs}]']")
  plist = menu.find("[data-playlist-menu-playlist='#{playlist}']")
  loading = plist.find("[data-playlist-menu-playlist-loading]")
  added = plist.find("[data-playlist-menu-playlist-added]")
  
  if action == 'add'
    data = { songs: { added: songs } }
  else
    data = { songs: { removed: songs } }
  
  $http({
    url: "#{playlist}.json",
    method: 'patch',
    data: data,
  }).then ->
    
    # success
    loading.hide()
    added.attr 'data-playlist-menu-playlist-added',
      (action == 'add' ? 'true' : 'false')
    refreshChecks()
    
  , ->
    # error
    loading.hide()
    added.attr 'data-playlist-menu-playlist-added',
      (action == 'add' ? 'false' : 'true')
    refreshChecks()


  
add_new = (songs, name) ->
  alert("add #{songs} to new playlist with name #{name}")
  
# Update the visibility of check marks depending on their setting.
refreshChecks = ->
  $("[data-playlist-menu-playlist-added='false']").hide()
  $("[data-playlist-menu-playlist-added='true']").show()