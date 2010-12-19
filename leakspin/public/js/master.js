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
    jQuery('#spin_metadata_value').html(getSelectedText());
    jQuery('#spin_status').html("<a id='select_validate'>Click to validate selection</a>");
  }
}

function loadJsonSpin(){
  jQuery("#spin_status").html("Fetching spin from server..."); // Set new status
  jQuery.ajax({
    url: '/spin.json',
    dataType: 'json',
    success: function(data){
      
      jQuery("#cable_panel pre").html(data.fragment.content); // Load fragment content
      jQuery("#spin_fragment_id").val(data.fragment.id); // Save fragment id
      
      jQuery("#spin_question").html(data.question.content); // Load question content
      jQuery("#spin_question_id").val(data.question.id); // Save question id
      jQuery("#spin_metadata_name").val(data.question.metadata_name);
      
      jQuery("#spin_metadata_value").html(""); // Clean last answer
      
      jQuery("#spin_status").html("Please select text..."); // Set new status
    }
  });
}

function sendLeakSpin(){
  jQuery("#spin_status").html("Sending spin to server..."); // Set new status
  jQuery.ajax({
    url: '/spin',
    type: 'POST'
    data: {
      'metadata[name]': jQuery("#spin_metadata_name").val(),
      'metadata[value]': jQuery("#spin_metadata_value").html(),
      'fragment_id': jQuery("#spin_fragment_id").val(),
      'question_id': jQuery("#spin_question_id").val()
    },
    success: function(data){
      loadJsonSpin();
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

jQuery(document).bind('keydown', 's', function(){
  changeAnswerText()
});

jQuery(document).ready(function(){
  loadJsonSpin();
  
  jQuery("#select_validate").live('click', function(){
    sendLeakSpin();
  });
});