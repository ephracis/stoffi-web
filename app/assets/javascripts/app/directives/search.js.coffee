@app.directive 'stfSearch', ->
  {
    restrict: 'A',
    scope: {
      before: '=stfSearchBefore',
      after: '=stfSearchAfter',
      select: '=stfSearchSelect'
    },
    link: (scope, element, attributes) ->
      $(element).autocomplete({
        source: attributes.stfSearch,
        minLength: 2,
        search: ->
          scope.$apply(scope.before())
        response: ->
          scope.$apply(scope.after())
        focus: ->
          false
        select: (event,ui) ->
          scope.$apply(scope.select(event,ui))
          $(element).val('')
          false
      })
      .autocomplete('instance')._renderItem = (ul, item) ->
        $("<li>"+item.value+"</li>").appendTo(ul)
  }