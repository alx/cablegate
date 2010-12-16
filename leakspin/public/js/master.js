function changeAnswerText(){
  var selected = getSelectedText();
  if(selected != ""){
    jQuery('#spin_answer').html(getSelectedText());
    jQuery('#spin_answer').html("Validating...");
  }
}

$(document).bind('keydown', 's', function(){
  changeAnswerText()
});

jQuery(function() {
    jQuery('#fragment_content').keypress(function(evt) {
      code= (evt.keyCode ? evt.keyCode : evt.which);
      if (code == 13) changeAnswerText();
      evt.preventDefault();
    });
});

// Get user selection text on page
function getSelectedText() {
    if (window.getSelection) {
        return window.getSelection().toString();
    }
    else if (document.selection) {
        return document.selection.createRange().text;
    }
    return '';
}