//
//= require jquery
//= require jquery_ujs

$(function () {
  var $tilde = $('#tilde');
  var tildeconsole = $tilde.jqconsole('', '>> ');
  var startPrompt = function () {
    tildeconsole.Prompt(true, function (input) {
      if (input == "clear") {
        tildeconsole.Reset();
        startPrompt();
      } else {
        $.ajax({
          headers: {
            'X-Transaction': 'POST Example',
            'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
          },
          data: { command: input, commit: 'Execute' },
          url: $tilde.data('commandUrl'),
          type: 'post',
          dataType: 'json',
          success: function(e) {
            tildeconsole.Write(e.response + '\n', 'jqconsole-output');
            startPrompt();
          },
          failure: function(e) {
            tildeconsole.Write('There was an error with your request' + '\n', 'jqconsole-output');
          }
        });
      }
    });
  };
  startPrompt();

  var open = false;
  $(document).keydown(function(evt){
    if (evt.which == 192) {
      open = !open
      $tilde.animate({
        top: open ? "0" : "-505"
      });
      tildeconsole.Focus();
      return false;
    }
  });

});

