var ContactMessage = (function() {
    function ContactMessage() {
      this.modelName = 'contact';
        this.sortTableImage = function(target, type_sort) {
          //if ($('.table').hasClass('contact_table_restaurant')){
            //var image_arrows_sort = '#contact_table > thead > tr >' + target;
            //sort = '#contact_table > thead > tr > th > span >' + type_sort;
          //}else {
            //var image_arrows_sort = '#my_contact_table > thead > tr >' + target;
            //sort = '#my_contact_table > thead > tr > th > span >' + type_sort;
          //}
          
          //if ($(image_arrows_sort).hasClass('headerSortDown') == true) {
            //console.log('headerSortDown');
             //$(sort).attr("src", "/assets/arrows_up.png");
             //$(type_sort).removeClass('hide');
          //} else if ($(image_arrows_sort).hasClass('headerSortUp') == true){
            //console.log('headerSortUp');
             //$(sort).attr("src", "/assets/arrows_down.png");
             //$(type_sort).removeClass('hide');
          //} //else {
          //   $(sort).attr("src", "/assets/arrows_down.png");
          //    $(type_sort).removeClass('hide');
          // }
        };

        this.checkAllUsers = function(target) {
          console.log('testvao')
          if(target.checked) { // check select status
            $('.check_user_contact_app').each(function() { //loop through each checkbox
              this.checked = true;  //select all checkboxes with class "check_user_contact_app"
            });
            }else{
              $('.check_user_contact_app').each(function() { //loop through each checkbox
                this.checked = false; //deselect all checkboxes with class "check_user_contact_app"
              });
            }
        };
        this.changeCheckedAllUser = function(target){
          var ids_count = 0
          var ids =[]
          $('.check_user_contact_app:checked').each(function() {
            ids.push($(this).val());
          });
          ids_count = ids.length
          check_user_count = $('.check_user_contact_app').length
          if (ids_count == check_user_count){
             document.getElementById('check_all_customer_contact').checked = true;
          }else{
             document.getElementById('check_all_customer_contact').checked = false;
          }
        };

      this.getAttrUserMessage = function(target, _href){
        var ids_count = 0
        var ids =[]
        $('.check_user_contact_app:checked').each(function() {
          ids.push($(this).val());
        });
        var user_contact_list = ids.join(",");
        //$('.send_message_contact').attr('href') + user_contact_list

        //alert(_href)
        $('.send_message_contact').attr("href", _href);
        $('.send_message_contact').attr("href", _href + user_contact_list);
        //alert($('.send_message_contact').attr('href') + user_contact_list)
      //ids_count = ids.length
      //check_user_count = $('.check_user_contact_app').length
        // console.log(check_user_count);
        // console.log(ids_count);
      //if (ids_count == check_user_count){
      //   document.getElementById('check_all_user').checked = true;
      //}else{
      //   document.getElementById('check_all_user').checked = false;
      //}
    };
  };
  return ContactMessage;
})();

