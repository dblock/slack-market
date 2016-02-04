var SlackMarket = {};

$(document).ready(function() {

  SlackMarket.message = function(text) {
    $('#messages').fadeOut('slow', function() {
      $('#messages').fadeIn('slow').html(text)
    });
  };

  SlackMarket.error = function(xhr) {
    try {
      var message;
      if (xhr.responseText) {
        var rc = JSON.parse(xhr.responseText);
        if (rc && rc.message) {
          message = rc.message;
          if (message == 'invalid_code') {
            message = 'The code returned from the OAuth workflow was invalid.'
          } else if (message == 'code_already_used') {
            message = 'The code returned from the OAuth workflow has already been used.'
          }
        }
      }

      SlackMarket.message(message || xhr.statusText || xhr.responseText || 'Unexpected Error');

    } catch(err) {
      SlackMarket.message(err.message);
    }
  };

  // Slack OAuth
  var code = $.url('?code')
  if (code) {
    SlackMarket.message('Working, please wait ...');
    $('#register').hide();
    $.ajax({
      type: "POST",
      url: "/api/teams",
      data: {
        code: code
      },
      success: function(data) {
        SlackMarket.message('Team successfully registered!<br><br>DM <b>@market</b> or create a <b>#channel</b> and invite <b>@market</b> to it.');
      },
      error: SlackMarket.error
    });
  }
});
