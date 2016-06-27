# script that runs on page load and massages the dom
$ ->
  
  # set target on breadcrumb links
  $("ol.breadcrumb a[href]").attr('target', '_self')