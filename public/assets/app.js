$(document).ready(function () {
// will call refreshPartial every 5 seconds
  setInterval(refreshPartial, 15000)
});

// calls action refreshing the partial
function refreshPartial() {
  $.ajax({
    url: "/"
  });
  $(".container").load(location.href + " .container");
}
