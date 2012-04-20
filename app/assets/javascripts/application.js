//
//= require jquery
//= require jquery_ujs
//= require_tree .

$(function () {
  var jqconsole = $('#console').jqconsole('', '>> ');
  var startPrompt = function () {
    jqconsole.Prompt(true, function (input) {
      jqconsole.Write(input + '\n', 'jqconsole-output');
      startPrompt();
    });
  };
  startPrompt();
}); 

