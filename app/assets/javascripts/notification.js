var GroupMessage = (function() {
    function GroupMessage(type) {
      this.modelName = 'receipt';
        this.updateImage = function(type) {
            image_url = '';
            if (type === 'DirectMarketing') {
                image_url = '../assets/direct-message.png';
            } else if (type === 'GeneralMarketing') {
                image_url = '../assets/general-message.png';
            } else if (type === 'Rating Reward') {
                image_url = '../assets/rating-alert.png';
            } else {
                image_url = '../assets/reward-alert.png';
            }
            $('.alertLogoSpan').attr('src', image_url);
        };

        this.updatePointInput = function() {
            $('#points').val($('#redactor_points').val());
        };

        this.updatePoint = function(type) {
            this.disablePoint();
            if (type === 'Rating' || type === 'Points Message' || type === 'Rating Reward') {
                this.enablePoint();
            }
            // this.disablePrizePoint();
            // if (type === 'Points Message' || type === 'Rating Reward'){
            //   this.enablePrizePoint();
            // }
        };

         // var options = "";
         //        $.get('url', function(data){

         //            options += '<option>' + value+ '</option>';
         //            $("#prize-points").html(options);
         //            $("#prize-points").show();

         //        })

        this.disablePoint = function() {
            $('a.redactor_btn_advanced').trigger('click');
            $('#redactor_points').hide();
            $('#points').val(0);
        };

        this.enablePoint = function() {
            $('a.redactor_btn_advanced').trigger('click');
            $('#redactor_points').show();
            $('#redactor_points').val('');
            $('#points').val(0);
        };

        this.disablePrizePoint = function(){
          $('#prize_point').hide();
        }
        this.enablePrizePoint = function() {
            // $('a.redactor_btn_advanced').trigger('click');
            $('#prize_point').show();
            // $('#prize_points').val('');
            // $('#points').val(0);
        };

        this.updateGUI = function(type) {
            this.updateImage(type);
            this.updatePoint(type);
        };

        //clean code
        //@author :tuantran
        this.validateEmailFormat = function(email) {
            result = true;
            if (typeof email !== 'undefined' && email !== '') {
                var re = /\S+@\S+\.\S+/;
                result = re.test(email);
            }
            return result;
        };
        this.updateGUIuser_emails = function(valid) {
            if (valid) {
                $("#user_emails").removeClass('error');
                $(".Validate_Email_Span").hide();
            } else {
                $("#user_emails").focus();
                $("#user_emails").addClass('error');
                $(".Validate_Email_Span").show();
            }
        };

        this.validate_email_exist = function() {
            result = true;
            // if ( !this.validateEmailFormat($("#user_emails").val()) && ($('#notifications_alert_type').val()=== 'DirectMarketing'
            // || $('#notifications_alert_type').val()=== 'Points Message' || $('#notifications_alert_type').val()=== 'Rating Reward' )) {
            //     var str1 = $("#user_emails").val();
            //     var str2 = "; ";
            //     if(str1.indexOf(str2) != -1){
            //       $(".Validate_Email_Span").text("Please enter valid emails to send");
            //     } else {
            //         $(".Validate_Email_Span").text("Please enter valid email to send");
            //     }

            //     this.updateGUIuser_emails(false);
            //     result = false;
            //     // console.log('fdsfdsf')
            // }
            if (($('#notifications_alert_type').val() === "Points Message" || $('#notifications_alert_type').val() === "Rating Reward") && $("#user_emails").val() === "") {
                $(".Validate_Email_Span").text("Please provide User Emails");
                this.updateGUIuser_emails(false);
                result = false;
            }
            if ($('#notifications_alert_type').val()=== 'GeneralMarketing'){
                result = true
            }
            if (result) {
                this.updateGUIuser_emails(true);
            }
            value = $('#ckeditor').val().replace(/<(?:.|\n)*?>/gm, '');
            $point = $('#redactor_points');
            $prize = $('#prize_point');
            $notifications_alert_type = $('#notifications_alert_type');
            if (value.trim() === "") {
                $('.messageSpan').html('Please enter your Message');
                $('.messageSpan').addClass('error');
                $('.messageSpan').show();
                result = false;
            } //else if ($point.is(':visible') && (isNaN(parseInt($point.val())) || $point.val()  == 0) && !$prize.is(':visible') && $notifications_alert_type.is(':visible')) {
            //     $('.messageSpan').html('Please enter your point');
            //     $('.messageSpan').addClass('error');
            //     $('.messageSpan').show();
            //     result = false;
            // }
            // else if($point.is(':visible') && (isNaN(parseInt($point.val()))  || $point.val()  == 0) && $prize.is(':visible') && ($prize.val() == null || $prize.val()== "--Select Prize--") && $notifications_alert_type.is(':visible')) {
            //     $('.messageSpan').html('Please enter your point or prize');
            //     $('.messageSpan').addClass('error');
            //     $('.messageSpan').show();
            //     result = false;
            //}
            else {
                $('.messageSpan').html('');
                $('.messageSpan').removeClass('error');
            }
            return result;
        };

        this.sendMessage = function(target) {
            var error = 0;
            var alert_type = $('#alert_type').attr('value');
            var points = $('#points').attr('value');
            this.updateGUIuser_emails(true);
            console.log(this.validate_email_exist())
            if (this.validate_email_exist()) {
                $('#new_notifications').submit();
            }
            return false;
        };

        //Function show user Email.
        this.showUserEmailMode = function(isGeneralMarketing,
            isCancelMode, isShowCancelButton) {
            if (isGeneralMarketing) {
                $(".userInputs label").show();
                $("#user_emails").addClass('hide');
                $(".btnCancelUser").hide();
                $(".btnEditUser").hide();
                $(".lb-all-customer").show();
                $(".lb-all-user").hide();
            } else {
                if (isCancelMode) {
                    $(".userInputs label").show();
                    $("#user_emails").removeClass('hide');
                    if (isShowCancelButton) {
                        $(".btnCancelUser").show();
                    } else {
                        $(".btnCancelUser").hide();
                    }
                    $(".btnEditUser").hide();
                    $(".lb-all-customer").hide();
                    $(".lb-all-user").hide();
                } else {
                    $(".userInputs label").show();
                    $("#user_emails").addClass('hide');
                    // $("#user_emails").val("");
                    $(".btnCancelUser").hide();
                    $(".btnEditUser").show();
                    $(".lb-all-customer").hide();
                    $(".lb-all-user").show();
                }
            }
        };
        //Function change notification alert type.
        this.changeNotification = function(target) {
            var about = $(target).val();
            $(".lb-all-customer").hide();
            if (about == 'DirectMarketing') {
                this.showUserEmailMode(false, true, true);
                $(".messageSpan").hide();
            } else if (about == 'GeneralMarketing') {
                this.showUserEmailMode(true, true, false);
                $(".messageSpan").hide();
                if ($(".Validate_Email_Span").length != 0) {
                    $(".Validate_Email_Span").hide();
                }
            } else if (about == 'Rating Reward') {
                this.showUserEmailMode(false, true, false);
                $(".messageSpan").hide();
            } else {
                this.showUserEmailMode(false, true, false);
                $(".messageSpan").hide();
            }
        };

        this.hideNotificationForm = function() {
            $("[rel=tooltip]").tooltip();
            $(".lb-all-customer").hide();
            $(".lb-all-user").hide();
            $(".btnEditUser").hide();
            $(".Validate_Email_Span").hide();
        };

        this.approveRating = function(target){
          if ($(target).is(":checked")){
              // it is checked
            $('#receipt_approved').val($(target).val());
            // console.log($('#receipt_approved').val());
          }
        };

        this.sortTableImage = function(target, type_sort){
            //var image_arrows_sort = '#myTable > thead > tr >' + target;
            //sort = '#myTable > thead > tr > th > span >' + type_sort;
          //if ($(image_arrows_sort).hasClass('headerSortDown') == true) {
            //console.log('vaodaychuacha');
            // $(sort).attr("src", "/assets/arrows_up.png");
             //$(type_sort).removeClass('hide');
         // } else if ($(image_arrows_sort).hasClass('headerSortUp') == true){
           // console.log('vaodaychuabacfdsfdsfdsf');
             //$(sort).attr("src", "/assets/arrows_down.png");
            // $(type_sort).removeClass('hide');
          //} else {
            //$(sort).attr("src", "/assets/arrows_down.png");
             //$(type_sort).removeClass('hide');
        //  }
        };

        this.checkedForm = function(){
          if ($('.approve-rating').is(":checked")){
            $('.datepciker-receipt > .date-span').addClass('hide-rating-ticket');
            $('.receipt-store > .store-span').addClass('hide-rating-ticket');
            $('.receipt-ticket > .ticket-span').addClass('hide-rating-ticket');
            $('.receipt-total > .total-span').addClass('hide-rating-total');
            return true;
          } //else {
        //     if (($('#receipt_date').val() == "") && ($('#receipt_store').val() == "" )
        //         && ($('#receipt_ticket').val() == "") && ($('#receipt_total').val() == "")){
        //         $('.datepciker-receipt > .date-empty').removeClass('hide-rating-date-empty');
        //         $('.receipt-store span').removeClass('hide-rating-store');
        //         $('.receipt-ticket > .ticket-span').removeClass('hide-rating-ticket');
        //         $('.receipt-total > .total-span').removeClass('hide-rating-total');
        //     }

        // }
    };

    this.checkAllUserContacts = function(target) {
      // console.log('testvao')
      var ids =[]
      $('.check_user_contact_app_message:checked').each(function() {
        ids.push($(this).val());
      });
      ids_count = ids.length
      check_user_count = $('.check_user_contact_app_message').length
        // console.log(check_user_count);
        // console.log(ids_count);
     //  var user_contact_list = ids.join(",");
     //  var _href =  $('#btn_submit_customer_contact').attr('href');
     // _href = _href.substring(0, _href.lastIndexOf("=") + 1);
     //  $('#btn_submit_customer_contact').attr("href", _href);
     //  $('#btn_submit_customer_contact').attr("href", _href + user_contact_list);

      if(target.checked) { // check select status
        $('.check_user_contact_app_message').each(function() { //loop through each checkbox
          this.checked = true;  //select all checkboxes with class "check_user_contact_app_message"
          $('#btn_submit_customer_contact').attr("disabled", false);
        });
        }else{
          $('#btn_submit_customer_contact').attr("disabled", true);
          $('.check_user_contact_app_message').each(function() { //loop through each checkbox
            this.checked = false; //deselect all checkboxes with class "check_user_contact_app_message"
          });
        }
    };

     this.getAttrUserContactMessage = function(target, _href){
        var ids_count = 0
        var ids =[]
        $('.check_user_contact_app_message:checked').each(function() {
          ids.push($(this).val());
        });
        var user_contact_list = ids.join(",");
        $('#btn_submit_customer_contact').attr("href", _href);
        $('#btn_submit_customer_contact').attr("href", _href + user_contact_list);
    };

    this.changeCheckedAllUserContact = function(target){
      var ids_count = 0

      var ids =[]
      $('.check_user_contact_app_message:checked').each(function() {
        ids.push($(this).val());
      });
      ids_count = ids.length
      check_user_count = $('.check_user_contact_app_message').length
        // console.log(check_user_count);
        // console.log(ids_count);
     //  var user_contact_list = ids.join(",");
     //  var _href =  $('#btn_submit_customer_contact').attr('href');
     // _href = _href.substring(0, _href.lastIndexOf("=") + 1);
     //  $('#btn_submit_customer_contact').attr("href", _href);
     //  $('#btn_submit_customer_contact').attr("href", _href + user_contact_list);

      if (ids_count == 0){
        $('#btn_submit_customer_contact').attr("disabled", true);
      } else {
        $('#btn_submit_customer_contact').attr("disabled", false);
      }
      if (ids_count == check_user_count){
         document.getElementById('check_all_customer_contact_message').checked = true;
      }else{
         document.getElementById('check_all_customer_contact_message').checked = false;
      }
    };

    this.disabledSelect = function(){
        if($('#view_customer_contact').hasClass('no_customer_contact') == true){
          $('.table_search_contact').css('margin-top','20px');
          $('.checkbox_select_all').addClass('hide');
        } else {
          $('.table_search_contact').css('margin-top','');
          $('.checkbox_select_all').removeClass('hide');
        }
    };

    // this.autoGrowTextArea = function(textField){
    //     if (textField.clientHeight < textField.scrollHeight)
    //     {
    //       textField.style.height = textField.scrollHeight + "px";
    //       if (textField.clientHeight < textField.scrollHeight)
    //       {
    //         textField.style.height =
    //           (textField.scrollHeight * 2 - textField.clientHeight) + "px";
    //       }
    //     }
    // };

        // end clean code
        this.updateGUI(type);
    };

    return GroupMessage;
})();

