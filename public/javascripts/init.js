$(function() {
  
  // Adjust the 'blog' link in main-nav to fit well with Cufon
  $('#header-nav a.blog').css({'margin-left' : '25px', 'padding-left' : '8px', 'padding-right' : '5px' }); //padding-right 4px in 'alternate'
  $('#header-nav.signedout').css({'width' : '421px', 'margin-left' : '89px', 'background-position' : '371px -52px' });
  // Adjust the signedin nav
  $('#header-nav.signedin').css({'width' : '452px', 'margin-left' : '59px' });
  $('#header-nav.signedin.notadmin').css({'width' : '373px', 'margin-left' : '139px' });
  $('#header-nav.signedin.globaladmin').css({'width' : '460px', 'margin-left' : '50px' });
  $('#header-nav.signedin.admin').css({'width' : '450px', 'margin-left' : '60px' });

  Cufon.replace('#header-nav a', {hover: true});
  
});

// Cufon initialization
Cufon.replace('#toppanel a', {hover: true});
Cufon.replace('p.cufonify a', {hover: true});
Cufon.replace('a.blue', {hover: true});
Cufon.replace('.recess-pitch h4', {hover: true});
Cufon.replace('h2:not(#subpage-header .top-header h2)');
Cufon.replace('#subheader h2');
Cufon.replace('#subpage-left h2 a', {hover: true});
Cufon.replace('#header-box h2');
Cufon.replace('h3:not(#webapp-modal h3)', {hover: true});
Cufon.replace('#cta h3 > a', {hover: true});
Cufon.replace('#quote p');
Cufon.replace('#quote cite', {hover: true});
Cufon.replace('.submit-button');
Cufon.replace('#promo h4');
Cufon.replace('#subpage-left h1');
Cufon.replace('button.search-button');
Cufon.replace('.cufonify');
Cufon.replace('.signedin h1');
Cufon.replace('.signedin h2');
Cufon.replace('.nav a', {hover: true});
Cufon.replace('h2.entry-title a', {hover: true});
Cufon.replace('a.demo-close', {hover: true});
Cufon.replace('.top-header h2 a', {hover: true});
//Cufon.replace('ul.waitlistButtons a', {hover: true});

