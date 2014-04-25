jQuery(function($) {
  var host = document.location.host;
  $('.repository').each(function() {
    var html = $(this).html().replace(/analizo.org/g, host);
    $(this).html(html);
    });
});
