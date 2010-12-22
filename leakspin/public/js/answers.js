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
        html_cable.push("<div class='cable' id='cable-" + cable.cable_id + "'>Cable: " + cable.cable_id);
        jQuery.each(cable.metadatas, function(index, metadata){
          var html_metadata = [];
          html_metadata.push("<div class='metadata_value'>");
          html_metadata.push(metadata.value);
          html_metadata.push("(<a rel='fragment_");
          html_metadata.push(metadata.fragment_id);
          html_metadata.push("'>display</a>)</div><div id='metadata-" + metadata.id + "' class='metadata-control'>");
          html_metadata.push("<a class='valid");
          if (metadata.validated) html_metadata.push(" selected");
          html_metadata.push("'>Valid</a>");
          html_metadata.push("<a class='not_valid");
          if (!metadata.validated) html_metadata.push(" selected");
          html_metadata.push("'>Not Valid</a><a class='delete'>Delete</a>");
          html_cable.push(html_metadata.join(""));
        });  
        html_cable.push("</div><hr/>");
        metadatas.push(html_cable.join(""));
      });
      
      jQuery("#metadata_list").append(metadatas.join(""));
      jQuery('#current_offset').val(offset);
    }
  })
}

jQuery(document).ready(function(){
  
  jQuery("li.question-metadata").click(function(){
    var question_id = jQuery(this).attr('id').split("-").pop();
    loadAnswerForQuestion(question_id, 0);
    jQuery('#selectable_questions li').removeClass('selected');
    jQuery(this).addClass('selected');
  });
  
  jQuery("a.valid").live("click", function(){
    var controls = jQuery(this).parents(".metadata-control");
    var metadata_id = controls.attr('id').split('-').pop();
    setAnswerStatus(metadata_id, "valid");
    controls.find("a").removeClass('selected');
    jQuery(this).addClass('selected');
  });
  
  jQuery("a.not_valid").live("click", function(){
    var controls = jQuery(this).parents(".metadata-control");
    var metadata_id = controls.attr('id').split('-').pop();
    setAnswerStatus(metadata_id, "not_valid");
    controls.find("a").removeClass('selected');
    jQuery(this).addClass('selected');
  });
  
  jQuery("a.delete").live("click", function(){
    var metadata_id = jQuery(this).parents(".metadata-control").attr('id').split('-').pop();
    setAnswerStatus(metadata_id, "delete");
    jQuery(this).parents(".cable").remove();
  });
  
  jQuery("#more_metadatas").click(function(){
    var question_id = jQuery('#selectable_questions li.ui-selected').attr('id').split("-").pop();
    var offset = parseInt(jQuery('#current_offset').val()) + 10;
    loadAnswerForQuestion(question_id, offset);
  });
});