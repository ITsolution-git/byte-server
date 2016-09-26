$(document).ready(function() {

  /* restaurant-types page */

  $("#restaurant-types img").on("click", function(){
    console.log('test');
    $("#restaurant-types img").removeClass('selected');
    $(this).addClass('selected');
    $("#user_restaurant_type").val($(this).data('type'));
  })  

  if ($("#user_restaurant_type").val() != "") {
    value = $("#user_restaurant_type").val()
    $("#restaurant-types img[data-type='" + value + "']").addClass('selected')
  }

  /* credit card page */
  $('#user_autofill').click(function() {
    $('#sameAddr').val(this.checked)
    if (this.checked) $('#billing_address_wrapper').hide();
    else $('#billing_address_wrapper').show();
  })
  
});
