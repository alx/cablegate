/*Tested by sandrine :-*/

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
    jQuery('#spin_status').html("<a id='select_validate'>Validate selection</a>");
  }
}

function loadJsonSpin(){
  jQuery("#spin_status").html("Fetching spin from server..."); // Set new status
  jQuery.ajax({
    url: '/spin.json',
    dataType: 'json',
    success: function(data){
      
      var fragment = data.fragment;
      var question = data.question;
      
      jQuery("#cable_panel pre").html(fragment.content); // Load fragment content
      jQuery("#spin_fragment_id").val(fragment.id); // Save fragment id
      jQuery("#spin_permalink a").attr("href", "http://git.tetalab.org/index.php/p/cablegate/source/tree/master/cables/" + fragment.cable.id + ".txt");
      
      jQuery("#spin_question").html(question.content); // Load question content
      jQuery("#spin_question_help").html(question.help); // Load question help
      jQuery("#spin_question_id").val(question.id); // Save question id
      jQuery("#spin_metadata_name").val(question.metadata_name);
      
      jQuery("#spin_metadata_value").html(""); // Clean last answer
      
      jQuery("#spin_status").html("Please select text..."); // Set new status
      
      // Set progress
      var progress = question.progress;
      var progress_percent = Math.round(progress.total_answers * 100 / progress.total_cables);
      jQuery("#progress").html("<a href='/answers'>" + progress.total_answers + "</a>/" + progress.total_cables + " cables");
      jQuery("#progressbar").progressbar( "value" , progress_percent )
    }
  });
}

function sendLeakSpin(value){
  jQuery("#spin_status").html("Sending spin to server..."); // Set new status
  jQuery.ajax({
    url: '/spin',
    type: 'POST',
    data: {
      'metadata[name]': jQuery("#spin_metadata_name").val(),
      'metadata[value]': value,
      'fragment_id': jQuery("#spin_fragment_id").val(),
      'question_id': jQuery("#spin_question_id").val()
    },
    success: function(data){
      loadJsonSpin();
    }
  });
}

jQuery(document).bind('mouseup', function(){
  changeAnswerText();
});

jQuery(document).bind('keydown', 'enter', function(){
  if(jQuery('#spin_metadata_value').html().length > 0) sendLeakSpin(jQuery("#spin_metadata_value").html());
});

jQuery(document).ready(function(){
  loadJsonSpin();
  
  jQuery( "#progressbar" ).progressbar();
  
  jQuery("#no_answer").live('click', function(){
    sendLeakSpin('no answer');
  });
  
  jQuery("#select_validate").live('click', function(){
    sendLeakSpin(jQuery("#spin_metadata_value").html());
  });
  
  jQuery("#next_question").live('click', function(){
    loadJsonSpin();
  });
});