jQuery(function($) {
  var host = document.location.host;
  if (host != "analizo.org" && host != "www.analizo.org") {
    $('.repository').each(function() {
      var html = $(this).html().replace('analizo.org', host);
      $(this).html(html);
    });
  }
});
