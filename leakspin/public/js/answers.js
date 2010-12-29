/*Tested by marcel*/

function setAnswerStatus(metadata_id, status){
  jQuery.ajax({
    url: '/answers',
    type: 'POST',
    data: {
      metadata_id: metadata_id,
      status: status
    }
  });
  if(status == 'delete') jQuery("#metadata-" + metadata_id).remove();
}

function loadAnswerForQuestion(question_id){
  jQuery.ajax({
    url: '/answers.json',
    type: 'GET',
    data: {
      question_id: question_id
    },
    dataType: 'json',
    success: function(data){
      
      var metadatas = [];
      var firstCable = true;

      jQuery.each(data.metadatas, function(index, metadata){
        var html_metadata = [];
        html_metadata.push("<div class='cable ");
        if (firstCable == true){
          firstCable = false;
          html_metadata.push("current_cable");
        }
        html_metadata.push("' id='cable-");
        html_metadata.push(metadata.cable_id);
        html_metadata.push("'><input type='hidden' name='fragment_id' id='fragment_id' value='");
        html_metadata.push(metadata.fragment_id);
        html_metadata.push("'/><div id='metadata-");
        html_metadata.push(metadata.id);
        html_metadata.push("' class='metadata-control'><a class='valid'>1. Valid</a><br><a class='delete'>2. Delete</a></div>Cable: ");
        html_metadata.push(metadata.cable_id);
        html_metadata.push("<div class='metadata-value'>");
        html_metadata.push(metadata.value);
        html_metadata.push("</div></div>");
        metadatas.push(html_metadata.join(""));
      });
      
      jQuery("#metadata_list").html(metadatas.join(""));
      jQuery("#more_metadatas").html("Refresh (still " + data.question.progress.not_validated + ")");
      loadFragment();
    }
  })
}

function loadFragment(){
  jQuery("#cable_panel pre").load('/fragments/' + jQuery(".current_cable #fragment_id").val());
  jQuery("#cable_panel pre").css({'top': window.pageYOffset, 'position':'absolute'});
}

function switchCable(cable){
  if(cable.length > 0){
    jQuery(".cable").removeClass("current_cable");
    cable.addClass("current_cable");
    loadFragment();
  } else {
    // refresh list
    var question_id = jQuery('#selectable_questions .selected').attr('id').split("-").pop();
    loadAnswerForQuestion(question_id);
  }
}

function controlCable(action){
  var controls = jQuery(".current_cable .metadata-control");
  var metadata_id = controls.attr('id').split('-').pop();
  setAnswerStatus(metadata_id, action);
  controls.find("a").removeClass('selected');
  controls.find("a." + action).addClass('selected');
}

jQuery(document).bind('keydown', 'up', function(){
  switchCable(jQuery(".current_cable").prev('.cable:first'));
});

jQuery(document).bind('keydown', 'down', function(){
  switchCable(jQuery(".current_cable").next('.cable:first'));
});

jQuery(document).bind('keyup', '1', function(){
  controlCable("valid");
});

jQuery(document).bind('keyup', '2', function(){
  controlCable("delete");
});


jQuery(document).ready(function(){
  
  jQuery("a.question-metadata").click(function(){
    var question_id = jQuery(this).attr('id').split("-").pop();
    loadAnswerForQuestion(question_id, 0);
    jQuery('#selectable_questions a').removeClass('selected');
    jQuery(this).addClass('selected');
  });
  
  jQuery("#more_metadatas").click(function(){
    var question_id = jQuery('#selectable_questions .selected').attr('id').split("-").pop();
    loadAnswerForQuestion(question_id);
  });
  
/*  jQuery(".metadata-value").editable('/metadatas', {
    name: 'value',
    submitdata: {
      id: jQuery(this).parents('div').siblings('.metadata-control').attr('id').split("-").pop()
    }
  });*/
});