$(function() {
  // Enable localScroll for smooth anchor links
  $.localScroll();

  // Animates position of jqModal closer to top of screen
  $('.view-demo, .demo-link, a.cover-image, a.tour, a.jqModal, a.webapp, a.offerModal').click(function(){
    $.scrollTo( {top:'100px', left:'0'}, 800 );
  });

  var slideshowLoad = function(hash){
    hash.w.css('opacity',0.94).show();
    // Loads the content. Turns out jqModal's handler was working fine...
    $(".slideshowContent").load("/demomodal", null, function() {
      // Modal slideshow gallery cycler
      $('#slideshow-gallery').after('<ul id="slideshow-nav"><li id="slideshow-caption"></li>').cycle({
        fx:     'fade',
        speed:  '400',
        timeout: 0,
        pager:  '#slideshow-nav',
        next:   '#slideshow-gallery img',
        after: onAfterSlideshow,

        // callback fn that creates a thumbnail to use as pager anchor
        pagerAnchorBuilder: function(idx, slide) {
            return '<li><a href="#"><img src="/images/slides/thumbs/' + $(slide).attr('src').split('/').slice(-1) + '" width="50" height="31" /></a></li>';
        }
      });

      function onAfterSlideshow(curr, next, opts) {
        $('#slideshow-caption').html('<h3>' + $(this).attr('caption') + '</h3>');
        Cufon.replace('#slideshow-caption h3', {hover: true});
        Cufon.replace('.recess-pitch h4', {hover: true});
        Cufon.replace('a.guillemot', {hover: true});
        $('.waiting').hide();
      }
    });
  };


  // Initialize jqModal
  $('#demo-modal').jqm({onShow:slideshowLoad});

  var expand = function(tab, e) {
   e.preventDefault();
    $("div#signupPanel").animate({height: "show"}, 'slow', 'swing');
    $.scrollTo("#toppanel", { 'duration' : '250' });
    $(tab + " .iframe-container").addClass("selected");
  };

  // Expand Panel
  $(".signup-open").click(function(e){ expand(".twoA", e); });
  $(".contact-open").click(function(e){ expand(".twoB", e); });
 
  // Collapse Panel
  $("#toppanel .close").click(function(e){
    e.preventDefault();
    $("div#signupPanel").animate({height: "hide"}, 'slow', 'swing');
    $(".twoA .iframe-container, .twoB .iframe-container").removeClass("selected");
   });
 
  // Switch buttons from "Signup, Contact" to "Close Panel" on click
  $("#toppanel li.close").hide();
  $("#toppanel li.toggleClose a, .contact-open, .signup-open").click(function() {
    $("#toppanel li.toggleClose").toggle();
    $("#toppanel li.toggleHide").toggle();
  });
 
  // Adds the selected class to the form container when clicked
  $(".twoA").mouseover(function() {
    $(".twoA .iframe-container").addClass("selected");
    $(".twoB .iframe-container").removeClass("selected");
  });
  $(".twoB").mouseover(function() {
    $(".twoB .iframe-container").addClass("selected");
    $(".twoA .iframe-container").removeClass("selected");
  });
 
  // Cyclers and galleries use the jQuery Cycler (http://malsup.com/jquery/cycle)
 
  // Gallery cycler
  $('#gallery')
    .after('<div id="gallery-nav" class="stripTransmitter">')
    .cycle({
      fx:     'fade',
      speed:  'fast',
      timeout: 0,
      pager:  '#gallery-nav',
      after:   onAfter
  });
 
  function onAfter() {
    $('#output').html('<h3>' + $(this).children("img").attr("alt") + '</h3>');
    // This is hacky - squeezes the images into the frame. Better to have more suitable images.
    $('li.mobile').css({ 'left' : '-100px' });
    $('li.customize').css({ 'left' : '-220px', 'top' : '-30px' });
    $('li.offer').css({ 'left' : '-180px' });
    $('li.locations').css({ 'top' : '-30px' });
  }

  // Quote cycler
  $('#quote').cycle({
    fx:     'fade',
    delay:  -1000
  });

  $('#quote').css({'overflow' : 'hidden', 'overflow-y' : 'hidden' });

  // The 'Take a Tour' button hover states
  $("a.demo-link, a.view-demo, .demo-link").hover(
    function () {
      $("a.view-demo").addClass("viewDemo-on");
  }, function() {
      $("a.view-demo").removeClass("viewDemo-on");
  });

  // Guillemots next to links. Hacky workaround thanks to IE not supporting :before pseudo-class.
  $('a.guillemot, p a:not(a.guillemot), .entry-content p a:not(a.guillemot), #primary-sidebar ul li a, #subpage-left ul li a:not(#gallery-nav a), #cta ul li.last-child a, .by-line a').prepend("<span class='guillemot'>&#187;</span>");
  $('.cta-subHeader a').prepend("<span>&#187;</span>");
  Cufon.replace('a.guillemot', {hover: true});
  Cufon.replace('#cta ul li.last-child a', {hover: true});
  Cufon.replace('.cta-subHeader a', {hover: true});
  
  // Adjusts positioning of guillemoted/Cufonified link
  $('#view-demo p.demo-link').css({'margin-left' : '0.75em' });
  $('#view-demo.subpage-tour p.demo-link').css({'margin-left' : '1.5em' });
  
  // Offer modal
  
  var hideWaiting = function(){ $('.waiting').hide(); };
  $('#offer-modal').jqm({ajax: '/front/wufoo_offer', modal: false, trigger: false, target: '.offerContent', onLoad:hideWaiting });  
  $(".offerModal").click(function () {
    $('#offer-modal').jqmShow();
  });
    
  $("a.webapp-popup").popup({
    width: 950,
    height: 520,
    titlebar: false,
    status: false,
    resizable: true,
    toolbar: false,
    scrollbars: false,
    menubar: false
  });
  
  // Tooltips
  
  // Show users which elements have helpful information
  $('.tip').append("<span class='ss_sprite ss_information' style='vertical-align: middle;'>&nbsp;</span>")
  
  // Adds q-tip tooltips to all title attributes
  $('[title]').qtip({
    style: { name: 'blue', tip: true, color: '#626262' },
    position: {
      corner: {
        target: 'topMiddle',
        tooltip: 'bottomMiddle'
      }
    }
  });

});