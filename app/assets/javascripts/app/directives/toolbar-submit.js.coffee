@app.directive 'toolbarSubmit', ->
  {
    link: (scope, element, attr) ->
      element.click ->
        $('.root form:first').submit()
  }