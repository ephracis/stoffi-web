@app.directive 'tooltip', ->
  {
    link: (scope, element, attributes) ->
      $(element).qtip {
        content: attributes.tooltip,
        style: 'qtip-light qtip-shadow'
      }
  }