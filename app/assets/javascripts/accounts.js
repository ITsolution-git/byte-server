var AccountForm = (function($) {
  "user strict";
  var AccountForm = function(data) {
    var self = this;
    this.modelName = 'user';


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

    this.getListPhysicalCountry = function(target, alt, countryName, countryCode, selected) {
      $(target).append($("<option></option>")
                        .attr("alt",alt)
                        .attr("value",countryName)
                        .attr("countryCode",countryCode)
                        .attr("selected",selected)
                        .text(countryName));
    };
    /**
    * Change account coutry
    * @param  {string} - Current element change
    */
    this.changeAccountCountry = function(target) {
      var accountState = '#user_profile_attributes_physical_state';
      self.loadStateByCountryFromWS(accountState);
      if(AccountObj['accountNewRecord'] === 'false') {
        $("#user_profile_attributes_physical_state option:first").text("-Select State-");
      }
      $(accountState).change();
    };

    /**
    * Change account coutry
    * @param  {string} - Current element change
    */
    this.changeAccountMailingCountry = function(target) {
      var accountMailingCity = '#user_profile_attributes_mailing_state';
      self.loadMailingCityByCountryFromWS(accountMailingCity);
      if(AccountObj['accountNewRecord'] === 'false') {
        $("#user_profile_attributes_mailing_state option:first").text("-Select State-");
      }
      $(accountMailingCity).change();
    };

    /**
    * Change billing coutry
    * @param  {string} - Current element change
    */
    this.changeAccountBillingCountry = function(target) {
      var billingtCity = '#customer_credit_cards_billing_address_region';
      self.loadBillingCityByCountryFromWS(billingtCity);
      if(BillingObj['accountNewRecord'] === 'false') {
        $("#customer_credit_cards_billing_address_region option:first").text("-Select State-");
      }
      $(billingtCity).change();
    };

    this.exportPdf = function(target){
      var str ="month=";
      $('#select-month input[name="multiselect"]').each(function(){
        if($(this).is(":checked")){
          str += $(this).val() + "_";
        }
      });
      if(str == 'month=')
      {
        return alert("Please select at least one month to export");
      }
      else
      {
        window.open("/accounts/export_pdf?" + str);
        // document.location.href = "/accounts/export_pdf?" + str;
        //console.log(document.location.href);
      }
    },

    this.getValueCardTypeChange = function(target) {
      return $(target).val();
    },

    /**
     * Call input[type='file'] clicked trigger
     * @param  {string} target - Current element clicked
     * @return {void}        Type input clicked
     */
    this.uploadImage = function(target) {
      $(target).parent().find("input[type='file']").trigger('click');
    },


    $('#' + self.modelName + '_phone').mask('(999) 999-9999');
  };
  return AccountForm;
})($);

