$(".inspectable-sheet").click(function() {
  sheet    = $(this)

  if ($(this).data('content') == "" || $(this).data('content') == null) {
    sheet_id   = $(this).data('sheet-id')
    column_url = ajax_host + 'sheets/' + sheet_id + '/columns'
    $.get(column_url, function(data) {
      $(sheet).data("content", "1")
      $(sheet).popover({
        html:    true,
        content: columns_to_html(data)
      })
      $(sheet).popover('show')
    });
  }
});

function columns_to_html(data) {
  console.log(data.columns.length)
  html_content = ""
  for (var i = 0 ; i < data.columns.length ; i++) {
    column = data.columns[i]
    html_content += "<b>" + column.title + "</b><br>"
  }
  return html_content
}
