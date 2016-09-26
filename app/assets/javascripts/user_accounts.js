var UserAccountForm = (function($) {
  "user strict";
  var UserAccountForm = function(data) {
    var self = this;
    this.modelName = 'user_account';
    this.checkAllUsers = function(target) {
      console.log('testvao')
      if(target.checked) { // check select status
        $('.check_user_account').each(function() { //loop through each checkbox
          this.checked = true;  //select all checkboxes with class "check_user_account"
        });
        }else{
          $('.check_user_account').each(function() { //loop through each checkbox
            this.checked = false; //deselect all checkboxes with class "check_user_account"
          });
        }
    };
    this.changeCheckedAllUser = function(target){
      var ids_count = 0
      var ids =[]
      $('.check_user_account:checked').each(function() {
        ids.push($(this).val());
      });
      ids_count = ids.length
      check_user_count = $('.check_user_account').length
        // console.log(check_user_count);
        // console.log(ids_count);
      if (ids_count == check_user_count){
         document.getElementById('check_all_user').checked = true;
      }else{
         document.getElementById('check_all_user').checked = false;
      }
    };

  };
  return UserAccountForm;
})($);

$(document).ready(function() {
  var user_account = new UserAccountForm();
  $(document).on('click', '#check_all_user', function (event) {
    user_account.checkAllUsers(this);
  });
  $(".check_user_account").on('click', function(){
    user_account.changeCheckedAllUser(this);
  });
});

$(document).on("change", "#user_status", function(){
    var selectd_val = $(this).val();
    $.ajax({
      url: "/user_accounts/change_user_status",
      dataType: "html",
      data: {id: selectd_val},
      success: function(data) {
        if(!(data == "false")){
          console.log(".user_status_"+selectd_val);
          $(".user_status_"+selectd_val.split("_")[0]).html(data);
        }
      }
    });
});

$(document).on("click", ".submit_change_passowrd", function(event){
  event.preventDefault();
  var new_password = $("#user_new_password").val();
  var confirm_password = $("#user_confirm_password").val();
  var serializedData = $("#user_change_password").serialize();
  if(new_password != "" && confirm_password != "" && confirm_password == new_password){
    $.ajax({
      url: "/user_accounts/change_user_password",
      dataType: "html",
      type: "post",
      data: serializedData,
      success: function(data) {
        $("#password_message").html(data);
      }
    });
  }
  else
  {
    alert("Confirm password does not match.");
  }
});

$(document).on("click", ".submit_change_email", function(event){
  event.preventDefault();
  var new_email = $("#user_user_new_email").val();
  var confirm_email = $("#user_user_new_email_confirm").val();
  var serializedData = $("#user_change_email").serialize();
  if(new_email != "" && confirm_email != "" && confirm_email == new_email){
    $.ajax({
      url: "/user_accounts/change_user_email",
      dataType: "script",
      type: "post",
      data: serializedData
    });
  }
  else
  {
    alert("Confirm email does not match!");
  }
});

$(document).on("click", "#change_passowrd_model", function(event){
  $('#tooltip_account').modal('hide');
  $(".bs-example-modal-sm").modal("show");
  $("#user_name_restaurant").val($(this).data("location-name"));
  $("#user_name_restaurant").prop('disabled', true);
  $("#user_user_id").val($(this).data("user-id"));
});

$(document).on('click', '#change-email-model', function(event){
  $('#tooltip_account').modal('hide');
  $('#new-password-modal').modal('show');
  $('#user_user_id_email').val($(this).data('user-id'));
});

$(document).on("change", "select#user_location_id", function(event){
  var selectd_location_id = $(this).val();
  $("#user_location_id").val(selectd_location_id);
  if(selectd_location_id != ""){
    $.ajax({
      url: "/user_accounts/move_location_to_new_user",
      dataType: "html",
      type: "get",
      data: {location_id: selectd_location_id},
      success: function(data) {
        $('#tooltip_account').modal('hide');
        $("#move_location_account").modal("show");
        $("#pop_move_location").html(data);
      }
    });
  }else{
    alert("Restaurant should not be blank");
  }
});

$(document).on("click", "#account_setting_btn", function(event){
  var user_id = $(this).attr("data-user_id");
  if(user_id != ""){
    $.ajax({
      url: "/user_accounts/account_setting",
      dataType: "html",
      type: "get",
      data: {id: user_id},
      success: function(data) {
        $("#tooltip_account").modal("show");
        $("#pop_account_setting").html(data);
      }
    });
  }
});

$(document).on("click", ".submit_move_location", function(event){
  event.preventDefault();
  var new_password = $("#user_move_new_password").val();
  var confirm_password = $("#user_move_confirm_password").val();
  var username = $("#user_move_username").val();
  var email = $("#user_move_email").val();
  var credit_card_type = $("#user_move_credit_card_type").val();
  var credit_card_holder_name = $("#user_move_credit_card_holder_name").val();
  var credit_card_number = $("#user_move_credit_card_number").val();
  var credit_card_expiration_date = $("#user_move_credit_card_expiration_date").val();
  var credit_card_cvv = $("#user_move_credit_card_cvv").val();
  var serializedData = $("#new_user_with_location").serialize();
  var $this = $(this);
  if(credit_card_cvv != "" && credit_card_expiration_date != "" && credit_card_number != "" && credit_card_holder_name != "" && credit_card_type != "" && new_password != "" && confirm_password != "" && username != "" && email != "" && new_password == confirm_password){
    $this.html("Loading...");
    $.ajax({
      url: "/user_accounts/new_user_with_location",
      dataType: "html",
      type: "post",
      data: serializedData,
      success: function(data) {
        $this.html("Submit");
        $("#move_location_account").modal("hide");
        $(".flash_messages").html("<div class='flash_messages'><div class='alert fade in alert-success'><button data-dismiss='alert' class='close'>×</button>Account has been moved. Please login with "+email+"</div></div>");
      }
    });
  }else{
    alert("All fields are mandatory and confirm password should be match.");
  }
})
