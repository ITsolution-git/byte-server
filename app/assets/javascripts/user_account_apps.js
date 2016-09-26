var UserAccountAppForm = (function($) {
  "user strict";
  var UserAccountAppForm = function(data) {
    var self = this;
    this.modelName = 'user_account_app';
    this.checkAllUsers = function(target) {
      console.log('testvao')
      if(target.checked) { // check select status
        $('.check_user_account_app').each(function() { //loop through each checkbox
          this.checked = true;  //select all checkboxes with class "check_user_account_app"
        });
        }else{
          $('.check_user_account_app').each(function() { //loop through each checkbox
            this.checked = false; //deselect all checkboxes with class "check_user_account_app"
          });
        }
    };
    this.changeCheckedAllUser = function(target){
      var ids_count = 0
      var ids =[]
      $('.check_user_account_app:checked').each(function() {
        ids.push($(this).val());
      });
      ids_count = ids.length
      check_user_count = $('.check_user_account_app').length
      if (ids_count == check_user_count){
         document.getElementById('check_all_user_app').checked = true;
      }else{
         document.getElementById('check_all_user_app').checked = false;
      }
    };

  };
  return UserAccountAppForm;
})($);

$(document).ready(function() {
  var user_account = new UserAccountAppForm();
  $(document).on('click', '#check_all_user_app', function (event) {
    user_account.checkAllUsers(this);
  });

  $(".check_user_account_app").on('click', function(){
    user_account.changeCheckedAllUser(this);
  });

  $(document).on('click', '.change-email-model', function(event){
    $('#new-password-modal').modal('show');
    $('#user_user_id_email').val($(this).data('user-id'));
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
        data: serializedData,
      });
    }
    else
    {
      alert("Confirm email does not match!");
    }
});
});
