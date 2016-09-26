var Invited = (function($) {
    var Invited = function(config) {
        this.submit = config.submit;
        this.form = config.form;
        this.signed_up = config.signed_up;
        this.user_email = config.user_email;
        this.add_friend_link = config.add_friend_link;
        this.params = config.params;
        this.check_manager_link = config.check_manager_link;

        if (this.signed_up) {
            alert('You have already signed up.');
            this.addFriend();
        }
    };

      Invited.prototype.addFriend = function() {
        // ajax to add notification
        $.ajax({
            url: "/request_friend",
            type: 'POST',
            data: this.params,
            success: function (data) {
                window.location = '/';
            }
        });
    };
    

    Invited.prototype.displayWarningManager= function() {
        alert('This email has been used on Restaurant Portal. Please user another email to sign up');
        document.getElementById("user_email").value = "";
        //return $(this.form).submit();

    };

    Invited.prototype.checkWarningManager = function(user_email) {
        var self = this;
        $.ajax({
            url: "/check_manager",
            type: 'POST',
            data:{
                email: user_email
            },
            success: function (data) {
                console.log(data);
                if (data == 'true') {
                    //$(self.form).attr('action', self.expired_link);
                    self.displayWarningManager();
                } else {
                    $(self.form).submit();
                }
            }
        });
    };

    return Invited;
})($);

$(document).ready(function() {
    console.log("link", link);
    var invitedForm = new Invited(invitedFormObj);

    $(invitedForm.submit).on('click', function(e) {
        console.log("SUBMIT", $("#user_email").val());
        var user_email = $("#user_email").val();
        invitedForm.checkWarningManager(user_email);
        e.preventDefault();
    });
});