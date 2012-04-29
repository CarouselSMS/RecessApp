$(document).ready(function(){

  $('ul.waitlistButtons li a').click(function(){
    $('ul.waitlistButtons li a').removeClass('active');
    link_id = $(this).attr('id');
    $(document).queue("ajaxRequests", function(){
      $.get('/guests/'+ link_id, {}, function(data){
        $('#guest-list').html(data);
        $('#guest-details').html('');
        $(document).dequeue("ajaxRequests");
        refresh_dom();
      });
    });
    $(document).dequeue("ajaxRequests");
    $(this).addClass('active');
  });

  function ajaxPoller()
  {
    var active = $('ul.waitlistButtons li a.active:first');
    var guest  = $('#guest_id')
    $(document).queue("ajaxRequests", function(){
      $.getScript('/guests/all?poll=true&type='+ active.attr('id') + '&guest_id=' + guest.attr('value'), function(){
        $(document).dequeue("ajaxRequests");
      });
    });
    $(document).dequeue("ajaxRequests");
   }

  var hold = setInterval(ajaxPoller, 10000);

  $('td.guest-info').click(function(){
    var href = $(this).find('a.show-guest').attr('href');
    $(document).queue("ajaxRequests", function(){
      $.get(href, {}, function(data){
        $('#guest-details').html(data);
        $('#details-container').effect('highlight', {color: '#FBB51F'}, 1000);
        $(document).dequeue("ajaxRequests");
      });
    });
    $('tr.guest').removeClass('selected');
    $('tr.e').removeClass('e').addClass('even');
    var tr = $(this).parents().filter('tr');
    if(tr.hasClass('even')){
      tr.removeClass('even').addClass('e');
    }
    tr.addClass('selected');
    $(document).dequeue("ajaxRequests");
    return false;
  });

});

var refresh_dom = function(){
  $('td.guest-info').click(function(){
    var href = $(this).find('a.show-guest').attr('href');
    $(document).queue("ajaxRequests", function(){
      $.get(href, {}, function(data){
        $('#guest-details').html(data);
        $('#details-container').effect('highlight', {color: '#FBB51F'}, 500);
        $(document).dequeue("ajaxRequests");
      });
    });
    $(document).dequeue("ajaxRequests");
    $('tr.guest').removeClass('selected');
    $('tr.e').removeClass('e').addClass('even');
    var tr = $(this).parents().filter('tr');
    if(tr.hasClass('even')){
      tr.removeClass('even').addClass('e');
    }
    tr.addClass('selected');
    return false;
  });
}

$(document).dequeue("ajaxRequests");


jQuery(function($){
   $("#phone-number").mask("(999) 999-9999");
});