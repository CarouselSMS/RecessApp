// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
if(!Array.indexOf) {
  Array.prototype.indexOf = function(obj) {
    for (var i = 0; i < this.length; i++) if (this[i]==obj) return i;
	  return -1;
  }
}

$.fn.send_test_offer = function(phone_id, status_id) {
  var action = "send_test_offer";
  var phone  = $(phone_id);
  var status = $(status_id);
  return this.each(function() {
    var btn = $(this);
    btn.click(function(e) {
      e.preventDefault();

      btn[0].disabled = true;
      status.value = "";
      $.post("/messages/" + action, {
        authenticity_token: window._token,
        phone_number: phone[0].value,
        "offer[name]":    $("#offer_name")[0].value,
        "offer[text]":    $("#offer_text")[0].value,
        "offer[details]": $("#offer_details")[0].value
      }, function(data) {
        btn[0].disabled = false;
        status.text("");
        status.show();
        status.text(data);
        status.fadeOut(7000);
      });
    });
  });
};

$.fn.send_test_message = function(action, phone_id, status_id) {
  var phone  = $(phone_id);
  var status = $(status_id);
  return this.each(function() {
    var btn = $(this);
    btn.click(function(e) {
      e.preventDefault();

      btn[0].disabled = true;
      status.value = "";
      $.post("/messages/" + action, {
        authenticity_token: window._token,
        phone_number: phone[0].value,
        "account[offer_id]":           $("#account_offer_id")[0].value,
        "account[conf_prepend_venue]": $("#account_conf_prepend_venue")[0].checked,
        "account[conf_message]":       $("#account_conf_message")[0].value,
        "account[page_append_sub]":    $("#account_page_append_sub")[0].checked,
        "account[page_prepend_venue]": $("#account_page_prepend_venue")[0].checked,
        "account[page_message]":       $("#account_page_message")[0].value
      }, function(data) {
        btn[0].disabled = false;
        status.text("");
        status.show();
        status.text(data);
        status.fadeOut(7000);
      });
    });
  });
};
 
$.fn.message_editor = function(is_conf, venue_name) {
  var prepend = $(is_conf ? "#account_conf_prepend_venue" : "#account_page_prepend_venue");
  var preview = $(is_conf ? "#conf_preview" : "#page_preview");
  var append  = is_conf ? false : $("#account_page_append_sub");
  var offer   = $("#account_offer_id");
  
  if (venue_name.length > 20) venue_name = venue_name.substr(0, 20);

  return this.each(function() {
    var message = $(this);

    var update_preview = function() {
      // Venue name
      var str = prepend[0].checked && venue_name.length > 0 ? venue_name + ": " : "";
      
      // Message
      str += message[0].value;
      
      // Offer or SUB
      var offer_text = "";
      var option = offer.find("option[value=" + offer[0].value + "]");
      if (option) offer_text = option.attr('offer');
      
      // Replace offer with SUB if 
      var offer_present = offer_text.length > 0;
      if (!is_conf) {
        if (append[0].checked) offer_text = "Reply SUB for special offers!"; else offer_text = "";
      }

      // Offer
      if (str.length > 0 && offer_text.length > 0) str += "\n";
      if (offer_text.length > 30) offer_text = offer_text.substr(0, 30);
      str += offer_text;

      if (str.length > 0) str += "\n";
      
      // Footer
      if (offer_present) str += "Txt M for more";
      if (is_conf) {
        if (offer_present) str += ", ";
        str += "HELP for help\nMsg&data rates may apply\nBy recessapp.com";
      } else {
        if (offer_present) str += "\n";
        str += "Waitlist offers by recessapp.com";
      }
      
      preview[0].value = str;
      preview.trigger('change');
    };
  
    update_preview();

    message.change(update_preview).keyup(update_preview);
    prepend.change(update_preview).keyup(update_preview);
    if (offer) offer.change(update_preview).keyup(update_preview);
    if (append) append.change(update_preview).keyup(update_preview);
  });
}

