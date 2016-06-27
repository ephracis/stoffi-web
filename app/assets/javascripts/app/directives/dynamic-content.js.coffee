@app.directive 'dynamicContent', ($compile, $parse) ->
  {
    link: (scope, element, attr) ->
      parsed = $parse(attr.ngBindHtml)
      getStringValue = ->
        (parsed(scope) || '').toString()
      scope.$watch getStringValue, ->
        $compile(element, null, -9999)(scope)
  }