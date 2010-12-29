function createPeople(name, metadata_id){
  jQuery.ajax({
    url: '/people',
    type: 'POST',
    data: {
      'name': name,
      'metadata_id': metadata_id
    },
    success: function(data){
      var new_people = [];
      new_people.push("<li class='people' id='people-");
      new_people.push(data.people.id);
      new_people.push("'>");
      new_people.push(data.people.name);
      new_people.push("<ul  class='metadata-list>");
      jQuery.each(data.people.metadatas, function(index, metadata){
        new_people.push("<li class='people-metadata' id='people-metadata-");
        new_people.push(metadata.id);
        new_people.push("'>");
        new_people.push(metadata.value);
        new_people.push("</li>");
      });
      new_people.push("</ul></li>");
      jQuery('#people_list').append(new_people.join(""));
    }
  });
}

function updatePeople(people, name, metadata_id){
  jQuery.ajax({
    url: '/people',
    type: 'POST',
    data: {
      'people_id': people.attr('id').split("-").pop(),
      'name': name,
      'metadata_id': metadata_id
    },
    success: function(data){
      var new_people = [];
      jQuery.each(data.people.metadata, function(index, metadata){
        new_people.push("<li class='people-metadata' id='people-metadata-");
        new_people.push(metadata.id);
        new_people.push("'>");
        new_people.push(metadata.value);
        new_people.push("</li>");
      });
      people.find('.metadata-list').html(new_people.join(""));
    }
  });
}

jQuery(document).ready(function(){
  jQuery('.create_people').live('click', function(){
    var metadata = jQuery(this).parents('li');
    var name = metadata.find('.metadata-value').html();
    var metadata_id = metadata.attr('id').split("-").pop();
    createPeople(name, metadata_id);
  });
  
  jQuery('.people').live('click', function(){
    var people = jQuery(this);
    var metadata = jQuery('li.selected');
    var name = metadata.find('.metadata-value').html();
    var metadata_id = metadata.attr('id').split("-").pop();
    updatePeople(people, name, metadata_id);
  });
  
  jQuery('.metadata').live('mouseover', function(){
    jQuery('.metadata').removeClass('selected');
    jQuery(this).addClass('selected');
  });
});