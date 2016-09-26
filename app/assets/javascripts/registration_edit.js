var RegistrationEdit = (function($) {
  "user strict";
  var RegistrationEdit = function() {
    // Validate function will need this attribute to indicate the validated form
    this.modelName = 'user';
  };

  return RegistrationEdit;
})($);

$(document).ready(function() {
  var registrationEdit = new RegistrationEdit();

  // Validate registration form
  var userForm = Util.validate(registrationEdit, {
    current_password: [Validate.Presence],
    password: [Validate.Presence],
    password_confirmation: [Validate.Presence],
  });
});