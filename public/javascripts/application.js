$(document).ready(function(){
  $('#stories').sortable({
    axis:   'y',
    handle: '.index',
    update: function(event, ui){
      $('#stories .index').each(function(index){
        $(this).html("#" + (index + 1))
      })
    }
  })
})