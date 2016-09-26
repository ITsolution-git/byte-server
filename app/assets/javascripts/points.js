var GroupPoint = (function() {
    function GroupPoint() {
        this.modelName = 'social_point';
        this.unDisabledSubmit = function(target, social_point1, social_point2, social_point3) {
          if ($(target).val() == ""
              && $(social_point1).val() == ""
              && $(social_point2).val() == ""
              && $(social_point3).val() == "" ){
            $('#social_form_submit').attr("disabled", true);
          } else {
             $('#social_form_submit').attr("disabled", false);
          }
        };
        this.isNumber = function(o) {
          return typeof o === 'number' && isFinite(o);
        }
    };

    return GroupPoint;
})();
var EMPTY_MESSAGE = "Can't be empty!", ZERO_MESSAGE = "This value must be greater than zero!";
$(document).ready(function() {
$(document).on("change", ".status_prize_name, .prize_name, .redeem_value", function(){
  window.changed_prize = true;
});

    var groupPoint = new GroupPoint();
  // $(document).on("click",".status_level_prize_edit", function(e){ 
  //   e.preventDefault();
  //   console.log('vaoAAAAAAa')
  //   $("#primary-layout .span7").load($(this).data('href') + ' #primary-layout .span7 #prize-status');
  //   return false;
  // });
    if($(".alert-success").length!=0){
      $(".alert-success").delay(3000).fadeOut();
    }
    if($(".alert-error").length!=0){
      $(".alert-error").delay(3000).fadeOut(); 
    }
    
     // $(document).on("click", "#clonetrigger", function(){
    $('#clonetrigger').click(function(){
      $('#submit_prize_form').attr("disabled", true);
    });

    $(document).on('keyup', ".status_prize_name", function() {
        if ($(this).val() == ""){
          $('#submit_prize_form').attr("disabled", true);
          // $('#status_name').text("Can't be empty.");
          $('.status-name-span').removeClass('hide-status');
        }
        else {
          if ($(this).val().length > 30) {
          $('#submit_prize_form').attr("disabled", true);
          $('.status-name-span').text("Must not be more than 30 characters long!");
          $('.status-name-span').removeClass('hide-status');
          } else {
             $('#submit_prize_form').attr("disabled", false);
             $('.status-name-span').addClass('hide-status');
             $('.status-name-span').text("Can't be empty.");
          }
        }
    });
    $(document).on('keyup', ".prize_name", function() {
      // console.log('vaofhdsfkjgd')
      names = []
      $(".prize_name").each(function(){
        names.push($(this).val());
      });
       prize_level_length = $('.display_level_prize').length
      ////console.log("redeem_lenght",prize_level_length)
      // ////console.log(names.length)
      if (names.length != 1 || prize_level_length == 0){
        var id = $(this).attr('id');
        // ////console.log(id)
        lastChar = id[id.length - 1]
        // ////console.log("lastChar",lastChar)
        if ($(this).val() == ""){
          // alert('cant be empty');
          // alert(lastChar)
         // $('#prize-name-span_'+ lastChar).text("Can't be empty.");
          $('#prize-name-span_'+ lastChar).removeClass('hide-prize');
          $('#prize-name-span_'+ lastChar).removeClass('prize-name-span');
          return false;
        } else if ($('#prize_name_'+lastChar).val().length > 50){
          console.log('fdsfdsfdsfds')
           $('#prize-name-span_'+ lastChar).text('Must be 50 characters');
           $('#prize-name-span_'+ lastChar).removeClass('hide-prize');
           $('#prize-name-span_'+ lastChar).removeClass('prize-name-span');
          return false;
        }
        else {
          $('#prize-name-span_'+ lastChar).text("Can't be empty.");
          $('#prize-name-span_'+lastChar).addClass('hide-prize');
          $('#prize-name-span_'+ lastChar).addClass('prize-name-span');
          return true;
        }
      }
      else {
        var is_valid_redeem = true;
        var is_valid_name =true;
        var is_valid_name_char = true
        $(".redeem_value").each(function(){
          if ($(this).val() == ""){
           is_valid_redeem = false;
          }
        });
        $(".prize_name").each(function(){
         if ($(this).val() == ""){
          // console.log($(this).val())
           is_valid_name = false;
          }
          else if ($(this).val().length > 50){
            is_valid_name_char = false;
          }
        });
        console.log(is_valid_name_char)
        console.log("redeem"+is_valid_redeem)
        console.log("name"+is_valid_name)
        // console.log(is_valid_redeem)
        // console.log(is_valid_name)
        if(is_valid_redeem && is_valid_name){
          if (is_valid_name_char == false){
            $('#prize-name-span_1').text("Must be 50 characters.");
            $('#prize-name-span_1').removeClass('hide-prize');
            $('#prize-name-span_1').removeClass('prize-name-span');
          }
          else {
            $('#prize-name-span_1').addClass('hide-prize');
            $('#prize-name-span_1').addClass('prize-name-span');
            return true;
          }
          // $("#submit_prize_form").attr("disabled", false);
          // $("#clonetrigger").removeClass('hide');
        }
        else if(is_valid_redeem == false && is_valid_name == false){
          $('#prize-name-span_1').addClass('hide-prize');
          $('#prize-name-span_1').addClass('prize-name-span');
          $('#prize-redeem-value-span_1').addClass('hide-prize');
          return true;
          // $("#submit_prize_form").attr("disabled", false);
          // $("#clonetrigger").addClass('hide');
        }
        else{
          if (is_valid_redeem == true && is_valid_name == false){
            // alert('cant be empty')
            $('#prize-name-span_1').text("Can't be empty.");
            $('#prize-name-span_1').removeClass('hide-prize');
            $('#prize-name-span_1').removeClass('prize-name-span');
          }
          // $("#submit_prize_form").attr("disabled", true);
          // $("#clonetrigger").addClass('hide');
        }
      }
    });
    // $(document).on('keyup', "#redeem_value_1, #prize_name_1", function() {
    //    is_hide = true;
    //    if ($('#redeem_value_1').val()== ""){
    //       is_hide = false;
    //    }
    //    if ($('#prize_name_1').val()== ""){
    //      is_hide = false;
    //    }
    //     if(is_hide){
    //      $("#clonetrigger").removeClass('hide')
    //     // ////console.log("ok");
    //   }
    //   else{
    //     $("#clonetrigger").addClass('hide')
    //     // ////console.log("fail");
    //   }
    //  });
  $(document).on('keyup', ".redeem_value, .prize_name, .status_prize_name", function() {
    points = []
    $(".redeem_value").each(function(){
      points.push($(this).val());
    });
     prize_level_length = $('.display_level_prize').length
     ////console.log("redeem_lenght",prize_level_length)
    if (points.length != 1 || prize_level_length == 0){
      var is_valid = true;
        $(".redeem_value").each(function(){

          if ($(this).val() == "" || isNaN($(this).val()) || parseInt($(this).val()) == 0){
           is_valid = false;
          }
        });
        $(".prize_name").each(function() {
         if ($(this).val() == "") {
           is_valid = false;
          }
          else if ($(this).val().length > 50){
            is_valid = false;
          }
        });

        if ($('.status_prize_name').val() == ""){
          is_valid = false;
        }
        else {
          if ($('.status_prize_name').val().length > 30) {
            is_valid = false;
          }
        }

       if(is_valid) {
           $("#submit_prize_form").attr("disabled", false);
            $("#clonetrigger").removeClass('hide');
        }
        else{
          $("#submit_prize_form").attr("disabled", "disabled");
          $("#clonetrigger").addClass('hide');
        }
      } else {
        var is_valid_redeem = true;
        var is_valid_name =true
        var is_valid_status = true
        $(".redeem_value").each(function(){
          if ($(this).val() == ""){
            is_valid_redeem = false;
          }
        });
        $(".prize_name").each(function(){
         if ($(this).val() == ""){
           is_valid_name = false;
          }
          else if ($(this).val().length > 50){
            is_valid_name = false;
          }
        });

        if ($('.status_prize_name').val() == ""){
          is_valid_status = false;
        }
        else {
          if ($('.status_prize_name').val().length > 30) {
            is_valid_status = false;
          }
        }

        //console.log(is_valid_redeem)
        //console.log(is_valid_name)
      if (points.length == 1){
        $(".redeem_value").each(function(){
          if (parseInt($(this).val()) == 0){
               $('#prize-redeem-value-span_1').text(ZERO_MESSAGE);
            $('#prize-redeem-value-span_1').removeClass('hide-prize');
            is_valid_redeem = false;
          }
        });
       }
       if(is_valid_redeem && is_valid_name && is_valid_status){
          $("#submit_prize_form").attr("disabled", false);
          $("#clonetrigger").removeClass('hide');
        }
        else if(is_valid_redeem== false && is_valid_name == false && is_valid_status){
          $("#submit_prize_form").attr("disabled", false);
          $("#clonetrigger").addClass('hide');
        }
        else{
          if (is_valid_status == false){
            $("#submit_prize_form").attr("disabled", true);
          }
          else {
            $("#submit_prize_form").attr("disabled", true);
            $("#clonetrigger").addClass('hide');
          }
        }
      }
  });

  $(document).on('click', ".remove", function() {
    $(this).closest(".clonable").remove();
     var check = true;
     var redeem_lenght = $('.redeem_value').length;
     var name_lenght = $('.prize_name').length;
     prize_level_length = $('.display_level_prize').length
     ////console.log("redeem_lenght",prize_level_length)
      if (redeem_lenght != 1 || prize_level_length == 0){
        $(".redeem_value").each(function(index){
          ////console.log("aaa", $(this).val())
            if ($(this).val() == ""){
              check = false;
            }
        });
        var name_lenght = $('.prize_name').length;
        $(".prize_name").each(function(index){

            if ($(this).val() == ""){
             check = false;
            }
        });
        ////console.log(check)
       if(check){
           $("#submit_prize_form").attr("disabled", false);
           $("#clonetrigger").removeClass('hide');
          // ////console.log("ok");
        }
        else{
          $("#submit_prize_form").attr("disabled", "disabled");
          $("#clonetrigger").addClass('hide');
          // ////console.log("fail");
        }
      } else {
        var is_valid_redeem = true;
        var is_valid_name =true
        $(".redeem_value").each(function(){
          if ($(this).val() == ""){
           is_valid_redeem = false;
          }
        });
        $(".prize_name").each(function(){
         if ($(this).val() == ""){

           is_valid_name = false;
          }
        });

         if(is_valid_redeem && is_valid_name){
           $("#submit_prize_form").attr("disabled", false);
           $("#clonetrigger").removeClass('hide');
           // $('.prize-name-span').addClass('hide-prize');
           // $('.prize-redeem-value-span').addClass('hide-prize');
        }
        else if(is_valid_redeem == false && is_valid_name == false){
           $("#submit_prize_form").attr("disabled", false);
           $('.prize-name-span').addClass('hide-prize');
           $('.prize-redeem-value-span').addClass('hide-prize');
        }
        else{
          $("#submit_prize_form").attr("disabled", true);
          // if (is_valid_redeem == true && is_valid_name == false \
          //   || is_valid_redeem == false && is_valid_name == true){
          //   $('#prize-name-span_1').text("Can't be empty.");
          //   $('#prize-name-span_1').removeClass('hide-prize');
          // }
          // $("#submit_prize_form").attr("disabled", true);
          // $("#clonetrigger").addClass('hide');
        }
      }
  });

    $(document).on('keyup', ".redeem_value", function() {
       points = []
      $(".redeem_value").each(function(){
        points.push($(this).val());
      });
        var is_valid_redeem = true;
        var is_valid_name =true
        var check_redeem = false
        var id = $(this).attr('id');
        lastChar = id[id.length - 1];
       prize_level_length = $('.display_level_prize').length
      ////console.log("redeem_lenght",prize_level_length)
      ////console.log(points.length)

      if (points.length != 1 || prize_level_length == 0){
      
         $('.redeem_value').mask('?999999',{placeholder: ""});
         $('#prize-redeem-value-span_'+ lastChar).text(EMPTY_MESSAGE);
          if ($(this).val() == ""){
            $('#prize-redeem-value-span_'+ lastChar).removeClass('hide-prize');
          }
          else if (!isNaN($(this).val()) && parseInt($(this).val()) == 0){
            $('#prize-redeem-value-span_'+ lastChar).text(ZERO_MESSAGE);
            $('#prize-redeem-value-span_'+ lastChar).removeClass('hide-prize');
          }
          else if(!$.isNumeric($(this).val())){
            $('#prize-redeem-value-span_'+ lastChar).text('Must be a number!');
            $('#prize-redeem-value-span_'+ lastChar).removeClass('hide-prize');
          }
          else {
            $('#prize-redeem-value-span_' + lastChar).addClass('hide-prize');
          }
      } else {
        $('.redeem_value').mask('?999999',{placeholder: ""});
        $(".redeem_value").each(function(){
          if ($(this).val() == ""){
           is_valid_redeem = false;
          }
        });
        $(".prize_name").each(function(){
         if ($(this).val() == ""){
           is_valid_name = false;
          }
        });
          //console.log(is_valid_name)
          //console.log(is_valid_redeem)
           if (points.length == 1){
        if (!isNaN($(this).val()) && parseInt($(this).val()) == 0){

            $('#prize-redeem-value-span_1'+ lastChar).text(ZERO_MESSAGE);
            $('#prize-redeem-value-span_'+ lastChar).removeClass('hide-prize');
            is_valid_redeem = false;
            return false;
          }
       }
         if(is_valid_redeem && is_valid_name){
           $('#prize-redeem-value-span_1').addClass('hide-prize');
          return true;
          // $("#submit_prize_form").attr("disabled", false);
          // $("#clonetrigger").removeClass('hide');
        }
        else if(is_valid_redeem == false && is_valid_name == false){
          $('#prize-redeem-value-span_1').addClass('hide-prize');
          $('#prize-name-span_1').addClass('hide-prize');
          return true;
          // $("#submit_prize_form").attr("disabled", false);
          // $("#clonetrigger").addClass('hide');
        }
        else{
          if (is_valid_redeem == false && is_valid_name == true){
            $('#prize-redeem-value-span_1').text("Can't be empty.");
            $('#prize-redeem-value-span_1').removeClass('hide-prize');
          }
          // $("#submit_prize_form").attr("disabled", true);
          // $("#clonetrigger").addClass('hide');
        }

      }
     
    });

    $(document).on('click', "#submit_prize_form", function() {
      var name_arr = [];
      $(".prize_name").each(function(){
        var name = $(this).val();
        name_arr.push(name);
      });
      if (name_arr.length != 1){
        var is_valid_name = true;
        var name_lenght = 0;
        var tmp_lenght = 0;
        name_lenght = name_arr.length;
        $.unique(name_arr);
        tmp_lenght = name_arr.length;
        if(name_lenght != tmp_lenght){
          is_valid_name = false;
        }
        // ////console.log("fdsfdsf",is_valid_name);

        var points = []; 
        $(".redeem_value").each(function(){
          var point = parseFloat($(this).val());
          points.push(point);
        });
        var is_valid = true;
        var error_index = null;
        points.sort(function(a, b){
          if((a-b)> 0 && is_valid){
            is_valid = false;
            error_index = points.indexOf(a);
          } 
          return a - b; 
        });
         for (i = 1; i <= 100; i++){
           a = i + 1
           if ($('#prize_name_'+ i).val() == ""){
            $('#prize-name-span_' + i).removeClass('hide-prize');
             return false;
           }
           else if ($('#prize_name_'+i).text().length > 50){
            $('#prize-name-span_'+ lastChar).text('Must be 50 characters');
            $('#prize-name-span_'+ lastChar).removeClass('hide-prize');
            $('#prize-name-span_'+ lastChar).removeClass('prize-name-span');
            return false;
           }

          if (($('#redeem_value_'+ i).val() == "")){
            $('#prize-redeem-value-span_' + i).removeClass('hide-prize');
            return false;
          }
          else if(!$.isNumeric($('#redeem_value_'+ i).val())){
            // $('#prize-redeem-value-span_'+ lastChar).text('Must be a number!');
            // $('#prize-redeem-value-span_'+ lastChar).removeClass('hide-prize');
            return true
          }
          // else if ($('#redeem_value_' + i).val().length > 6){
          //   if ($('#redeem_value_'+ i).val() != ""){
          //     $('#prize-redeem-value-span_' + lastChar).text('Must be 6 number.');
          //     $('#prize-redeem-value-span_'+ lastChar).removeClass('hide-prize');
          //     return false
          //   }
          // }
          // else if ( is_valid == false ) {
          //   error_index = error_index + 2
          //   // alert(error_index);
          //   alert("The redemption value of level " + error_index +" cannot be lower than the redemption value of lower level")
          //   return false
          // }
          // else if ( is_valid_name == false ) {
          //   // alert(error_index);
          //   alert(' Prize name of current level must be different from others.');
          //   //alert("The prize name value of level " + error_index_name +" cannot be lower than the redemption value of lower level")
          //   return false
          // }
          // return false;
        }
      }
    });
    $("#social_point_facebook_point").on('keyup', function(){
      //this.value = this.value.replace(/[^0-9]/g,'');
      groupPoint.unDisabledSubmit(this,'#social_point_google_plus_point', '#social_point_twitter_point','#social_point_instragram_point');
    });

    $("#social_point_google_plus_point").on('keyup', function(){
      //this.value = this.value.replace(/[^0-9]/g,'');
      groupPoint.unDisabledSubmit(this,'#social_point_facebook_point', '#social_point_twitter_point','#social_point_instragram_point');
    });

    $("#social_point_twitter_point").on('keyup', function(){
      //this.value = this.value.replace(/[^0-9]/g,'');
      groupPoint.unDisabledSubmit(this,'#social_point_google_plus_point', '#social_point_facebook_point','#social_point_instragram_point');
    });

    $("#social_point_instragram_point").on('keyup', function(){
      //this.value = this.value.replace(/[^0-9]/g,'');
      groupPoint.unDisabledSubmit(this,'#social_point_google_plus_point', '#social_point_twitter_point','#social_point_facebook_point');
    });
});