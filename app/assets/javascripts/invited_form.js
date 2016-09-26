var Invited = (function($) {
    var Invited = function(config) {
        this.expired = config.expired;
        this.alert = config.alert;
        this.submit = config.submit;
        this.form = config.form;
        this.expired_link = config.expired_link;
        this.friend_expired_link = config.friend_expired_link;
        this.signed_up = config.signed_up;
        this.add_friend_link = config.add_friend_link;
        this.params = config.params;

        if (this.signed_up) {
            alert('You have already signed up.');
            this.addFriend();
        }
    };

    Invited.prototype.openModal = function() {
        $(this.alert).modal();
    };

    Invited.prototype.addFriend = function() {
        // ajax to add notification
        $.ajax({
            url: this.add_friend_link,
            type: 'post',
            data: this.params,
            success: function (data) {
                window.location = '/';
            }
        });
    };

    Invited.prototype.displayWarningExpired = function() {
        if (confirm('The invitation is over 30 days. '
                + 'The invitation is over 30 days. You will not receive the shared points anymore.'
                + ' Please continue signing up to use BYTE.')) {
            return $(this.form).submit();
        }

        return false;
    };

    Invited.prototype.displayWarningManager= function() {
        alert('This email has been used on Restaurant Portal. Please user another email to sign up');
        document.getElementById("user_email").value = "";
        //return $(this.form).submit();

    };

    Invited.prototype.checkWarningExpired = function() {
        var self = this;
        // when expired
        if (this.friend_expired_link === '') {
            $(self.form).submit();
            return false;
        }
        $.ajax({
            url: this.friend_expired_link,
            type: 'GET',
            success: function (data) {
                if (data == 'true') {
                    self.displayWarningExpired();
                } else {
                    $(self.form).submit();
                }
            }
        });
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
                if (data == 'true') {
                    //$(self.form).attr('action', self.expired_link);
                    self.displayWarningManager();
                    self.checkWarningExpired();
                } else {
                     self.checkWarningExpired();
                     //$(self.form).submit();
                }
            }
        });
    };



    return Invited;
})($);

$(document).ready(function() {
   
    var invitedForm = new Invited(invitedFormObj);

    $(invitedForm.submit).on('click', function(e) {
        var user_email = $("#user_email").val();
        invitedForm.checkWarningManager(user_email);
        //$(self.form).submit();
        //invitedForm.checkWarningExpired();
        e.preventDefault();
    });
});