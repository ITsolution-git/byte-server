var RestaurantForm = (function($) {
  "user strict";
  var RestaurantForm = function(data) {
    // Validate function will need this attribute to indicate the validated form
    this.modelName = 'restaurant';
    var self = this;

    this.$timepicker = data['timepicker'];

    // Default config for timepicker
    this.tpConfig = {
      'defaultTime': false,
      'minuteStep': 1
    };

    /**
     * Call input[type='file'] clicked trigger
     * @param  {string} target - Current element clicked
     * @return {void}        Type input clicked
     */
    this.uploadImage = function(target) {
      // //console.log('uploadImage:', target);
      //  //console.log('uploadImage:',  $(target).parent().find("input[type='file']"));
      $(target).parent().find("input[type='file']").trigger('click');
      // //console.log('uploadImage parent:', $(target).parent());
    };

    /**
     * Display timepicker
     * @param  {object} config - additional config
     * @return {void}        Display timepicker
     */
    this.viewTimePicker = function(config) {
      $.extend(this.tpConfig, config);
      this.$timepicker.timepicker(this.tpConfig);
    };

    /**
     * Coerce Tax to format that have 2 decimal digits. Ex: 12.00
     * @param  {string} target - Current element
     * @return {void}        Coerce Tax format
     */
    this.coerceTax = function(target) {
      var value = parseFloat(Math.round($(target).val() * 100) / 100).toFixed(2);
      $(target).val(isNaN(value) ? '' : value);
    };

    /**
    * Autocomplete restaurant city
    * @param  {string} - Current element forcus
    */

    /**
    * Change restaurant state.
    * @param  {string} - Current element change
    */
    this.changeRestaurantState = function(target) {
      if(RestaurantObj['restaurantNewRecord'] === 'false') {
        $("#restaurant_city option:first").text("-Select City-");
      }
    }

    /**
    * Get State function.
    * @param {string} - Current restaurant state
    */

    /*
    *Function sort list country, city, state
    *@param {string} - countryName
    */
    this.predicatBy = function(countryName) {
      var check = 0;
      return function(a, b){
        if(a[countryName] > b[countryName]) {
          check =  1;
        } else if( a[countryName] < b[countryName] ) {
          check = -1;
        }
        return check;
      }
    };

    /*
    * Function get list restaurant country.
    * @param target, alt, countryName, countryCode, selected
    */
    this.getListRestaurantCountry = function(target, alt, countryName, countryCode, selected) {
      $(target).append($("<option></option>")
                        .attr("alt",alt)
                        .attr("value",countryName)
                        .attr("countryCode",countryCode)
                        .attr("selected",selected)
                        .text(countryName));
    };

    /*
    * Function get restaurant country.
    * @param {string} - Current restaurant country
    */

    /**
    * Change restaurant coutry
    * @param  {string} - Current element change
    */
    this.changeRestaurantCountry = function(target) {
      var restaurantState = '#restaurant_state';
      self.loadStatesByCountryFromWS(restaurantState);
      if(RestaurantObj['restaurantNewRecord'] === 'false') {
        $("#restaurant_state option:first").text("-Select State-");
      }
      $(restaurantState).change();
    };
    this.checkCheckedDay = function(target) {

      if ($(".mon_to_fri:checked").length > 0) {
        //$(".every_day").prop({ disabled: true, checked: false });
        $(".mon_to_fri").not(':checked').prop({ disabled: true, checked: false });
      } else {
        //$(".every_day").prop("disabled", false);
        $(".mon_to_fri").prop("disabled", false);
      }
      if ($(".sat_to_sun:checked").length > 0) {
        //$(".weekends").prop({ disabled: true, checked: false });
        $(".sat_to_sun").not(':checked').prop({ disabled: true, checked: false });
      } else {
        //$(".weekends").prop("disabled", false);
        $(".sat_to_sun").prop("disabled", false);
      }

      if ($(".every_day:checked").length > 0) {
        $(".every_day").each(function(index, value){
          if($(this).is(':checked')){
            //$(".every_day[value="+$(value).val()+"]").not(':checked').prop({ disabled: true, checked: false });
            $(".mon_to_fri").prop({ disabled: true, checked: false });
          }
        });
      } else {
        //$(".mon_to_fri").prop("disabled", false);
      }

      if ($(".weekends:checked").length > 0) {
        $(".weekends").each(function(index, value){
            if($(this).is(':checked')){
              // //console.log(value);
              //$(".weekends[value="+$(value).val()+"]").not(':checked').prop({ disabled: true, checked: false });
              $(".sat_to_sun").prop({ disabled: true, checked: false });
            }
        });
      } else {
        //$(".sat_to_sun").prop("disabled", false);
      }
    };

    this.checkDisabledDay = function(){
      $(".mon_to_fri").prop("disabled", false);
     // $(".every_day").prop("disabled", false);
      //$(".weekends").prop("disabled", false);
      $(".sat_to_sun").prop("disabled", false);
    };

      // if ($(".select_all_day:checked").length > 0) {
      //   $(".every_day").prop({ disabled: true, checked: true });
      //   // $(".mon_to_fri").not(':checked').prop({ disabled: true, checked: false });
      // } else {
      //   $(".every_day").prop("disabled", false);
      //   $(".mon_to_fri").prop("disabled", false);
      // }
      // if ($(".sat_to_sun:checked").length > 0) {
      //   $(".weekends").prop({ disabled: true, checked: false });
      //   $(".sat_to_sun").not(':checked').prop({ disabled: true, checked: false });
      // } else {
      //   $(".weekends").prop("disabled", false);
      //   $(".sat_to_sun").prop("disabled", false);
      // }

      // if ($(".every_day:checked").length > 0) {
        // $(".every_day").each(function(index, value){
        //   if($(this).is(':checked')){
        //     // $(".every_day[value="+$(value).val()+"]").not(':checked').prop({ disabled: true, checked: false });
        //     // $(".mon_to_fri").prop({ disabled: true, checked: false });
        //   }
        // });
      // } else {
      //   //$(".mon_to_fri").prop("disabled", false);
      // }

      // if ($(".weekends:checked").length > 0) {
      //   $(".weekends").each(function(index, value){
      //       if($(this).is(':checked')){
      //         // //console.log(value);
      //         $(".weekends[value="+$(value).val()+"]").not(':checked').prop({ disabled: true, checked: false });
      //         $(".sat_to_sun").prop({ disabled: true, checked: false });
      //       }
      //   });
      // } else {
      //   //$(".sat_to_sun").prop("disabled", false);
      // }
    //};

    // this.checkDisabledDay = function(){
    //   $(".mon_to_fri").prop("disabled", false);
    //   $(".every_day").prop("disabled", false);
    //   $(".weekends").prop("disabled", false);
    //   $(".sat_to_sun").prop("disabled", false);
    // };

    this.viewNameChooseDay = function(){
      // var ids =[]
      // $('.hour_of_operation_day:checked').each(function() {
      //   ids.push($(this).val());
      // });
      // ids_count = ids.length
      // //console.log(ids_count);
    }

    $('#' + this.modelName + '_phone').mask('?(999) 999-9999');
  };


  return RestaurantForm;
})($);

