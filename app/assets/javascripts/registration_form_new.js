var RegistrationForm = (function($) {
  "user strict";

  var RegistrationForm = function() {
    // Validate function will need this attribute to indicate the validated form
    this.modelName = 'user';
    this.autoFillElement = this.modelName + '_autofill';

    this.toggleBilling = function() {
      if($('#' + this.autoFillElement).is(':checked')) {
        $('#user_billing_country').val($('#user_restaurants_attributes_0_country').val()).trigger('change');
        $('#user_billing_address').val($('#user_restaurants_attributes_0_address').val())
          .prop('disabled', false).trigger('blur').prop('disabled', true);
        $('#user_billing_state').val($('#user_restaurants_attributes_0_state').val()).trigger('blur');
        $('#user_billing_city').val($('#user_restaurants_attributes_0_city').val()).trigger('blur');
        $('#user_billing_zip').val($('#user_restaurants_attributes_0_zip').val())
          .prop('disabled', false).trigger('blur').prop('disabled', true);

        $('#billing_address_wrapper').hide();
        return false;
      }
      $('#billing_address_wrapper').show();
      return true;
    };

    $('#' + this.modelName + '_phone').mask('?(999) 999-9999');
    $('#' + this.modelName + '_credit_card_expiration_date').mask('?99/99');
  };

  return RegistrationForm;
})($);

$(document).ready(function() {

  $('#user_billing_country').on('change', function() {
    setTimeout(function() {
      $('#user_billing_state').val($('#user_restaurants_attributes_0_state').val()).trigger('blur');
    },200);
  });

  var user = new RegistrationForm();

  // Validate registration form
  var userForm = Util.validate(user, {
    username: [
      Validate.Presence,
      [Validate.Length, {minimum: 3, maximum: 30}],
    ],
    email: [
      Validate.Presence,
      Validate.Email
    ],
    password: [
      Validate.Presence,
      [Validate.Length, {minimum: 5}],
    ],
    phone: [
      [Validate.Format, {
        pattern: /^\(([0-9]{3})\)([ ])([0-9]{3})([-])([0-9]{4})$/,
        failureMessage: "Invalid Phone number format. Use: (xxx) xxx-xxxx"
      }]
    ]
  });

  // else if ($('#user_restaurants_attributes_0_primary_cuisine').val() != ""){
  //     $('.primary_cuisine_error').addClass('hide');
  //     return true;
  //   }

  $( "#user_restaurants_attributes_0_primary_cuisine" ).change(function() {
    if ($(this).val() != ""){
      $('.primary_cuisine_error').addClass('hide');
      return true;
    } else if ($(this).val() == ""){
       $('.primary_cuisine_error').removeClass('hide');
       return false;
    }
  });

  $('#submit_form_register').click(function() {
    if ($('#user_restaurants_attributes_0_primary_cuisine').val() == ""){
      $('.primary_cuisine_error').removeClass('hide');
      return false;
    }

    for (var element in userForm) {
      $('#user_' + element).trigger('blur');
      if(userForm.hasOwnProperty(element)){
        if (userForm[element].validationFailed) {
          $('#user_autofill:checked').trigger('click');
          return false;
        }
      }
    }
    toggleValidate(user.toggleBilling());
  });

  // function toggleValidate(isEnable) {
  //   if (isEnable) {
  //     Util.enableValidate(userForm, ['billing_address', 'billing_zip']);
  //   } else {
  //     Util.disableValidate(userForm, ['billing_address', 'billing_zip']);
  //   }
  // }

  /*$('#user_credit_card_expiration_date').on('change', function(){
    var currentTime = new Date()
    var current = currentTime.getYear().toString().substr(1,2);
    var year = parseInt(current)
    var expiration_date_val = $('#user_credit_card_expiration_date').val();
    var res = expiration_date_val.split("/");
    var expiration_date = parseInt(res[1])
    if (expiration_date < year || expiration_date > year + 10) {
     $('.LV_validation_message').text('Most sites assume a max expiration period of around 10 years.')
    }
  });*/
  // Toggle Billing Address
  // toggleValidate(user.toggleBilling());
  // $('#' + user.autoFillElement).on('change', function() {
  //   toggleValidate(user.toggleBilling());
  // });

});
