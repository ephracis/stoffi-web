tag = document.createElement('script')
tag.src = "//www.youtube.com/iframe_api"
firstScriptTag = document.getElementsByTagName('script')[0]
firstScriptTag.parentNode.insertBefore(tag, firstScriptTag)

player = null

window.onYouTubeIframeAPIReady = ->
  player = new YT.Player 'player', { 
    height: '100%',
    width: '100%',
    videoId: 'dQw4w9WgXcQ',
    playerVars: {
      autoplay: false,
      controls: false,
      modestbranding: true
    },
    events: {
      onStateChange: onPlayerStateChange
    }
  }

onPlayerStateChange = (event) ->
  console.log "changed state to #{event.data}" # YT.PlayerState

@loadVideo = (id) ->
  player.loadVideoById id

@playVideo = ->
  player.playVideo()

@pauseVideo = ->
  player.pauseVideo()

@stopVideo = ->
  player.stopVideo()

@getPlayerState = ->
  player.getPlayerState()

@getVideoLoadedFraction = ->
  player.getVideoLoadedFraction()

@setPlaybackRate = (suggestion) ->
  player.setPlaybackRate suggestion

@seekTo = (seconds) ->
  player.stopVideo seconds, true

@getDuration = ->
  player.getDuration()

@getCurrentTime = ->
  player.getCurrentTime()