$(document).ready(function() {
    // Initialize redactor editor
    var csrf_token = $('meta[name=csrf-token]').attr('content');
    var csrf_param = $('meta[name=csrf-param]').attr('content');
    var params;
    if (csrf_param !== undefined && csrf_token !== undefined) {
        params = csrf_param + "=" + encodeURIComponent(csrf_token);
    }
    $('#ckeditor').redactor({
        "imageUpload": "/redactor_rails/pictures?" + params,
        "imageGetJson": "/redactor_rails/pictures",
        "fileUpload": "/redactor_rails/documents?" + params,
        "fileGetJson": "/redactor_rails/documents",
        "path": "/assets/redactor-rails",
        "css": "style.css",
        "autoresize": "false",
        focus: true,
        buttonAdd: ["|", "Points"],
        plugins: ['advanced']
    });

    var about = $('#notifications_alert_type').val();
    var groupMessage = new GroupMessage(about);
    groupMessage.hideNotificationForm();
    groupMessage.disabledSelect();

    // $(document).on('keyup', '#user_emails', function (event) {
    //    groupMessage.autoGrowTextArea(this);
    // });

    $(document).on('click', '#check_all_customer_contact_message', function (event) {
       groupMessage.checkAllUserContacts(this);
       var _href =  $('#btn_submit_customer_contact').attr('href');
       _href = _href.substring(0, _href.lastIndexOf("=") + 1);
       groupMessage.getAttrUserContactMessage('.check_user_contact_app_message', _href);
    });

    $(document).on('click', '.check_user_contact_app_message', function (event) {
       groupMessage.changeCheckedAllUserContact(this);
       var _href =  $('#btn_submit_customer_contact').attr('href');
       _href = _href.substring(0, _href.lastIndexOf("=") + 1);
       groupMessage.getAttrUserContactMessage('.check_user_contact_app_message', _href);
    });

    $(".approve-rating").on('change', function(){
      groupMessage.approveRating(this);
      groupMessage.checkedForm();
    });

    $(".image-arrows-user").on('click', function(){
      groupMessage.sortTableImage('.image-arrows-user', '.user-sort');
       $('.receipt-sort').addClass('hide');
       $('.message-sort').addClass('hide');
       $('.product-sort').addClass('hide');
       $('.date-sort').addClass('hide');
    });

    $(".image-arrows-receipt").on('click', function(){
      groupMessage.sortTableImage('.image-arrows-receipt', '.receipt-sort');
      $('.user-sort').addClass('hide');
       $('.message-sort').addClass('hide');
       $('.product-sort').addClass('hide');
       $('.date-sort').addClass('hide');
    });


    $(".image-arrows-message").on('click', function(){
      groupMessage.sortTableImage('.image-arrows-message', '.message-sort');
      $('.receipt-sort').addClass('hide');
       $('.user-sort').addClass('hide');
       $('.product-sort').addClass('hide');
       $('.date-sort').addClass('hide');
    });



    $(".image-arrows-product").on('click', function(){
      groupMessage.sortTableImage('.image-arrows-product', '.product-sort');
      $('.receipt-sort').addClass('hide');
      $('.message-sort').addClass('hide');
      $('.user-sort').addClass('hide');
      $('.date-sort').addClass('hide');
    });



    $(".image-arrows-date").on('click', function(){
      groupMessage.sortTableImage('.image-arrows-date', '.date-sort');
      $('.receipt-sort').addClass('hide');
      $('.message-sort').addClass('hide');
      $('.product-sort').addClass('hide');
      $('.user-sort').addClass('hide');
    });



    // $(document).on('click', '.approve-rating', function(e) {
    //    groupMessage.checkedForm();
    // });

    $(document).on('change', '#receipt_date', function(e) {
       patt = /^(\d{1,2})-(\d{1,2})-(\d{4})$/;
       res = patt.test($('#receipt_date').val());
       // console.log(res)
       if (res == true) {
        $('.datepciker-receipt > .date-invalid').addClass('hide-rating-date');
          return true
       }else {
         $('.datepciker-receipt > .date-invalid').removeClass('hide-rating-date');
          return false
       }
    });

    $(document).on('keydown', '#redactor_points', function(e) {
      return Util.forceNumericOnly(this, e);
    });

    $(".approve-rating").on('change', function(){
      groupMessage.approveRating(this);
      groupMessage.checkedForm();
    });

    $(document).on('keyup', '#redactor_points', function(e) {
      return Util.removeNoneDigitChar(this, e);
    });

    $(document).on('change', '#notifications_alert_type', function() {
        if ($(this).val()=='GeneralMarketing') {
          $('#label_link_to').removeAttr('data-target');
        } else {
          $('#label_link_to').attr("data-target", "#myModal");
        }
        groupMessage.updateGUI($(this).val());
        groupMessage.changeNotification(this);
        return false;
    });

    $(document).on("click", ".btnEditUser", function() {
        $('#label_link_to').attr("data-target", "#myModal");
        groupMessage.showUserEmailMode(false, true, true);
        return false;
    });

    $(document).on("click", ".btnCancelUser", function() {
        $('#label_link_to').removeAttr('data-target');
        groupMessage.showUserEmailMode(false, false, false);
        groupMessage.updateGUIuser_emails(true);
        return false;
    });

     $(document).on("click", "#label_link_to", function() {
        $('.check_user_contact_app_message').each(function() { //loop through each checkbox
          this.checked = false; //deselect all checkboxes with class "check_user_contact_app_message"
        })
        document.getElementById('check_all_customer_contact_message').checked = false;
        return false;
    });

    $(document).on("click", ".messageButton", function() {
        groupMessage.sendMessage(this);
        return false;
    });

    $(document).on('change', '#redactor_points', function() {
        groupMessage.updatePointInput();
    });

    $(document).on('change', '#receipt_date', function(){
      if ($('#receipt_date').val() != ""){
        $('.datepciker-receipt > .date-span').addClass('hide-rating-ticket');
      }
    });

    $(document).on('change', '#receipt_store', function(){
      if ($("#receipt_store option:selected").val()){
        $('.receipt-store > .store-span').addClass('hide-rating-ticket');
      }
    });
    $(document).on('keyup', '#receipt_ticket', function(){
      if ($('.approve-rating').is(":checked") == false){
          if ($('#receipt_ticket').val() != ""){
            $(this).parent().find('.ticket-span').addClass('hide-rating-ticket');
          }else {
            $(this).parent().find('.ticket-span').removeClass('hide-rating-ticket');
          }
      }
    });
    // $(document).on('keydown', '#receipt_ticket', function(){
    //     console.log('testaaaaa1111')
    //   if ($('#receipt_ticket').val() != ""){
    //     $(this).parent().find('.ticket-span').addClass('hide-rating-ticket');
    //   }else {
    //     console.log('testaaaaa2222')
    //     $(this).parent().find('.ticket-span').removeClass('hide-rating-ticket');
    //   }
    // });
    $(document).on('keyup', '#receipt_total', function(){
      if ($('.approve-rating').is(":checked") == false){
          if ($('#receipt_total').val() != ""){
            $(this).parent().find('.total-span').addClass('hide-rating-total');
          }else {
            $(this).parent().find('.total-span').removeClass('hide-rating-ticket');
          }
      }
    });

    $(document).on('click', '#contact_all_customer', function(){
      // alert('contact_all_customer');
      var restaurant_id = $('#restaurant_id_field').val();
        $.ajax({
          url: '/notification/contact_all_message',
          data: {restaurant: restaurant_id},
          type: 'get',
          success: function(data) {
            groupMessage.disabledSelect();
            document.getElementById('check_all_customer_contact_message').checked = false;
            $('.search_contact_customer_field').val("");
            $('#btn_submit_customer_contact').attr("disabled", true);
            $('.label_customer_contact_name').text('Customers');
            $('.label_customer_contact_name').append(' <span class="caret"></span>');
          }
        });
    });

    $(document).on('click', '#contact_customer_group', function(){
      // alert('contact_customer_group')
       var restaurant_id = $('#restaurant_id_field').val();
       var name =$(this).text();
       var group_id = parseInt($(this).attr('class'))
       $.ajax({
          url: '/notification/contact_group_message',
          data: {restaurant: restaurant_id, group_id: group_id},
          type: 'get',
          success: function(data) {
            groupMessage.disabledSelect();
            document.getElementById('check_all_customer_contact_message').checked = false;
            $('.search_contact_customer_field').val("");
            $('#btn_submit_customer_contact').attr("disabled", true);
            $('.label_customer_contact_name').text(name);
            $('.label_customer_contact_name').append(' <span class="caret"></span>');
          }
        });
    });

    $(document).on('keypress', '.search_contact_customer_field', function(e){
       var search_params = $(this).val();
       var restaurant_id = $('#restaurant_id_field').val();
       var code = (e.keyCode ? e.keyCode : e.which);
        if(code == 13){
            $.ajax({
              url: '/notification/search_contact_message',
              data: {search_params: search_params, restaurant: restaurant_id},
              type: 'get',
              success: function(data) {
                groupMessage.disabledSelect();
                document.getElementById('check_all_customer_contact_message').checked = false;
                $('#btn_submit_customer_contact').attr("disabled", true);
                $('.label_customer_contact_name').text('Customers');
                $('.label_customer_contact_name').append(' <span class="caret"></span>');
                // $('.label_customer_contact_name').text(name);
                // $('.label_customer_contact_name').append(' <span class="caret"></span>');
              }
            });
        }
    });

    $(document).on('click', '.btn_search_contact_custoner', function(){
       var search_params = $('.search_contact_customer_field').val();
       var restaurant_id = $('#restaurant_id_field').val();
        $.ajax({
          url: '/notification/search_contact_message',
          data: {search_params: search_params, restaurant: restaurant_id},
          type: 'get',
          success: function(data) {
            groupMessage.disabledSelect();
            document.getElementById('check_all_customer_contact_message').checked = false;
            $('#btn_submit_customer_contact').attr("disabled", true);
            $('.label_customer_contact_name').text('Customers');
            $('.label_customer_contact_name').append(' <span class="caret"></span>');
            // $('.label_customer_contact_name').text(name);
            // $('.label_customer_contact_name').append(' <span class="caret"></span>');
          }
        });
    });

    $("#btn_submit_customer_contact").on('click', function() {
      // $('#user_emails').autosize();
      $("#user_emails").removeClass('error');
      $(".Validate_Email_Span").hide();
    });

    $('#user_emails').on('keyup', function(){
        console.log('fdsfhkjdsgfjkdsg')
      if ($(this).val()== "") {
        $(this).addClass('user_height');
        $(".Validate_Email_Span").show();
        $("#user_emails").addClass('error');
        // $('#user_emails').flexible();
      } else {
        $(".Validate_Email_Span").hide();
         $("#user_emails").removeClass('error');
        $(this).removeClass('user_height');
        $('#user_emails').css({'height': ''});
        $(this).flexible();
      }
      // if ($('#notifications_alert_type').val() == "Rating Reward" || $('#notifications_alert_type').val() == "Points Message") {
      //   if ($(this).val() != "") {
      //     $("#user_emails").removeClass('error');
      //     $(".Validate_Email_Span").hide()
      //   } else {
      //      $("#user_emails").addClass('error');
      //      $(".Validate_Email_Span").show();
      //   }
      // }
    });

    $('.redactor_redactor_mm.redactor_text_message.redactor_editor').on('keyup', function(){
      var self = $('.redactor_redactor_mm.redactor_text_message.redactor_editor > p');
      if ((self).text().length == 1) {
        $(".messageSpan").show();
      } else {
        $(".messageSpan").hide();
      }
    });
});
