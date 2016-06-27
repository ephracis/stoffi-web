@app.directive 'stfAutocomplete', ->
  {
    link: (scope, element, attributes) ->
      $(element).autocomplete({
        source: attributes.stfAutocomplete,
        minLength: 2,
        focus: (event,ui) ->
          $(element).val(ui.item.value)
          false
        select: (event,ui) ->
          # TODO: uncommenting this keeps the autocomplete open after
          # pressing enter
          #$(element).closest('form').submit()
          false
      })
      .autocomplete('instance')._renderItem = (ul, item) ->
        l = $(element).val().length
        str = "<b>#{item.value.substr(0,l)}</b>#{item.value.substr(l,item.value.length)}"
        li = '<li>'
        li = "<li data-value='#{item.id}'>" if item.id
        $(li+str+'</li>').appendTo(ul)
  }