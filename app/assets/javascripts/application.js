//
//= require jquery
//= require jquery_ujs
//= require_tree .

$(function () {
  var jqconsole = $('#console').jqconsole('', '>> ');
  var startPrompt = function () {
    jqconsole.Prompt(true, function (input) {
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
        }
      }); 
      startPrompt();
    });
  };
  startPrompt();
}); 

$(document).keydown(function(e){
  if (e.keyCode == 192) { 
    $('#console').slideToggle();
    return false;
  }
});

