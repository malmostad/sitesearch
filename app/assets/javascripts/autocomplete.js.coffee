$ ->
  $searchField = $('#full-search #q')
  if $searchField.length
    $searchField.autocomplete
      source: (request, response) ->
        $.ajax
          url: $searchField.attr("data-autocomplete-path")
          data:
            q: request.term.toLowerCase()
            ilang: 'sv'
          dataType: "jsonp"
          jsonpCallback: "results"
          success: (data) ->
            if data.length
              response $.map data, (item) ->
                return {
                  hits: item.nHits
                  suggestionHighlighted: item.suggestionHighlighted
                  value: item.suggestion
                }
      minLength: 2
      select: (event, ui) ->
        $searchField.val(ui.item.value)
        $('#full-search').submit()
    .data( "ui-autocomplete" )._renderItem = (ul, item) ->
      return $("<li></li>")
      .data("ui-autocomplete-item", item)
      .append("<a><span class='hits'>" + item.hits + "</span>" + item.suggestionHighlighted + "</a>")
      .appendTo(ul)