$(document).ready(function() {
  card_type =  $('input[name="credit_card_type"]:checked').val();

  $(document).on('change', 'input[name="customer[credit_cards][card_type]"]', function(){
    card_type = account.getValueCardTypeChange(this);
  });
  $(document).on('change', '#user_profile_attributes_physical_country', function(){
    account.changeAccountCountry(this);
  });
  $(document).on('change', '#user_profile_attributes_mailing_country', function(){
    account.changeAccountMailingCountry(this);
  });

  $(document).on('change', '#customer_credit_cards_billing_address_country_name', function(){
    account.changeAccountBillingCountry(this);
  });

  $(document).on('click', '.buttonEmulation', function() {
    account.uploadImage(this);
  });
  
  $(document).on('change', '.upload-image-menu', function() {
      Util.validateOnUploadImage(this);
      return false;
  });

  $(document).on('focus','#user_profile_attributes_physical_city', function(){
    account.autoCompletePhysicalCity(this);
  });

  $(document).on('focus','#user_profile_attributes_mailing_city', function(){
    account.autoCompleteMailingCity(this);
  });

  $(document).on('focus','#customer_credit_cards_billing_address_locality', function(){
    account.autoCompleteBillingCity(this);
  });

  $(document).on('click', '.crop-btn a', function () {
    // console.log('fdsfd')
    // image_preview = $($(this).parents()[1]).find("div[id^='myModal_image_']");
    // image_preview.find("img").attr("src", image_preview.find("img").attr("src") + "?" + new Date().getTime());
    // image_preview.modal();
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

  $(document).on('click', "div[id^='myModal_image_'] .modal-footer .btn-primary", function () {
    form = $(this).attr('form');

    var rate = $('#' + form + ' #info_avatar_rate').val();
    var width = $('#' + form + ' #info_avatar_crop_w').val() * rate;
    var height = $('#' + form + ' #info_avatar_crop_h').val() * rate;
    
    if(width < 800 || height < 600) {
      alert(Util.errorMessageImage(800, 600, " above", " crop "))
      return false;
    }
    else{
      $('#' + form).submit();
      modal = $(this).parents()[1];
      $(modal).modal('hide');
      return false;
    }
  });
   
  $(document).on('click', '.icon-plus.btn', function() {
    target_id = $(this).attr('data-target');
    target = target_id.substring(1, target_id.length);
    $(this).toggleClass('icon-minus icon-plus');
    target_selector = $('#' + target);
    if (target_selector.hasClass('in')) {
      target_selector.removeClass('in');
    }
    if (!target_selector.hasClass('in')) {
      target_selector.addClass('in');
      target_selector.height('auto');
      target_selector.removeClass('collapseHeight');
    }
    return false;
  });

  $(document).on('click', '.icon-minus.btn', function() {
    target_id = $(this).attr('data-target');
    target = target_id.substring(1, target_id.length);
    $(this).toggleClass("icon-minus icon-plus");
    target_selector = $('#' + target);
    if (!target_selector.hasClass('in')) {
      target_selector.addClass('in');
    }
    if (target_selector.hasClass('in')) {
      target_selector.removeClass('in');
      target_selector.addClass('collapseHeight');
    }
    return false;
  });
  
  $(document).on('click', '.collapsu', function() {
    $(this).parent().parent().find('.togglebtn').trigger("click");
    return false;
  });
  
  $(document).on('click', '.header-menu-mgt', function() {
    $(this).find('.togglebtn').trigger("click");
    return false;
  });

  $(document).on('click', 'body', function (evt) {
    var target = evt.target;
    if (!($(target).hasClass('add-nested-attributes') ||
        $(target).hasClass('nested-item') ||
        $(target).parents('.combo_sub_categories_table').length !== 0 ||
        $(target).hasClass('wrapper-checkbox'))) {
      $(".wrapper-checkbox").addClass('close');
      $(".wrapper-checkbox").parent().find('.add-nested-attributes').removeClass('open-item');
    }
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

   $(document).on('click', '#update_restaurant_form input[name="locations_array[]"]', function(){
     //if ($(this).is(":checked")) {
    if (($('#update_restaurant_form input[name="locations_array[]"]:checked').length) != 0 
        && ($('#update_restaurant_form input[name="locations_array[]"]:checked').length) <= 10){
      // console.log(($('#update_restaurant_form input[name="locations_array[]"]:checked').length))
       $('#btn_submit_modal').attr("disabled", false);
     }else{
       $('#btn_submit_modal').attr("disabled", true);
     }
   });

   $(document).on("click", ".rotate_info_image:not(.waiting)", function(){
     self = $(this);
    if($(this).attr('angle') != undefined){
      var angle = parseInt($(this).attr('angle'));
      value = angle
    }else {
      value = 0
    }
     $(this).addClass('waiting');
     value +=90;
     if(value > 360){
      value = 90;
     }
     $(this).attr('angle', value);
     $("#image_info_image").rotate({ angle:value});
     $('#myModal_image_user_avatar_form .modal-body img').rotate({ angle:value});

     var id =$('#image_info_image').attr('class');
    $.ajax({
      url: 'accounts/rotate_info',
      data: {logo: id, direction: value}, 
      type: 'POST',
      complete: function(){
        self.removeClass('waiting');
      },
      success: function(data) {
        setTimeout(function(){
         self.removeClass('waiting');
        }, 2000);
        // self.removeClass('waiting');
      }
    });
  });


});
