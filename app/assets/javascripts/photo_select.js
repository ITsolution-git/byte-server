$('.photo-select-btn').click(function(event) {
  var association = $(event.currentTarget).data().association;
  var photo_id = $(event.currentTarget).data().photoId;
  var fullpath = $(event.currentTarget).data().fullpath;
  var logopath = $(event.currentTarget).data().logopath;
  
  $(event.currentTarget).closest("form").find("#"+association+"_id").val(photo_id)
  $(event.currentTarget).closest("form").find("#"+association+"_display").html("<img src="+fullpath+"></img>")
  
  if(association === "logo"){
    $(event.currentTarget).closest("form").find("#modal_body").html("<img src="+logopath+"></img>")
  }

  $(event.currentTarget).closest(".modal").modal('hide');
  event.preventDefault();
});

$('.remove-photo-btn').click(function(event) {
  var association = $(event.currentTarget).data().association;
  console.log(association);
  $(event.currentTarget).closest("form").find("#"+association+"_id").val('')
  $(event.currentTarget).closest("form").find("#"+association+"_url").val(null)
  $(event.currentTarget).closest("form").find("#"+association+"_display").html("")
});
