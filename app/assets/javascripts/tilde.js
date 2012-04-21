//
//= require jquery
//= require jquery_ujs

$(function () {
  var $tilde = $('#tilde');
  var tildeconsole = $tilde.jqconsole('', '>> ');

  var specialCommands = {
    "clear": function(){
      tildeconsole.Reset();
      startPrompt();
    }
  }

  var startPrompt = function () {
    tildeconsole.Prompt(true, function (input) {
      if (input in specialCommands) {
        specialCommands[input]();
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
          error: function(e) {
            tildeconsole.Write('There was an error with your request: ' + e.response + '\n', 'jqconsole-error');
            startPrompt();
          }
        });
      }
    });
  };
  startPrompt();

  var open = false;
  $(document).keydown(function(evt){
    if (evt.which == $tilde.data('key')) {
      $tilde.toggleClass('active');
      if ($tilde.hasClass('active')) {
        tildeconsole.Focus();
      }
      return false;
    }
  });

});

