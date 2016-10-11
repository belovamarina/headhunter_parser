// $.ajax({
//     url:'/grab_vacancies',
//     data: params,
//     type:'POST',
//     beforeSend: function() {
//         alert("loading")
//     },
//     success:function(html){ alert(html) }
// });


$(document).ready(function () {
// will call refreshPartial every 15 seconds
    setInterval(refreshPartial, 15000)

});

// calls action refreshing the partial
function refreshPartial() {
  $.ajax({
    url: "/"
 })
}
