/*Tested by marcel*/

function setAnswerStatus(answer_id, status){
  jQuery.ajax({
    url: '/answers',
    type: 'POST',
    data: {
      answer_id: answer_id,
      status: status
    }
  });
  if(status == 'delete') jQuery("#answer-" + answer_id).remove();
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
      
      var answers = [];

      jQuery.each(data.cables, function(index, cable){
        var html_cable = [];
        html_cable.push("Cable: " + cable.cable_id)
        jQuery.each(cable.metadatas, function(index, metadata){
          var html_answer = [];
          html_answer.push("<p>");
          html_answer.push(metadata.value);
          html_answer.push("</p><div id='answer-" + metadata.id + "' class='radio_validation'>");
          html_answer.push("<input type='radio' id='radio_valid' name='radio_validation' value='valid'");
          if (metadata.validated) html_answer.push(" checked='checked'");
          html_answer.push("/><label for='radio_valid'>Valid</label>");
          html_answer.push("<input type='radio' id='radio_not_valid' name='radio_validation' value='not_valid'");
          if (!metadata.validated) html_answer.push(" checked='checked'");
          html_answer.push("/><label for='radio_not_valid'>Not Valid</label>");
          html_answer.push("<input type='radio' id='radio_delete' name='radio_validation' value='delete'/>");
          html_answer.push("<label for='radio_delete'>Delete</label></div>");
          html_cable.push(html_answer.join(""));
        });  
        html_cable.push("<button class='display_cable' value='" + cable.cable_id + "'>Display Cable &#x2192;</button><hr/>");
        answers.push(html_cable.join(""));
      });
      
      jQuery("#answer_list").append(answers.join(""));
      
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
    var answer_id = jQuery(this).parents(".radio_validation").attr('id').split('-').pop();
    var status = jQuery(this).val();
    setAnswerStatus(answer_id, status);
  });
  
  jQuery("#more_answers").click(function(){
    var question_id = jQuery('#selectable_questions li.ui-selected').attr('id').split("-").pop();
    var offset = parseInt(jQuery('#current_offset').val()) + 10;
    loadAnswerForQuestion(question_id, offset);
  });
});