@app.directive 'stfPillbox', ->
  {
    restrict: 'A',
    scope: {
      add: '=stfPillboxAdd',
      remove: '=stfPillboxRemove'
    },
    link: (scope, element, attributes) ->
      $(element).pillbox({
        onAdd: (data, callback) ->
          scope.$apply(scope.add(data))
        onRemove: (data, callback) ->
          scope.$apply(scope.remove(data))
      })
  }