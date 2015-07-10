refreshDuplicate = (element) ->
	if element.attr('data-duplicate-status') == 'marked'
		element.find('[data-duplicate-mark]').hide()
		element.find('[data-duplicate-unmark]').show()
	else
		element.find('[data-duplicate-mark]').show()
		element.find('[data-duplicate-unmark]').hide()

toggleDuplicate = (element, event) ->
	url = element.closest('[data-resource-url]').attr('data-resource-url')+'.json'
	archetype = element.attr 'data-archetype'
	status = element.attr 'data-duplicate-status'
	archetype = '' if status == 'marked'
	
	if status == 'marked'
		element.attr 'data-duplicate-status', 'unmarked'
	else
		element.attr 'data-duplicate-status', 'marked'
	refreshDuplicate element
	
	$.ajax {
		method: 'patch',
		url: url,
		data: "song[archetype]=#{archetype}",
		error: (output) ->
			element.attr 'data-duplicate-status', status
			refreshDuplicate element
	}

#
# Open a dialog to find duplicates of a resource.
#
findDuplicatesClicked = (element) ->
	url = element.data('duplicatable-url')
	openDialog url
	
markAsDuplicateClicked = (element) ->
	url = element.closest('#find-duplicates').data 'duplicatable-url'
	id = element.data 'resource-id'
	type = element.data 'resource-type'
	$.ajax {
		method: 'patch',
		url: url+'.json',
		dataType: 'html',
		data: "#{type}[]=#{id}",
		success: (data, status, jqXHR) ->
			element.toggle()
	}

$(document).on 'contentReady', () ->
	for element in $("a[data-ajax-call='duplicate']")
		refreshDuplicate $(element)
	$("a[data-ajax-call='duplicate']").when 'click.duplicate', (event) ->
		if event.which == 1
			event.stopPropagation()
			event.preventDefault()
			toggleDuplicate($(@), event)
			
	$('[data-duplicatable-url]').when 'click.find_duplicates', (event) ->
		findDuplicatesClicked $(@)
		
	$('#find-duplicates #search-results .item').when 'click.mark_duplicates', (event) ->
		markAsDuplicateClicked $(@)
		event.stopPropagation()