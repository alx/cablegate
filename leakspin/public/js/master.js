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

function changeAnswerText(){
  var selected = getSelectedText();
  if(selected != ""){
    jQuery('#spin_answer').html(getSelectedText());
    jQuery('#spin_answer').html("Validating...");
  }
}

function loadJsonSpin(){
  $.ajax({
    url: '/spin.json',
    dataType: 'json',
    success: function(data){
      
    }
  });
}

jQuery(function() {
    jQuery('#fragment_content').keypress(function(evt) {
      code= (evt.keyCode ? evt.keyCode : evt.which);
      if (code == 13) changeAnswerText();
      evt.preventDefault();
    });
});

$(document).bind('keydown', 's', function(){
  changeAnswerText()
});

$(document).ready(function(){
  loadJsonSpin();
});