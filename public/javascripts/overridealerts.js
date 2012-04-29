/* Overriding Javascript's Confirm Dialog */

// NOTE; A callback must be passed. It is executed on "cotinue". 
//  This differs from the standard confirm() function, which returns
//   only true or false!

// If the callback is a string, it will be considered a "URL", and
//  followed.

// If the callback is a function, it will be executed.


function confirm(msg,callback) {
  $('#confirm')
    .jqmShow()
    .find('p.jqmConfirmMsg')
      .html(msg)
    .end()
    .find(':submit:visible')
      .click(function(){
        if(this.value == 'yes')
          (typeof callback == 'string') ?
            window.location.href = callback :
            callback();
        $('#confirm').jqmHide();
      });
}


$().ready(function() {
  $('#confirm').jqm({overlay: 88, modal: true, trigger: false});
  Cufon.replace('a.demo-close', {hover: true});
  // trigger a confirm whenever links of class alert are pressed.
  $('a.confirm').click(function() { 
    confirm('About to visit: '+this.href+' !',this.href); 
    return false;
  });
});