$(document).ready(function() {

  function showErrorWrap(selectorHour, isValidAll){
    if (isValidAll){
      selectorHour.find('.hour_error_message').addClass('hide');
    } else{
      selectorHour.find('.hour_error_message').removeClass('hide');
    }
  }

  function showError(selectorHour, isValid, index){
      if (isValid){
        selectorHour.find('.hour_error_message > div > span:eq('+index+')').addClass('invisible');
      } else{
        selectorHour.find('.hour_error_message > div > span:eq('+index+')').removeClass('invisible');
      }

  }

  // function getUniqueValue(disabledArr){
  //   var uniqueArr = disabledArr.filter(function(itm,i,disabledArr){
  //       return i == disabledArr.indexOf(itm);
  //   });
  //   return uniqueArr;
  // }

  function checkDisabledAll(){
    // checkMaxDay = false;
    // var dayDisabled = $('.hour_of_operation_day');
    // var disabledArr = [];
    // dayDisabled.each(function(idx){
    //   if ($(this).is(":disabled")){
    //     disabledArr.push($(this).val());
    //   }
    // });
    // disabledArr = getUniqueValue(disabledArr);
    // lenghtDayDisabled = disabledArr.length;
    // //console.log("disabledArr",lenghtDayDisabled);
    // //console.log("disabledArr",disabledArr);
    // var checkArray = ["9", "10"];
    // if (lenghtDayDisabled == 2
    //   && $(checkArray).not(disabledArr).length == 0
    //   && $(disabledArr).not(checkArray).length == 0
    //   || lenghtDayDisabled == 7 || lenghtDayDisabled == 9){
    //   checkMaxDay = true;
    // }
    // return checkMaxDay;
  }

  function validateHourOperation(){
    var isValidAll = true;
    $(".clonable_hour_operation").each(function(idx){
        var objValid = getObjValid($(this), false);
        setForceDirty($(this));
        var daySelected = objValid.daySelected;
        var timeOpen = objValid.timeOpen;
        var timeClose = objValid.timeClose;
        var isValidAllOneLine = objValid.isValidAllOneLine;
        // console.log("data:", daySelected, timeOpen, timeClose);
        // console.log("isValidAllOneLine", isValidAllOneLine);

        showErrorWrap($(this), isValidAllOneLine);
        if (!isValidAllOneLine){
            isValidAll = false;
            showError($(this), daySelected, 0);
            showError($(this), timeOpen, 1);
            showError($(this), timeClose, 2);
        }
    });
    return isValidAll;
  }

  //function init(){
  //  validateHourOperation();
  //}
  //init();

  Util.checkBrower();
  var restaurant = new RestaurantForm({
    timepicker: $('.timepicker')
  });

  restaurant.viewTimePicker();
  restaurant.checkCheckedDay();
  // restaurant.viewNameChooseDay();
  // $(".mon_to_fri").on('click', function(){

  $(document).on('click','.mon_to_fri', function() {
    // //console.log('fdshfjkgdsf');
     if ($(".mon_to_fri:checked").length > 0) {
       //$(".every_day").prop({ disabled: true, checked: false });
     } else {
       //$(".every_day").prop("disabled", false);
     }
    if ($(this).is(':checked')) {
       //$(".every_day").not(this).attr("disabled", true);
       $(".mon_to_fri").not(this).attr("disabled", true);
    } else if ($(".every_day").not(':checked')) {
       //$(".every_day").not(this).attr("disabled", false);
       $(".mon_to_fri").not(this).prop("disabled", false);
    }   
  });     
       
  $(document).on('click', '.select_all_day', function() {
    if ($(this).is(":checked")) {
      $(this).closest('.wrapper-checkbox').find(".every_day").prop({checked: true });
    } else {
      $(this).closest('.wrapper-checkbox').find(".every_day").prop({checked: false });
    }
    // if ($(this).is(':checked')) {
    //    $(".every_day").not(this).attr("disabled", true);
    //    $(".mon_to_fri").not(this).attr("disabled", true);
    // } else if ($(".every_day").not(':checked')) {
    //    $(".every_day").not(this).attr("disabled", false);
    //    $(".mon_to_fri").not(this).prop("disabled", false);
    // }
  });

    // $(document).on('click', '.every_day',function(){
    //     if($(".every_day").length == $(".every_day:checked").length) {
    //         $(".select_all_day").prop({checked: true});
    //     } else {
    //         $(".select_all_day").removeAttr("checked");
    //     }
    //  });
  function setForceDirty(parentClosest){
    parentClosest.find("input[type=checkbox]:eq(0)").attr('dirty', true);
    parentClosest.find(".time_open").attr('dirty', true);
    parentClosest.find(".time_close").attr('dirty', true);
  }

  function getObjValid(parentClosest, isDirty){
    var isValidAllOneLine = false;

    var daySelected = parentClosest.find("input[type=checkbox]:checked").length > 0;
    if (isDirty){
      if (!daySelected && parentClosest.find("input[type=checkbox][dirty]").length == 0){
        daySelected = true;
      }
    }

    if (!daySelected){
      parentClosest.find('.day_error').html("Can't be empty!");
    }else{
      parentClosest.find('.day_error').html("");
    }


    var timeOpenVal = parentClosest.find(".time_open").val();
    var timeOpenIndex = parentClosest.find('.time_open option:selected').index();
    var timeOpen = undefined;

    var timeCloseVal = parentClosest.find(".time_close").val();
    var timeCloseIndex = parentClosest.find('.time_close option:selected').index();
    var timeClose = undefined;

    if (timeOpenVal && $.trim(timeOpenVal) != ""){
      timeOpen = true;
      parentClosest.find('.time_open_error').html("");
    } else{
      timeOpen = false;
      parentClosest.find('.time_open_error').html("Can't be empty!");
    }

    if (timeCloseVal && $.trim(timeCloseVal) != ""){
        timeClose = true;
        parentClosest.find('.time_close_error').html("");
    } else{
      timeClose = false;
      parentClosest.find('.time_close_error').html("Can't be empty!");
    }

    // console.log("Valid data:", daySelected, timeOpen, timeClose);
    if (daySelected && timeOpen && timeClose){
      isValidAllOneLine = true;
    }
    return {
      'daySelected': daySelected,
      'timeOpen': timeOpen,
      'timeClose': timeClose,
      'isValidAllOneLine': isValidAllOneLine
    }
  }

  // function validateItem(selector){
  //   console.log("VALIDATE ITEM");
  //   var parentClosest = selector.closest('.clonable_hour_operation');;
  //   var objValid = getObjValid(parentClosest, true);
  //   var daySelected = objValid.daySelected;
  //   var timeOpen = objValid.timeOpen;
  //   var timeClose = objValid.timeClose;
  //   var isValidAllOneLine = objValid.isValidAllOneLine;

  //   showErrorWrap(parentClosest, isValidAllOneLine);
  //   if (!isValidAllOneLine){
  //      showError(parentClosest, daySelected, 0);
  //      showError(parentClosest, timeOpen, 1);
  //      showError(parentClosest, timeClose, 2);
  //   }

  // }

  // $(document).on('change', '.hour_of_operation_day', function(){
  //   $(this).attr('dirty', true);
  //   // validateItem($(this));
  // });
  // $(document).on('change', '.time_open', function(){
  //   $(this).attr('dirty', true);
  //   // validateItem($(this));
  // });
  // $(document).on('change', '.time_close', function(){
  //   $(this).attr('dirty', true);
  //   // validateItem($(this));
  // });

  // $(".every_day").on('click', function(){
   $(document).on('click','.every_day', function() {
     if ($(".every_day:checked").length > 0) {
       $(".mon_to_fri").prop({ disabled: true, checked: false });
     } else {
       $(".mon_to_fri").prop("disabled", false);
     }
     var value = $(this).val();
     closest = $(this).closest(".checkbox-dropdownlist")
     openItem = closest.find(".wrapper-checkbox");
     nameDayChoose = closest.find(".name_day_choose");
     if ($(this).is(':checked')) {
       //$(".every_day[value=" + value + "]").not(this).attr("disabled", true);
       $(".mon_to_fri").attr("disabled", true);
     } else if ($(".every_day").not(':checked')) {
       openItem.find(".select_all_day").prop("checked", false);
       count = $(".every_day:checked").length
       if (count == 0){
         $(".mon_to_fri").prop("disabled", false);
       }
     }
     if (openItem.find(".every_day:checked").length >= 7){
        openItem.find(".select_all_day").prop("checked", true);
        nameDayChoose.html("All days");
     }
  });

  // $(".weekends").on('click', function(){
  $(document).on('click','.weekends', function() {
     if ($(".weekends:checked").length > 0) {
       $(".sat_to_sun").prop({ disabled: true, checked: false });
     } else {
       $(".sat_to_sun").prop("disabled", false);
     }
     var value = $(this).val();
     if ($(this).is(':checked')) {
       //$(".weekends[value=" + value + "]").not(this).attr("disabled", true);
       $(".sat_to_sun").attr("disabled", true);
     } else if ($(".weekends").not(':checked')) {
        // //console.log('BBBBBBBb')
       //$(".weekends[value="+value+"]").not(this).attr("disabled", false);
       count = $(".weekends:checked").length
       if (count == 0){
          $(".sat_to_sun").prop("disabled", false);
       }
     }
  });

  // $(".sat_to_sun").on('click', function(){
  $(document).on('click','.sat_to_sun', function() {
     if ($(".sat_to_sun:checked").length > 0) {
       //$(".weekends").prop({ disabled: true, checked: false });
     } else {
       $(".weekends").prop("disabled", false);
     }
     if ($(this).is(':checked')) {
       //$(".weekends").not(this).attr("disabled", true);
       $(".sat_to_sun").not(this).attr("disabled", true);
     } else if ($(".weekends").not(':checked')) {
       //$(".weekends").not(this).attr("disabled", false);
       $(".sat_to_sun").not(this).prop("disabled", false);
     }
  });

     // if ($(".every_day:checked").length > 0) {
     //   $(".mon_to_fri").prop({ disabled: true, checked: false });
     // } else {
     //   $(".mon_to_fri").prop("disabled", false);
     // }
     // var value = $(this).val();
     // if ($(this).is(':checked')) {
     //   $(".every_day[value=" + value + "]").not(this).attr("disabled", true);
     //   $(".mon_to_fri").attr("disabled", true);
     // } else if ($(".every_day").not(':checked')) {
     //    // //console.log('BBBBBBBb')
     //   $(".every_day[value="+value+"]").not(this).attr("disabled", false);
     //   count = $(".every_day:checked").length
     //   if (count == 0){
     //     $(".mon_to_fri").prop("disabled", false);
     //   }
     // }
  //});

  // $(".weekends").on('click', function(){
  // $(document).on('click','.weekends', function() {
  //    if ($(".weekends:checked").length > 0) {
  //      $(".sat_to_sun").prop({ disabled: true, checked: false });
  //    } else {
  //      $(".sat_to_sun").prop("disabled", false);
  //    }
  //    var value = $(this).val();
  //    if ($(this).is(':checked')) {
  //      $(".weekends[value=" + value + "]").not(this).attr("disabled", true);
  //      $(".sat_to_sun").attr("disabled", true);
  //    } else if ($(".weekends").not(':checked')) {
  //       // //console.log('BBBBBBBb')
  //      $(".weekends[value="+value+"]").not(this).attr("disabled", false);
  //      count = $(".weekends:checked").length
  //      if (count == 0){
  //         $(".sat_to_sun").prop("disabled", false);
  //      }
  //    }
  // });

  // $(".sat_to_sun").on('click', function(){
  // $(document).on('click','.sat_to_sun', function() {
  //    if ($(".sat_to_sun:checked").length > 0) {
  //      $(".weekends").prop({ disabled: true, checked: false });
  //    } else {
  //      $(".weekends").prop("disabled", false);
  //    }
  //    if ($(this).is(':checked')) {
  //      $(".weekends").not(this).attr("disabled", true);
  //      $(".sat_to_sun").not(this).attr("disabled", true);
  //    } else if ($(".weekends").not(':checked')) {
  //      $(".weekends").not(this).attr("disabled", false);
  //      $(".sat_to_sun").not(this).prop("disabled", false);
  //    }
  // });

  $(document).on('click', '.buttonEmulation', function() {
    //if (navigator.userAgent.indexOf("MSIE 10") > 0) {
      restaurant.uploadImage(this);
    //}
  });


    // $('.buttonEmulation').on('click', function(event) {
    //   //console.log('buttonEmulation');
    //   // if (navigator.userAgent.indexOf("MSIE 10") > 0) {
    //     restaurant.uploadImage(this);
    //   // }
    // });

  $(document).on('blur','#restaurant_tax', function() {
    restaurant.coerceTax(this);
  });

  $(document).on('focus','#restaurant_city', function(){
    restaurant.autoCompleteRestaurantCity(this);
  });

  $(document).on('change', '#restaurant_state', function(){
    restaurant.changeRestaurantState(this);
  });

  $(document).on('change', '#restaurant_country', function(){
    restaurant.changeRestaurantCountry(this);
  });


  // var restaurantForm = {};
  // restaurantForm['name'] = new LiveValidation("restaurant_name");
  // restaurantForm['zip'] = new LiveValidation("restaurant_zip");
  // restaurantForm['tax'] = new LiveValidation("restaurant_tax");
  // restaurantForm['phone'] = new LiveValidation("restaurant_phone");
  // restaurantForm['url'] = new LiveValidation("restaurant_url");

  // restaurantForm['name'].add(Validate.Presence);
  // restaurantForm['zip'].add(Validate.Numericality);
  // restaurantForm['zip'].add(Validate.Length, {is: 5});
  // restaurantForm['tax'].add(Validate.Numericality);
  // restaurantForm['tax'].add(Validate.Format, {pattern: /^(\d{1,3})\.(\d{0,2})$/, failureMessage: "Invalid Tax number format. Use: xxx.xx"});
  // restaurantForm['phone'].add(Validate.Format, {pattern: /^\(([0-9]{3})\)([ ])([0-9]{3})([-])([0-9]{4})$/, failureMessage: "Invalid Phone number format. Use: (xxx) xxx-xxxx"});
  // restaurantForm['url'].add(Validate.Format, {pattern: /^[w]{3}\.[\S]+\.[\S]+/});
  Util.validate(restaurant, {
    name: [Validate.Presence],
    zip: [
      Validate.Presence,
      Validate.Numericality,
      [Validate.Length, {is: 5}]
    ],
    address: [Validate.Presence],
    city: [Validate.Presence],
    state: [Validate.Presence],
    country: [Validate.Presence],
    primary_cuisine: [Validate.Presence],
    tax: [
      Validate.Numericality,
      [Validate.Format, {pattern: /^(\d{1,3})\.(\d{0,2})$/, failureMessage: "Invalid Tax number format. Use: xxx.xx"}]
    ],

    phone: [[Validate.Format, {pattern: /^\(([0-9]{3})\)([ ])([0-9]{3})([-])([0-9]{4})$/, failureMessage: "Invalid Phone number format. Use: (xxx) xxx-xxxx"}]],
    // url: [[Validate.Format, {pattern: /^(https?:\/\/)?((w{3}\.)?)[\S]+\.[\S]+/, failureMessage: "Invalid Contact URL format"}]],
    facebook_url:[[Validate.Format, {pattern: /^(https?:\/\/)?((w{3}\.)?)facebook.com\/.*/i, failureMessage: "Invalid Facebook URL format"}]],
    twiter_url:[[Validate.Format, {pattern: /^(https?:\/\/)?((w{3}\.)?)twitter.com\/.*/i, failureMessage: "Invalid Twitter URL format"}]],
    google_url:[[Validate.Format, {pattern: /^(https?:\/\/)?plus.google.com\/.*/i, failureMessage: "Invalid Google Plus URL format"}]],
    //google_url:[[Validate.Format, {pattern: /^[w]{3}\.plus.google.com\/[\s\D]+/i, failureMessage: "Invalid Google Plus URL format"}]],
    // linked_url:[[Validate.Format, {pattern: /^(https?:\/\/)?((w{3}\.)?)linkedin.com\/.*/i, failureMessage: "Invalid Linkedin URL format"}]],
    com_url: [[Validate.Format, {pattern: /^(https?:\/\/)?((w{3}\.)?)[\S]+\.[\S]+/, failureMessage: "Invalid Com URL format"}]],
    instagram_username:[[Validate.Format, {pattern: /^(https?:\/\/)?((w{3}\.)?)instagram.com\/.*/i, failureMessage: "Invalid Instagram URL format"}]]


    // phone: [[Validate.Format, {pattern: /^\(([0-9]{3})\)([ ])([0-9]{3})([-])([0-9]{4})$/, failureMessage: "Invalid Phone number format. Use: (xxx) xxx-xxxx"}]],
    // url: [[Validate.Format, {pattern: /^[w]{3}\.[\S]+\.[\S]+/, failureMessage: "Invalid Contact URL format"}]],
    // facebook_url:[[Validate.Format, {pattern: /^[w]{3}\.facebook.com\/[\s\D]+/i, failureMessage: "Invalid Facebook URL format"}]],
    // twiter_url:[[Validate.Format, {pattern: /^[w]{3}\.twitter\.com\/[\s\D]+/i, failureMessage: "Invalid Twitter URL format"}]],
    // google_url:[[Validate.Format, {pattern: /^(https?:\/\/)?plus.google.com\/[\s\D]+/i, failureMessage: "Invalid Google Plus URL format"}]],
    // //google_url:[[Validate.Format, {pattern: /^[w]{3}\.plus.google.com\/[\s\D]+/i, failureMessage: "Invalid Google Plus URL format"}]],
    // // linked_url:[[Validate.Format, {pattern: /^(https?:\/\/)?((w{3}\.)?)linkedin.com\/.*/i, failureMessage: "Invalid Linkedin URL format"}]],
    // com_url: [[Validate.Format, {pattern: /^[w]{3}\.[\S]+\.[\S]+/, failureMessage: "Invalid Com URL format"}]],
    // instagram_username:[[Validate.Format, {pattern: /^[w]{3}\.instagram.com\/[\s\D]+/i, failureMessage: "Invalid Instagram URL format"}]]

    // instagram_username:[[Validate.Format, {pattern: /^(https?:\/\/)?((w{3}\.)?)instagram.com\/.*/i, failureMessage: "Invalid Instagram URL format"}]]
    // phone: [[Validate.Format, {pattern: /^\(([0-9]{3})\)([ ])([0-9]{3})([-])([0-9]{4})$/, failureMessage: "Invalid Phone number format. Use: (xxx) xxx-xxxx"}]],
    // url: [[Validate.Format, {pattern: /^[w]{3}\.[\S]+\.[\S]+/, failureMessage: "Invalid Contact URL format"}]],
    // facebook_url:[[Validate.Format, {pattern: /^(https?:\/\/)?(([a-z-]{1,5}\.)?)facebook.com\/.*/i, failureMessage: "Invalid Facebook URL format"}]],
    // twiter_url:[[Validate.Format, {pattern: /^(https?:\/\/)?((w{3}\.)?)twitter.com\/.*/i, failureMessage: "Invalid Twitter URL format"}]],
    // google_url:[[Validate.Format, {pattern: /^(https?:\/\/)?((w{3}\.)?)plus.google.com\/.*/i, failureMessage: "Invalid Google Plus URL format"}]],
    // // linked_url:[[Validate.Format, {pattern: /^(https?:\/\/)?((w{3}\.)?)linkedin.com\/.*/i, failureMessage: "Invalid Linkedin URL format"}]],
    // com_url: [[Validate.Format, {pattern: /^[w]{3}\.[\S]+\.[\S]+/, failureMessage: "Invalid Com URL format"}]],
    // // instagram_username:[[Validate.Format, {pattern: /^(https?:\/\/)?((w{3}\.)?)instagram.com\/.*/i, failureMessage: "Invalid Instagram URL format"}]]
  });

  // Crop helper
    $(document).on('click', "div[id^='myModal_image_'] .modal-footer .btn-primary", function() {
      form = $(this).attr('form');
      var rate = $('#' + form + ' #location_image_rate').val();
      var width = $('#' + form + ' #location_image_crop_w').val() * rate;
      var height = $('#' + form + ' #location_image_crop_h').val() * rate;

      var rateLogo = $('#' + form + ' #location_logo_rate').val();
      var widthLogo = $('#' + form + ' #location_logo_crop_w').val() * rateLogo;
      var heightLogo = $('#' + form + ' #location_logo_crop_h').val() * rateLogo;

      if(width < 800 || height < 600){// || widthLogo < 800 || heightLogo < 600) {
        // var r = confirm(Util.errorMessageImage(800,600," above"));
         alert(Util.errorMessageImage(800, 600," above", " crop "));
        // if (r){
        //   $('#' + form).submit();
        // }
        // modal = $(this).parents()[1];
        // $(modal).modal('hide');
        return false;
      }else{
        $('#' + form).submit();
        modal = $(this).parents()[1];
        $(modal).modal('hide');
        return false;
      }
    });

    $(document).on('click', '.crop-btn a', function() {
      image_preview = $($(this).parents()[1]).find("div[id^='myModal_image_']");
      image_preview.find("img").attr("src", image_preview.find("img").attr("src") + "?" + new Date().getTime());
      $.get(image_preview.find("img").attr("src") + "?" + new Date().getTime(), function(){
        image_preview.find("img").attr("src", image_preview.find("img").attr("src") + "?" + new Date().getTime());

        setTimeout(function(){
          image_preview.find("img").attr("src", image_preview.find("img").attr("src") + "?" + new Date().getTime());
          if(!$("div[id^='myModal_image_']").hasClass('in')){
            image_preview.modal();
          }
        }, 3000);
      });
      return false;
    });

    $(document).on('click', '.fakesubmit', function() {
      var checkedValidate = validateHourOperation();
      if(checkedValidate){
        $('#location_form').submit();
        return false;
      }
    });

    $(document).on('change', '.upload-image-menu', function() {
      Util.validateOnUploadImage(this);
      return false;
    });

  var value = 0;
  $(document).on("click", ".rotate_location_logo:not(.waiting)", function(){
    // //console.log('vao');
     var self = $(this);
    if($(this).attr('angle') != undefined){
      var angle = parseInt($(this).attr('angle'));
      value = angle;
    }else {
      value = 0
    }
     $(this).addClass('waiting');
     value +=90;
     if(value > 360){
      value = 90;
     }
     $(this).attr('angle', value);
     $("#image_location_logo").rotate({ angle:value});
     $('#myModal_image_location_logo_form .modal-body img').rotate({ angle:value});

     // $('.crop-btn a').

     var id =$('#image_location_logo').attr('class');
    $.ajax({
      url: '/restaurants/rotate_logo',
      data: {logo: id, direction: value},
      type: 'POST',
      success: function(data) {
        self.removeClass('waiting');
      }
    });

    });

  var valRotateUpload = 0;
  $(document).on("click","img[class*=rotate_location_image]:not(.waiting)", function(){
    $(this).addClass('waiting');
    var self = $(this);
    if($(this).attr('angle') != undefined){
      var angle = parseInt($(this).attr('angle'));
      valRotateUpload = angle
    }else {
      valRotateUpload = 0
    }
    valRotateUpload += 90;

    if(valRotateUpload > 360){
      valRotateUpload = 90;
     }
    //$(this).data('angle', valRotateUpload);
    // $('crop-btn a').addClass('view_rotate');
    $(this).attr('angle', valRotateUpload);
    var form = $(this).closest('form');
    // //console.log(valRotateUpload, form);
    form.find('.modal-body img').rotate({ angle:valRotateUpload});
    form.find("img[id*=image_location_image]").rotate({ angle:valRotateUpload});
    var image_id_upload = form.find("img[id*=image_location_image]").attr('class');
    if (valRotateUpload == 90 || valRotateUpload == 270){
      $('.margin_image').css({
        'margin-bottom': '30px',
        'margin-top': '61px'
      });
     } //else {
    //   $('.margin_image').css({
    //     'margin-bottom': '',
    //     'margin-top': ''
    //   });
    // }
    $.ajax({
      url: '/restaurants/rotate_image',
      data: {image: image_id_upload, direction: valRotateUpload},
      type: 'POST',
      complete: function(){
        self.removeClass('waiting');
      },
      success: function(data) {
        setTimeout(function(){
         self.removeClass('waiting');
        }, 2000);
      },
      error: function(jq,status,message) {
        self.removeClass('waiting');
      }
    });
    self.removeClass('waiting');
  });

  $(document).on('click', 'body', function (evt) {
    var target = evt.target;
    if (!($(target).hasClass('add-nested-attributes') ||
        $(target).hasClass('nested-item') ||
        $(target).hasClass('wrapper-checkbox'))) {
      $(".wrapper-checkbox").addClass('close');
      $(".wrapper-checkbox").parent().find('.add-nested-attributes').removeClass('open-item');
    }
  });

  $(document).on('click', '.name_day_choose', function (evt) {
    $('.name_day_choose').not(this).parent().find(".wrapper-checkbox").addClass('close');
    $('.name_day_choose').not(this).parent().find(".wrapper-checkbox").parent().find('.add-nested-attributes').removeClass('open-item');
  });

   $(document).on('click', '.checkbox-dropdownlist span.add-nested-attributes', function () {
    wrapper_checkbox = $(this).parent().find('.wrapper-checkbox');
    if ($(this).hasClass('open-item')) {
      wrapper_checkbox.addClass('close');
      $(this).removeClass('open-item');
    } else {
      $(this).addClass('open-item');
      wrapper_checkbox.removeClass('close');
    }
  });

  $(document).on('click', ".delete_hour_operation", function() {
    var yourclass=".clonable_hour_operation";  //The class you have used in your form
    var clonecount = $(yourclass).length;
    // console.log("clonecount: ", clonecount);
    // if (clonecount - 1 < 7) {
    //   $('#clonetrigger').removeClass('hide');
    // }
    if (clonecount == 1){
      showErrorWrap($(this).closest(".clonable_hour_operation"), true);
      $(this).closest(".clonable_hour_operation").find('.time_open option:eq(0)').prop("selected", true);
      $(this).closest(".clonable_hour_operation").find('.time_close option:eq(0)').prop("selected", true);
      $('.name_day_choose').text('Choose A Day');
      $('.name_day_choose').append("<span class='caret' style='float:right''></span>");
      // $('.hour_of_operation_day').removeAttr('checked');
      $(".hour_of_operation_day").prop({ disabled: false, checked: false });

    } else {
      $(this).closest(".clonable_hour_operation").remove();
      // restaurant.checkDisabledDay();
      // restaurant.checkCheckedDay();
    }
  });

  $(document).on('click', "#clonetrigger", function() {
       // $('#clonetrigger').click(function() {
      var checkValidate = validateHourOperation();
      if (!checkValidate){
        // alert("Please finish setting current set of hours before creating a new one");
      }
      else {

        // if (checkDisabledAll()){
        //   alert("All days are set hour of operation");
        // } else {
           // if (clonecount + 1 == 7) {
           //   $(this).addClass('hide');
           // }

          var yourclass=".clonable_hour_operation";  //The class you have used in your form
          var clonecount = $(yourclass).length;   //how many clones do we already have?
          // var clonecount = parseInt($(".group_hour_name:last").val());

          var newid = parseInt(clonecount) + 1;

          $(yourclass+":last").fieldclone({      //Clone the original elelement
              newid_: newid,                      //Id of the new clone, (you can pass your own if you want)
              target_: $("#formbuttons"),         //where do we insert the clone? (target element)
              insert_: "before",                  //where do we insert the clone? (after/before/append/prepend...)
              limit_: 100                           //Maximum Number of Clones
          });
          var cloned = $(yourclass+":last")
          // console.log("XXXXXXXXX", cloned);

          cloned.closest(".clonable_hour_operation").find('.time_open option:eq(0)').prop("selected", true);
          cloned.closest(".clonable_hour_operation").find('.time_close option:eq(0)').prop("selected", true);


          var restaurant = new RestaurantForm({
             // timepicker: $('.timepicker')
          });
          // restaurant.viewTimePicker();
      }
         return false;
       // }
  });


  function getFirstItem(arr){
    return arr.slice(0,1)[0]; //return string instead of array
  }

  function getFirstItemArr(arr){
    return arr.slice(0,2); // return array with only one element
  }

  function getLastItem(arr){
    return arr.slice(-1)[0]; //return string instead of array
  }

  function getLastItemArr(arr){
    return arr.slice(-1); // return array with only one element
  }

  function getCorrectOrderDay(arrDaySelected ){
    result = getFirstItemArr(arrDaySelected);
    if (arrDaySelected.length > 2){
      result.push("...");
    }
    return result;
  }


  $(document).on('change', '.wrapper-checkbox input[type=checkbox]', function(e){
      $(this).closest('.clonable_hour_operation').find('.name_day_choose').html('');
      //Get all selected input
      var allSelectorSelected = $(this).parent().parent().find(":checked");
      var label = 'Choose A Day'
     //  //Push all label selected to label
      var arrDaySelected = [];
      allSelectorSelected.each(function(idx){
          arrDaySelected.push($(this).attr('text'));
      });
      //Append ... if data selected greater 1
      if (arrDaySelected.length == 1){
        label = arrDaySelected;
      }else{
          if(arrDaySelected.length > 1 && arrDaySelected.length < 8){
            arrDaySelected = getCorrectOrderDay(arrDaySelected);
            label = arrDaySelected.join(', ');
          }
          if(arrDaySelected.length ==8){
            label ="All days";
          }
      }


      //Caret
      var caretHtml = '<span class="caret" style="float:right;"></span>';

      var content = label + caretHtml;

      //Replace
     $(this).parent().parent().parent().find('> span:eq(0)').html(content);
     validateHourOperation();
  });

  // $(document).on('click', ".hour_of_operation_day", function() {
  //   // var ids =[]
  //   // var ids =[]
  //   // //console.log("ids", ids)
  //   // ids_count = ids.length
  //   // //console.log(ids_count);
  //   // if (ids_count == 0) {
  //   //   $(this).parents().find('.name_day_choose').text('Choose A Day');
  //   //   $(this).parents().find('.name_day_choose').append("<span class='caret' style='margin-left: 17px !important;''></span>");
  //   // }
  //   if ($(this).is(':checked')){
  //     // //console.log("aaaa",$(this).val());
  //     // //console.log($(this).parents().find('.name_day_choose').text());
  //   }
  //   else{
  //   }
  // });


  // $(document).on('change', '.time_close', function(){
  //   var parent = $(this).closest('.clonable_hour_operation');
  //   var time_open_index = parent.find('.time_open option:selected').index();
  //   var time_close_index = parent.find(".time_close option:selected").index();
  //     if (time_close_index <= time_open_index){
  //       parent.find(".hour_error_message").removeClass("hide");
  //       parent.find(".time_close_error").html("The close hour must be later than open hour.");
  //       next_index = time_open_index + 2;
  //       parent.find(".time_close option:nth-child(0)").prop('selected', true);
  //     }else{
  //       parent.find(".time_close_error").html("");

  //     }
  // });

  $(document).on('change','.select-time', function(){
    validateHourOperation();
  });

  $(document).on('click', '.select_all_day', function() {
    var caretHtml = '<span class="caret" style="float:right;"></span>';
    if ($(this).is(":checked")) {
      $(this).closest('.wrapper-checkbox').find(".every_day").prop({checked: true });
      $(this).closest('.clonable_hour_operation').find('.name_day_choose').html('All days' + caretHtml);
    } else {
      $(this).closest('.wrapper-checkbox').find(".every_day").prop({checked: false });
      $(this).closest('.clonable_hour_operation').find('.name_day_choose').html('Choose A Day' + caretHtml);
    }
  });

});
