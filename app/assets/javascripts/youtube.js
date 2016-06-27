var tag = document.createElement('script');
tag.src = "https://www.youtube.com/iframe_api";
var firstScriptTag = document.getElementsByTagName('script')[0];
firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);
var player;
function onYouTubeIframeAPIReady() {
    player = new YT.Player('player', {
        height: '100%',
        width: '100%',
        videoId: 'dQw4w9WgXcQ',
        playerVars: {
            'autoplay': 0,
            'controls': 0,
            'modestbranding': 1
        },
        events: {
            'onStateChange': onPlayerStateChange,
            'onPlayerReady': onPlayerReady
        }
    });
}

function onPlayerReady(event) {
    console.log("call back into app");
}

function onPlayerStateChange(event) {
    console.log("call back into app");
}

function loadVideo(id) {
    return player.loadVideoById(id);
}

function playVideo() {
    return player.playVideo();
}

function pauseVideo() {
    return player.pauseVideo();
}

function stopVideo() {
    return player.stopVideo();
}

function getVideoState() {
    return player.getPlayerState();
}

function getVideoLoadedFraction() {
    return player.getVideoLoadedFraction();
}

function setPlaybackRate(suggestion) {
    return player.setPlaybackState(suggestion);
}

function seekTo(seconds) {
    return player.seedTo(seconds, true);
}

function getDuration() {
    return player.getDuration();
}

function getCurrentTime() {
    return player.getCurrentTime();
}
