var value = 0;
$(document).on("click", ".rotate_photo:not(.waiting)", function(){
  console.log('ROTATE');
  var angle_field = $(this).closest("form").find("#photo_angle");
  var orientation = parseInt($(this).closest("form").find("#orientation").val()) || 0;
  var a = parseInt(angle_field.val());
  if(isNaN(a)){
    value = 0
  }else {
    value = a;
  }

  value +=90;

  if(value > 360){
    value = 90;
  }

  angle_field.val(value);
  $(".img-item-preview img").rotate({ angle:value - orientation});
});

$(document).on('click', '.crop-btn a', function() {
  image_preview = $("#myModal_photo_form");
  console.log(image_preview);
  image_preview.find("img").attr("src", image_preview.find("img").attr("src"));
  $.get(image_preview.find("img").attr("src"), function(){
    image_preview.find("img").attr("src", image_preview.find("img").attr("src"));

    image_preview.find("img").attr("src", image_preview.find("img").attr("src"));
    if(!$("#myModal_photo_form").hasClass('in')){
      image_preview.modal();
    }
  });
  return false;
});
