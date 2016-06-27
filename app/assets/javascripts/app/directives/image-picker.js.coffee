@app.directive 'imagePicker', ->
  {
    link: (scope, element, attributes) ->
      $(element).imagepicker()
  }
