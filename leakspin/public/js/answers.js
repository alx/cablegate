/*Tested by marcel*/

/*
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
*/

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
    }
  })
}

jQuery(document).bind('keydown', 'down', function(){
  var nextCable = jQuery(".current_cable").next('.cable:first');
  if(nextCable.lenght > 0){
    jQuery(".cable").removeClass("current_cable");
    nextCable.addClass("current_cable");
  } else {
    // refresh list
    var question_id = jQuery('#selectable_questions .selected').attr('id').split("-").pop();
    loadAnswerForQuestion(question_id);
  }
});

jQuery(document).bind('keyup', '1', function(){
  var controls = jQuery(".current_cable .metadata-control");
  var metadata_id = controls.attr('id').split('-').pop();
  setAnswerStatus(metadata_id, "valid");
  controls.find("a").removeClass('selected');
  controls.find("a.valid").addClass('selected');
});

jQuery(document).bind('keyup', '2', function(){
  var controls = jQuery(".current_cable .metadata-control");
  var metadata_id = controls.attr('id').split('-').pop();
  setAnswerStatus(metadata_id, "delete");
  controls.find("a").removeClass('selected');
  controls.find("a.delete").addClass('selected');
});


jQuery(document).ready(function(){
  
  jQuery("a.question-metadata").click(function(){
    var question_id = jQuery(this).attr('id').split("-").pop();
    loadAnswerForQuestion(question_id, 0);
    jQuery('#selectable_questions li').removeClass('selected');
    jQuery(this).addClass('selected');
  });
  
  jQuery("#more_metadatas").click(function(){
    var question_id = jQuery('#selectable_questions .selected').attr('id').split("-").pop();
    loadAnswerForQuestion(question_id);
  });
  
  jQuery(".cable").live("mouseover", function(){
    var fragment_id = jQuery(this).find("#fragment_id").val();
    jQuery(".current_cable").removeClass('current_cable');
    jQuery(this).addClass('current_cable');
    jQuery("#cable_panel pre").load('/fragments/' + fragment_id);
    jQuery("#cable_panel pre").css({'top': window.pageYOffset, 'position':'absolute'});
  });
});