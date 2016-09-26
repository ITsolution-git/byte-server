var Prize = (function($) {
    var Prize = function(config) {
        this.check_share_prize_link = config.check_share_prize_link;
        this.prize_token = config.prize_token;
        this.signed_up = config.signed_up;
        this.is_receive = config.is_receive;
        this.modal = config.modal;
        this.add_prize_link = config.add_prize_link;
        if (this.is_receive){
            this.openModal()
        }else{
            if(!this.signed_up){
                this.addPrize()
            }
        }
    };

    Prize.prototype.openModal = function() {
        $(this.modal).modal();
    };

    Prize.prototype.addPrize = function() {
        $.ajax({
            url: this.add_prize_link,
            type: 'GET',
            data: {
                prize_token: this.prize_token
            },
            success: function (data) {
                $("#prize_modal").modal();
            }
        });
    };
    return Prize;
})($);

$(document).ready(function() {
    var prizeForm = new Prize(PrizeObject);
    $("#close-modal").on('click', function() {
        window.location = '/';
    });
    // $(prizeForm.submit).on('click', function(e) {
    //     e.preventDefault();
    // });
});