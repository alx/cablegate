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

function loadAnswerForQuestion(question_id, offset){
  jQuery.ajax({
    url: '/answers.json',
    type: 'GET',
    data: {
      question_id: question_id,
      offset: offset
    },
    dataType: 'json',
    success: function(data){
      
      var metadatas = [];

      jQuery.each(data.cables, function(index, cable){
        var html_cable = [];
        html_cable.push("Cable: " + cable.cable_id)
        jQuery.each(cable.metadatas, function(index, metadata){
          var html_metadata = [];
          html_metadata.push("<div class='metadata_value'>");
          html_metadata.push(metadata.value);
          html_metadata.push("</div><div id='metadata-" + metadata.id + "' class='radio_validation'>");
          html_metadata.push("<input type='radio' id='radio_valid_" + cable.cable_id + "' name='radio_validation' value='valid'");
          if (metadata.validated) html_metadata.push(" checked='checked'");
          html_metadata.push("/><label for='radio_valid_" + cable.cable_id + "'>Valid</label>");
          html_metadata.push("<input type='radio' id='radio_not_valid_" + cable.cable_id + "' name='radio_validation' value='not_valid'");
          if (!metadata.validated) html_metadata.push(" checked='checked'");
          html_metadata.push("/><label for='radio_not_valid_" + cable.cable_id + "'>Not Valid</label>");
          html_metadata.push("<input type='radio' id='radio_delete_" + cable.cable_id + "' name='radio_validation' value='delete'/>");
          html_metadata.push("<label for='radio_delete_" + cable.cable_id + "'>Delete</label></div>");
          html_cable.push(html_metadata.join(""));
        });  
        html_cable.push("<button class='display_cable' value='" + cable.cable_id + "'>Display Cable &#x2192;</button><hr/>");
        metadatas.push(html_cable.join(""));
      });
      
      jQuery("#metadata_list").append(metadatas.join(""));
      
      jQuery(".radio_validation").buttonset();
      jQuery(".display_cable").button();
      jQuery('#current_offset').val(offset);
    }
  })
}

jQuery(document).ready(function(){
  
  jQuery("li.question-metadata").click(function(){
    var question_id = jQuery(this).attr('id').split("-").pop();
    loadAnswerForQuestion(question_id, 0);
    jQuery('#selectable_questions li').removeClass('ui-selected');
    jQuery(this).addClass('ui-selected');
  });
  
  jQuery(".radio_validation").live('change', function(){
    var metadata_id = jQuery(this).parents(".radio_validation").attr('id').split('-').pop();
    var status = jQuery(this).val();
    setAnswerStatus(metadata_id, status);
  });
  
  jQuery("#more_metadatas").click(function(){
    var question_id = jQuery('#selectable_questions li.ui-selected').attr('id').split("-").pop();
    var offset = parseInt(jQuery('#current_offset').val()) + 10;
    loadAnswerForQuestion(question_id, offset);
  });
});