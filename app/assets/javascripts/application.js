//
//= require jquery
//= require jquery_ujs
//= require_tree .

$(function () {
  var jqconsole = $('#console').jqconsole('', '>> ');
  var startPrompt = function () {
    jqconsole.Prompt(true, function (input) {
      if (input == "clear") {
        jqconsole.Reset();
        startPrompt();
      } else {
        $.ajax({
          headers: {
            'X-Transaction': 'POST Example',
            'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
          },
          data: { command: input, commit: 'Execute' },
          url: '/tilde/command',
          type: 'post',
          dataType: 'json',
          success: function(e) {
            jqconsole.Write(e.response + '\n', 'jqconsole-output');
            startPrompt();
          }
        }); 
      }
    });
  };
  startPrompt();
 
  var open = true;
  $(document).keydown(function(e){
    if (e.keyCode == 192) { 
      open = !open
      $('#console').animate({
        top: open ? "0" : "-500"
      });
      return false;
    }
  });
 
}); 