$.fn.sms_field = function(opts) {
  // Default options
  var defaults   = {
    part_size:    160,   // number of characters in the part
    part_warning: true,  // TRUE to show warning when the part boundary is reached
    multipart:    true   // TRUE to show the number of parts in the message
  };
  var options = $.extend(defaults, opts);
  
  // ISO-8951-1 set (without 0x20-0x7f range)
  var iso_8951_1 = [ 0x0a, 0x0d, 0xa1, 0xa4, 0xa5, 0xa7, 0xbf, 0xc4, 0xc5, 0xc6, 0xc7, 0xc9, 0xd1, 0xd6, 0xd8,
                     0xdc, 0xdf, 0xe0, 0xe4, 0xe5, 0xe6, 0xe8, 0xe9, 0xec, 0xf1, 0xf2, 0xf6, 0xf8, 0xf9, 0xfc ];

  // Checks character against the table of iso-8951-1 codes + ranges
  var valid_char = function(char) {
    return (char > 0x1f && char < 0x80) || iso_8951_1.indexOf(char) != -1;
  };
  
  // Checks text against SMS field rules
  var check_content = function(text) {
    for (var i = 0; i < text.length; i++) {
      if (!valid_char(text.charCodeAt(i))) return "Invalid character: " + text.charAt(i);
    }
    return false;
  };
  
  var gsm_length = function(text) {
    return text.length + text.replace(/[^\{\}\\\[\]~\^€\|]/g, '').length;
  };
  
  return this.each(function() {
    // add meta-line
    var textarea = $(this);
    var meta     = $('<div class="sms-meta"><span class="counter"></span>&nbsp;characters<span class="parts"></span>&nbsp;&nbsp;&nbsp;<span class="errors"></span></div>').insertAfter(textarea);
    var counter  = meta.find(".counter");
    var errors   = meta.find(".errors");
    var parts    = meta.find(".parts");

    // install meta-updater
    var update_meta = function() {
      var text    = textarea[0].value;
      var invalid = check_content(text);

      // Let the counter show 160/160 instead of 0/160
      var char_count = options.multipart ? gsm_length(text) % options.part_size : gsm_length(text);
      if (char_count == 0 && text.length > 0) char_count = options.part_size;
      
      counter.html(char_count.toString() + "/" + options.part_size.toString());
      errors.html(invalid);

      if (invalid) textarea.addClass('sms-field-error'); else textarea.removeClass('sms-field-error');
      if (!options.multipart && char_count > options.part_size) counter.addClass('sms-field-error'); else counter.removeClass('sms-field-error');
      
      if (options.multipart) {
        var part_count = Math.ceil(text.length / options.part_size);

        if (options.part_warning && part_count > 1) textarea.addClass('sms-field-warning'); else textarea.removeClass('sms-field-warning');

        if (part_count == 0) part_count = 1;
        parts.html("; " + part_count.toString() + " part" + (part_count == 1 ? "" : "s"));
      }
    };
    
    textarea.change(update_meta).keyup(update_meta);
    update_meta();
  });
}

$.fn.domain_field = function() {
 return this.each(function() {
   var input = $(this);
   var update_domain = function() {
     var val = input.val();
     var val2 = val.replace(/[^a-zA-Z0-9_-]/g, '')
     if (val != val2) {
       input.val(val2);
       val = val2;
     }
     $('span.domain').each(function() { $(this).text(val); });
   };
   input.change(update_domain).keyup(update_domain);
   update_domain();
 });
}

$.fn.company_name = function(domain_field_id) {
 return this.each(function() {
   var cn = $(this);
   var df = $(domain_field_id);
   var old = df.val();
   var update_domain = function() {
     var val = cn.val().toLowerCase().replace(/[^a-z0-9_-]/g, '-').replace(/-+/g, '-').replace(/(^-+|-+$)/g, '');
     if (old == df.val()) {
       df.val(val);
       old = val;
     }
     $('span.domain').each(function() { $(this).text(val); }); 
   }
   cn.change(update_domain).keyup(update_domain);
   update_domain();
 });
}

$(function() {
  $ = jQuery; // Some script undefines '$', get it back
  
  $("textarea.sms-field").sms_field();
  $("textarea.sms-field-sp").sms_field({ multipart: false });
});