$(document).ready(function() {
    var contactMessage = new ContactMessage();

    // $("#contact_table").on('click', function(){
    // // $(document).on('click', '#contact_table', function (event) {
    //   console.log('ok')
      
    // });
    // $myTable = $("#contact_table");
    // $("thead > tr", $myTable).click(function() {
    //     alert('ok');
    // });
    //$('.btn-group').removeClass('open');
    $(document).on('click', '#check_all_customer_contact', function (event) {
      contactMessage.checkAllUsers(this);
      var _href =  $('.send_message_contact').attr('href');
      _href = _href.substring(0, _href.lastIndexOf("=") + 1);
      contactMessage.getAttrUserMessage('.check_user_contact_app', _href);
    });
    $(".check_user_contact_app").on('click', function(){
      contactMessage.changeCheckedAllUser(this);
      var _href =  $('.send_message_contact').attr('href');
      _href = _href.substring(0, _href.lastIndexOf("=") + 1);
      contactMessage.getAttrUserMessage(this, _href)
    });

    $(document).on('click', '#add_user_group', function(event) {
      event.preventDefault();
      var listUser = Array();
      $('.check_user_contact_app:checked').each(function() {
        listUser.push($(this).val());
      });
      var mycontact = $('#mycontact').val();
      var group_id = $(this).closest('.modal-body').find('#group_id option:selected').val();
      $.get($(this).attr('href') + '?&customer_id=' + listUser.join(",") + '&group_id=' + group_id, function(data){
          // alert(data);
      });   
    });

    //$(document).on('click',".send_message_contact", function(){
     // console.log('vao')
      // $(".check_user_contact_app").on('click', function(){
        //var ids = [];
        //$('.check_user_contact_app:checked').each(function() {
         // $('.send_message_contact').attr('href') + user_contact_list
        //});
        //var user_contact_list = ids.join(",");

        // $('.send_message_contact').attr('href', $('.send_message_contact').attr('href') + user_contact_list);
        // alert("OK:" + $('.send_message_contact').attr('href'))
        //alert = "GM"
        //$.get($('.send_message_contact').attr('href') +'?&restuarant=' + 17 + '&alert=' + alert +  '&user_contact=' +  user_contact_list, function(data){
          // alert(data); restuarant=>@restaurant.id ,:alert=>'GM'
        //}); 
      //});

    $(document).on('click', '#create_group_btn', function(event) {
       if ($('#group_name').val() == ""){
        return false;
       }else {
        return true;
       }
    });

   // $(".image-arrows-name").on('click', function(){
   //    contactMessage.sortTableImage('.image-arrows-name', '.name-sort');
   //     $('.status-sort').addClass('hide');
   //     $('.username-sort').addClass('hide');
   //     $('.point-sort').addClass('hide');
   //     $('.email-sort').addClass('hide');
   //     $('.date-sort').addClass('hide');
   //     $('.zipcode-sort').addClass('hide');
   //     $('.account-sort').addClass('hide');
   //  });

   //  $(".image-arrows-status").on('click', function(){
   //    contactMessage.sortTableImage('.image-arrows-status', '.status-sort');
   //     $('.name-sort').addClass('hide');
   //     $('.username-sort').addClass('hide');
   //     $('.point-sort').addClass('hide');
   //     $('.email-sort').addClass('hide');
   //     $('.date-sort').addClass('hide');
   //     $('.zipcode-sort').addClass('hide');
   //     $('.account-sort').addClass('hide');
   //  });

   //  $(".image-arrows-username").on('click', function(){
   //    contactMessage.sortTableImage('.image-arrows-username', '.username-sort');
   //     $('.name-sort').addClass('hide');
   //     $('.status-sort').addClass('hide');
   //     $('.point-sort').addClass('hide');
   //     $('.email-sort').addClass('hide');
   //     $('.date-sort').addClass('hide');
   //     $('.zipcode-sort').addClass('hide');
   //     $('.account-sort').addClass('hide');
   //  });

   //  $(".image-arrows-point").on('click', function(){
   //    contactMessage.sortTableImage('.image-arrows-point', '.point-sort');
   //     $('.name-sort').addClass('hide');
   //     $('.status-sort').addClass('hide');
   //     $('.username-sort').addClass('hide');
   //     $('.email-sort').addClass('hide');
   //     $('.date-sort').addClass('hide');
   //     $('.zipcode-sort').addClass('hide');
   //     $('.account-sort').addClass('hide');
   //  });

   //  $(".image-arrows-email").on('click', function(){
   //    contactMessage.sortTableImage('.image-arrows-email', '.email-sort');
   //     $('.name-sort').addClass('hide');
   //     $('.status-sort').addClass('hide');
   //     $('.username-sort').addClass('hide');
   //     $('.point-sort').addClass('hide');
   //     $('.date-sort').addClass('hide');
   //     $('.zipcode-sort').addClass('hide');
   //     $('.account-sort').addClass('hide');
   //  });

   //  $(".image-arrows-date").on('click', function(){
   //   // alert('ok')
   //    contactMessage.sortTableImage('.image-arrows-date', '.date-sort');
   //     $('.name-sort').addClass('hide');
   //     $('.status-sort').addClass('hide');
   //     $('.username-sort').addClass('hide');
   //     $('.point-sort').addClass('hide');
   //     $('.email-sort').addClass('hide');
   //     $('.zipcode-sort').addClass('hide');
   //     $('.account-sort').addClass('hide');
   //  });

   //  $(".image-arrows-zipcode").on('click', function(){
   //    contactMessage.sortTableImage('.image-arrows-zipcode', '.zipcode-sort');
   //     $('.name-sort').addClass('hide');
   //     $('.status-sort').addClass('hide');
   //     $('.username-sort').addClass('hide');
   //     $('.point-sort').addClass('hide');
   //     $('.email-sort').addClass('hide');
   //     $('.date-sort').addClass('hide');
   //     $('.account-sort').addClass('hide');
   //  });

   //  $(".image-arrows-account").on('click', function(){
   //    // if ($('.table').hasClass('contact_table_restaurant')){
   //    contactMessage.sortTableImage('.image-arrows-account', '.account-sort');
   //     $('.name-sort').addClass('hide');
   //     $('.status-sort').addClass('hide');
   //     $('.username-sort').addClass('hide');
   //     $('.point-sort').addClass('hide');
   //     $('.email-sort').addClass('hide');
   //     $('.date-sort').addClass('hide');
   //     $('.zipcode-sort').addClass('hide');
   //   // }
   //  });


});