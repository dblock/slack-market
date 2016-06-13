$(document).ready(function() {
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
