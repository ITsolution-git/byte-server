var Menu = (function ($) {
  "use strict";
  var menu = {
    server: {
      // Validate function will need this attribute to indicate the validated form
      modelName: 'server'
    },

    menu: {
      // Validate function will need this attribute to indicate the validated form
      modelName: 'menu'
    },

    category: {
      // Validate function will need this attribute to indicate the validated form
      modelName: 'category'
    },

    item_key: {
      // Validate function will need this attribute to indicate the validated form
      modelName: 'item_key'
    },

    item: {
      // Validate function will need this attribute to indicate the validated form
      modelName: 'item'
    },

    combo_item: {
      // Validate function will need this attribute to indicate the validated form
      modelName: 'combo_item'
    },
    item_option: {
      // Validate function will need this attribute to indicate the validated form
      modelName: 'item_option'
    },
    item_option_addon: {
      modelName: 'item_option_addon'
    },

    ComboItem: function() {},

    Order: function(opts) {
      this.typeOrder = opts.type;
      this.listChanged = opts.listChanged;
      this.categoryId = opts.categoryId;
      this.menuId = opts.menuId;
    },

    preview: {
      carouselOptions: {
        pause: true,
        interval: false
      },

      init: function (element) {
        var self = this;
        if (typeof element === 'object') {
          self.carousel = element.carousel;
          self.wrapper = element.wrapper;
          self.category = element.category;
          self.phone = element.phone;
        }
        return self;
      },

      runCarousel: function (config) {
        var self = this;
        $.extend(self.carouselOptions, config);
        $(self.carousel).carousel(config);
        return self;
      },

      resetItemByCategory: function (scope) {
        var self = this;
        var device = $(self.phone).val();
        $.ajax({
          url: "/menus/preview?menu_id=" + $(scope).attr('menu_id') + "&category_id="
              + $(scope).val() + '&device=' + device,
          type: 'get'
        });
      },

      switchPhone: function (scope) {
        $.ajax({
          url: "/menus/switch_device?loc_id=" + $(scope).attr('loc_id') + "&menu_id="
              + $(scope).attr('menu_id') + "&category_id=" + $(scope).attr('category_id') + "&device=" + $(scope).val(),
          type: 'get'
        });
      },

      alignCenterIndicator: function (scope) {
        var indicator = $(scope).find(".wrapper-preview .carousel-indicators");
        indicator.css({"margin-left": -indicator.width()/2});
      },

      pauseCarousel: function (scope) {
        $(scope).carousel('pause');
      },

      changeItem: function (scope) {
        var self = this;
        var currentTarget = $(scope).find('div.active');
        var device = $(self.phone).val();
        var menuId = $(self.category).attr('menu_id');
        var categoryId = $(self.category).val();
        $.ajax({
          url: '/menus/change_item_preview?item_id=' + currentTarget.attr('data-item')
              + '&device=' + device + '&menu_id=' + menuId + '&category_id=' + categoryId,
          type: 'GET'
        });
      }
    },

    form: {
      init: function (input) {
        var self = this;
        self.input = input;
        return self;
      },

      jumpToNextInput: function (event, element) {
        var tabindex = parseInt($(element).attr('tabindex'));
        if (typeof tabindex !== 'undefined') {
          var selectorsStr = "input[tabindex=" + (tabindex + 1) + "]|||select[tabindex=" + (tabindex + 1) + "]|||" +
              "button[tabindex=" + (tabindex + 1) + "]|||textarea[tabindex=" + (tabindex + 1) + "]";
          var selectorsArr = selectorsStr.split('|||');
          var nextBox = [];
          for (var i = 0; i < selectorsArr.length; i++) {
            nextBox = $(selectorsArr[i]);

            if (nextBox.length !== 0) break;

          }
          nextBox.focus();
          nextBox.select();
        }
        event.preventDefault();
      },
    },

    buildMenuForm: {
      init: function (element) {
        var self = this;
        if (typeof element === 'object') {
          self.menu = element.menu;
          self.category = element.category;
          self.location = element.location;
        }
        return self;
      },

      updateItem: function () {
        var self = this;
        var menu_id = $(self.menu).val();
        var categoryId = $(self.category).val();
        var locationId = $(self.location).val();
        $.ajax({
          url: '/menus/update_build_menu_items?menu_id=' + menu_id + '&category_id='
              + categoryId + '&location_id=' + locationId,
          type: 'GET'
        });
      }
    },

    itemForm: {
      init: function (element) {
        var self = this;
        self.form = element.form;
        self.price = element.price;
        return self;
      },

      /**
       * Coerce price to format that have 2 decimal digits. Ex: 12.00
       * @param  {string} target - Current element
       * @return {void}        Coerce price format
       */
      coercePrice: function (target) {
        var value = parseFloat(Math.round($(target).val() * 100) / 100).toFixed(2);
        $(target).val(isNaN(value) ? '' : value);
      },

      validateMainDish: function(item_id, scope) {
        if (item_id) {
          // var extras = '';
          // if($(scope).is(":checked")) {
          //   extras = 'main_dish=true&';
          // }
          // ajax to checking main dish item
          $.ajax({
            url: '/menus/check_main_dish?item_id=' + item_id,
            type: 'GET'
          });
        }
      },

      validateItemKey: function () {
        var self = this;
        var itemKeysLength = $(self.form + ' .nested-item-key:checked').length;
        if (itemKeysLength > 3) {
          alert("Menu Item only has maximum 3 item keys");
          return false;
        }
      }
    },

    imageUpload: {
      init: function (element) {
        var self = this;
        if (typeof element === 'object') {
          self.fileInput = element.fileInput;
          self.fakeBtn = element.fakeBtn;
        }
        return self;
      },

      activeFileInput: function (scope) {
        $(scope).parent().find("input[type='file']").trigger('click');
        return false;
      },
    }
  }

  menu.ComboItem.prototype.displayBtnAddMainDish = function(item_id) {
    var btnAdd = $('.choose_combo .dropdown-toggle');
    var btnAddCommon = $('.is_not_pmi_and_gmi');
    this.invisibleCategories();
    this.updateGUI();
    if (isNaN(parseInt(item_id))) {
      btnAdd.addClass('hide');
      btnAddCommon.addClass('hide');
      return false;
    }
    // btnAddCommon.removeClass('hide')
    btnAdd.removeClass('hide');
    //btnAdd.text('Add');
    btnAdd.html('Add <span class="caret"></span>');
  };

  menu.ComboItem.prototype.validate = function(has_main_dish, isPmiHide, isGmiHide) {
    if (has_main_dish) {
      // Warning if user doesn't choose combo type
      if (!isPmiHide && !isGmiHide) {
        alert('Please add a GMI or PMI to save');
        return false;
      } else if (isGmiHide) {
        // GMI chosen
        var categoriesChosen = $('.combo_sub_categories_table').find('tr');
        var isEmpty = true;
        for(var i = 0, l = $(categoriesChosen).size(); i < l; i++) {
          var target = $(categoriesChosen)[i];
          var quantity = parseInt($($(target).find('.combo-quantity')).val(), 10);
          var flow = parseInt($($(target).find('.combo-flow')).val(), 10);
          // console.log(i, quantity, flow);
          if (!isNaN(quantity) && quantity > 0 && !isNaN(flow) && flow > 0) isEmpty = false;
          if (!isNaN(quantity) && quantity > 0 && !(!isNaN(flow) && flow > 0)) {
            alert('Please enter the flow for the selected category');
            return false;
          }
          if (!isNaN(flow) && flow > 0 && !(!isNaN(quantity) && quantity > 0)) {
            alert('Please enter the quantity for the selected category');
            return false;
          }
        }
        if (isEmpty) {
          alert('Please select category to create combo');
          return false;
        }
      } else if (isPmiHide) {
        // PMI chosen
        var val = [];
        var itemsChecked = $('.wrapper-checkbox input[type="checkbox"]:checked');
        if (itemsChecked.length == 0) {
          alert('Please add menu item to create combo');
          return false;
        }
      }
    }

    var hideButton = $('.combo_main_dish_second').hasClass('hide');
    // console.log(hideButton);
    if(hideButton == false){
      if (isGmiHide){
        //PMI is chosen extend
        var itemsChecked = $('.combo_sub_categories_wrapper_extend .checkbox-dropdownlist .wrapper-checkbox input[type="checkbox"]:checked');
        if (itemsChecked.length == 0) {
          alert('Please add menu item to create combo');
          return false;
        }
      }else if (isPmiHide) {
        //GMI is chosen extend
        var categoriesChosen = $('.combo_sub_categories_table').find('tr');
        var isEmpty = true;
        for(var i = 0, l = $(categoriesChosen).size(); i < l; i++) {
          var target = $(categoriesChosen)[i];
          var quantity = parseInt($($(target).find('.combo-quantity')).val(), 10);
          var flow = parseInt($($(target).find('.combo-flow')).val(), 10);
          // console.log(i, quantity, flow);
          if (!isNaN(quantity) && quantity > 0 && !isNaN(flow) && flow > 0) isEmpty = false;
          if (!isNaN(quantity) && quantity > 0 && !(!isNaN(flow) && flow > 0)) {
            alert('Please enter the flow for the selected category');
            return false;
          }
          if (!isNaN(flow) && flow > 0 && !(!isNaN(quantity) && quantity > 0)) {
            alert('Please enter the quantity for the selected category');
            return false;
          }
        }
        if (isEmpty) {
          alert('Please select category to create combo');
          return false;
        }
      }
    }
  }

  menu.ComboItem.prototype.updateGUI = function(type) {
    var gmi = $('#combo_item_form #combo_main_dish_gmi').parent();
    var pmi = $('#combo_item_form #combo_main_dish_pmi').parent();
    if (type) {
      $('.choose_combo .dropdown-toggle').html(type.toUpperCase() +'<span class="caret"></span>');
    }
    if (type === 'pmi') {
      // Visible gmi and Invisible pmi
      pmi.addClass('hide');
      gmi.removeClass('hide');
    } else if (type === 'gmi') {
      // Visible pmi and Invisible gmi
      gmi.addClass('hide');
      pmi.removeClass('hide');
    } else {
      // Visible both pmi and gmi
      gmi.removeClass('hide');
      pmi.removeClass('hide');
    }
  }

  menu.ComboItem.prototype.invisibleCategories = function() {
    $('.combo_sub_categories_wrapper .combo_sub_categories').html('');
    $('.combo_sub_categories_wrapper').addClass('hide');
  };

  menu.ComboItem.prototype.invisibleMainDish = function() {
    $('.combo_main_dish_built_wrapper').addClass('hide');
    $('.combo_main_dish_built_wrapper .combo_main_dish_built').html('');
  };

  menu.ComboItem.prototype.displayItems = function(menu_id) {
    $('.is_not_pmi_and_gmi').removeClass('hide')
    this.updateGUI('pmi');
    // this.invisibleCategories();
    if (isNaN(parseInt(menu_id))) {
      return false;
    }
    // Call ajax to display items
    $.ajax({
      url: '/menus/' + menu_id + '/display_main_dish/?pmi=true',
      type: 'GET'
    });
  };

  menu.ComboItem.prototype.displayItemsExtend = function(menu_id) {
    // $('.is_not_pmi_and_gmi').removeClass('hide')
    // this.updateGUI('pmi');
    // this.invisibleCategories();
    if (isNaN(parseInt(menu_id))) {
      return false;
    }
    // Call ajax to display items
    $.ajax({
      url: '/menus/' + menu_id + '/display_main_dish_extend/?pmi=true',
      type: 'GET'
    });
  };

  menu.ComboItem.prototype.displayCategories = function(menu_id) {
    $('.is_not_pmi_and_gmi').removeClass('hide')
    this.updateGUI('gmi');
    // this.invisibleItems();
    if (isNaN(parseInt(menu_id))) {
      return false;
    }

    // Call ajax to display categories
    $.ajax({
      url: '/menus/' + menu_id + '/display_categories',
      type: 'GET'
    });
  };

  menu.ComboItem.prototype.displayCategoriesExtend = function(menu_id) {
     // $('.is_not_pmi_and_gmi').removeClass('hide')
    //this.updateGUI('gmi');
    // this.invisibleItems();
    if (isNaN(parseInt(menu_id))) {
      return false;
    }

    // Call ajax to display categories
    $.ajax({
      url: '/menus/' + menu_id + '/display_categories_extend',
      type: 'GET'
    });
  };

  menu.ComboItem.prototype.displayMainDish = function(menu_id) {
    // this.invisibleItems();
    this.invisibleCategories();
    if (isNaN(parseInt(menu_id))) {
      this.invisibleMainDish();
      return false;
    }

    // Call ajax to display item
    $.ajax({
      url: '/menus/' + menu_id + '/display_main_dish',
      type: 'GET',
      success: function(){
        $('.combo_main_dish_second').addClass('hide')
        $('.is_not_pmi_and_gmi').addClass('hide')
        $('.wrap-comboitem-second select').attr('disabled', 'disabled');
        $('.wrap-comboitem-second select').attr('id', 'combo_item_item_id_change');
        $('.wrap-comboitem-second select').attr('name', 'combo_item[item_id_change]');
      }
    });
  };

  menu.Order.prototype.buildSequence = function(scope) {
    var self = this;
    var typeRow = $(scope).find('.right_' + this.typeOrder + '_row');
    var typeIds = [];

    // Build typeIds sequence
    typeRow.each(function(i) {
      typeIds.push($(typeRow[i]).attr(self.typeOrder + '-id'));
    });

    var index = 0;
    var type;

    for (var i = 0, l = this.listChanged.value.length; i < l; i++) {
      type = _.find(this.listChanged.value[i], function(item) {
        var rs = item.menu_id === self.menuId;
        if (!_.isUndefined(self.categoryId)) {
          rs = rs && item.category_id === self.categoryId;
        }
        return rs;
      });

      if (!_.isUndefined(type)) {
        index = i;
        self.listChanged.value.splice(i, 1);
        break;
      }
    }

    var result = [];
    _.each(typeIds, function(typeId) {
      var menuId = self.menuId;

      if (!_.isUndefined(type)) {
        menuId = type.menu_id;
      }
      var obj = {menu_id: menuId}
      if (!_.isUndefined(self.categoryId)) {
        obj['category_id'] = self.categoryId;
      }
      obj[self.typeOrder + '_id'] = typeId;
      result.push(obj);
    });

    return result;
  }

  return menu;
})($);

$(document).ready(function () {

  // $('#image_server_image').css({
  //   'width': parseInt(parseInt($(this).attr('width')) / 5)+'px',
  //   'height': parseInt(parseInt($(this).attr('height')) / 5)+'px'
  // });
  // $('.wrap-comboitem-second select').attr('disabled', 'disabled');
  // console.log($('.choose_combo_extend .dropdown-toggle').val());
  $(document).on('click', '.delete_main_dish', function() {
    var r = confirm("Are you sure to delete?");
    if (r){
      var mainDishWrapper = $('.combo_sub_categories_wrapper_extend .combo_sub_categories .checkbox-dropdownlist');
      $('.is_not_pmi_and_gmi').removeClass('hide');
      $('.combo_main_dish_second').addClass('hide');
      mainDishWrapper.html('');
    }
    // $('#myDiv').children().find('input,select').each(function(){
    //    $(this).val('');
    // });
    // $('.combo_main_dish_second').html('');
  });
  // Combo Item Form
  // =============================================
  var comboItemForm = new Menu.ComboItem();

  //  var check_menu_id = $('#combo_item_form').attr('menu_id');
  // if ($('#combo_item_check_combo_type').val() === 'gmi'){
  //   comboItemForm.displayItemsExtend(check_menu_id);
  //   $('.choose_combo_extend .dropdown-toggle').text('PMI');
  //   $('.choose_combo_extend .dropdown-toggle').val('pmi');
  // } else  if ($('#combo_item_check_combo_type').val() === 'pmi'){
  //    comboItemForm.displayCategoriesExtend(check_menu_id);
  //   $('.choose_combo_extend .dropdown-toggle').text('GMI');
  //   $('.choose_combo_extend .dropdown-toggle').val('gmi');
  // }

  //$(document).on('click', '#btn_link_edit_combo_item', function() {
    //var check_menu_id = $('#combo_item_form').attr('menu_id');
    //if ($('#combo_item_check_combo_type').val() === 'gmi'){
      //comboItemForm.displayItemsExtend(check_menu_id);
      //$('.choose_combo_extend .dropdown-toggle').text('PMI');
      //$('.choose_combo_extend .dropdown-toggle').val('pmi');
    //} else  if ($('#combo_item_check_combo_type').val() === 'pmi'){
      // comboItemForm.displayCategoriesExtend(check_menu_id);
      //$('.choose_combo_extend .dropdown-toggle').text('GMI');
      //$('.choose_combo_extend .dropdown-toggle').val('gmi');
    //}
  //});
  //
  $(document).on('click', '.is_not_pmi_and_gmi', function() {
    // console.log('test click phat coi sao???')
    $(this).addClass('hide');
    $('.combo_main_dish_second').removeClass('hide');
    var menu_id = $('#combo_item_form').attr('menu_id');
    // console.log($('#combo_item_check_combo_type').val() +":  " + $('.remove_check_combo_type').val())
    if ($('#combo_item_check_combo_type').val() == 'gmi'
      || $('.remove_check_combo_type').val() == 'gmi'){
      comboItemForm.displayItemsExtend(menu_id);
    }
    else if ($('#combo_item_check_combo_type').val() == 'pmi'
      || $('.remove_check_combo_type').val() == 'pmi'){
      comboItemForm.displayCategoriesExtend(menu_id);
    }
  });

  $(document).on('change', '#combo_item_form #combo_item_menu_id', function() {
    var menu_id = $(this).val();
    comboItemForm.displayMainDish(menu_id);
  });

  $(document).on('change', '#combo_item_form .wrap-comboitem-first select', function() {
    var item_id = $(this ).val();
    value = $('.wrap-comboitem-first select option:selected').val();
    name = $('.wrap-comboitem-first select option:selected').text();
    // console.log(value +":" + name)
    /*$('#combo_item_item_id_change').append($("<option></option>")
                        .attr("value",value)
                        .text(name));*/
    $('.wrap-comboitem-second select').val(value);

     // $('#combo_item_item_id_change #option_conbo_item').text = name;
     // $('#combo_item_item_id_change #option_conbo_item').value = value;


    comboItemForm.displayBtnAddMainDish(item_id);
  });

  $(document).on('click', '#combo_item_form #combo_main_dish_pmi', function() {
    var hideButton = $('.combo_main_dish_second').hasClass('hide');
    // console.log(hideButton)
      var menu_id = $('#combo_item_form').attr('menu_id');
      $('.choose_combo_extend .dropdown-toggle').text('GMI');
      $('.choose_combo_extend .dropdown-toggle').val('gmi');

      $('#combo_item_check_combo_type').val('pmi');

      //if ($('.check_combo').hasClass('remove_check_combo_type')){
        $('.remove_check_combo_type').val('pmi');
      //}

      if (hideButton == false){
        var r = confirm("If you change the Combo type, your combo information will be reset");
        if (r){
          $('#combo_item_check_combo_type').val('pmi');
           $('.remove_check_combo_type').val('pmi');
          // $('#combo_item_check_combo_type').val('pmi');
          $('.combo_main_dish_second').addClass('hide');
          //comboItemForm.displayItems(menu_id);
          // comboItemForm.displayCategoriesExtend(menu_id);
          $('.choose_combo_extend .dropdown-toggle').text('GMI');
          $('.choose_combo_extend .dropdown-toggle').val('gmi');
        }
        else{
          //comboItemForm.displayCategories(menu_id);
          //comboItemForm.displayItemsExtend(menu_id);
          $('.remove_check_combo_type').val('gmi');
          $('#combo_item_check_combo_type').val('gmi');
          $('.choose_combo_extend .dropdown-toggle').text('PMI');
          $('.choose_combo_extend .dropdown-toggle').val('pmi');
          $('.is_not_pmi_and_gmi').addClass('hide');
        }
      } else {
        comboItemForm.displayItems(menu_id);
        comboItemForm.displayCategoriesExtend(menu_id);
      }
      // $('#combo_item_check_combo_type').val('pmi');
    return false;
  });

  $(document).on('click', '#combo_item_form #combo_main_dish_gmi', function() {
    var hideButton = $('.combo_main_dish_second').hasClass('hide')
    // console.log(hideButton)
      var menu_id = $('#combo_item_form').attr('menu_id');

      $('.choose_combo_extend .dropdown-toggle').text('PMI');
      $('.choose_combo_extend .dropdown-toggle').val('pmi');
      // $('#combo_item_check_combo_type').val('pmi');
      //if ($('.check_combo').hasClass('remove_check_combo_type')){
      $('.remove_check_combo_type').val('gmi');
      $('#combo_item_check_combo_type').val('gmi');
      //}
      $('.gmi_extend').removeClass('hide');
      if (hideButton == false){
        var r = confirm("If you change the Combo type, your combo information will be reset");
        if (r){
          $('.remove_check_combo_type').val('gmi');
          $('#combo_item_check_combo_type').val('gmi');
          $('.combo_main_dish_second').addClass('hide');

          var menu_id = $('#combo_item_form').attr('menu_id');
          comboItemForm.displayCategories(menu_id);
          // comboItemForm.displayItemsExtend(menu_id);
          var mainDishWrapper = $('.combo_sub_categories_wrapper_extend .combo_sub_categories .checkbox-dropdownlist');
          mainDishWrapper.html('');

          $('.choose_combo_extend .dropdown-toggle').text('PMI');
          $('.choose_combo_extend .dropdown-toggle').val('pmi');
          $('.gmi_extend').removeClass('hide');
        }else{
          //comboItemForm.displayItems(menu_id);
          //comboItemForm.displayCategoriesExtend(menu_id);
          $('.remove_check_combo_type').val('pmi');
          $('#combo_item_check_combo_type').val('pmi');
          $('.choose_combo_extend .dropdown-toggle').text('GMI');
          $('.choose_combo_extend .dropdown-toggle').val('pmi');
          $('.is_not_pmi_and_gmi').addClass('hide');
        }
      }
      else {
        comboItemForm.displayCategories(menu_id);
        comboItemForm.displayItemsExtend(menu_id);
      }
      // $('#combo_item_check_combo_type').val('gmi');
      // if !('.combo_main_dish_second').hasClass('hide') {

      // }
    return false;
  });

  $(document).on('click', '.choose_combo .dropdown-menu li a', function() {
    $('.choose_combo').removeClass('open');
  });

  $(document).on('click', '.submit_combo_item', function() {
    var isPmiHide = $('#combo_main_dish_pmi').parent().hasClass('hide');
    var isGmiHide = $('#combo_main_dish_gmi').parent().hasClass('hide');
    var has_main_dish = !!$('#combo_item_item_id').val();
    // console.log("testthu coi ra sao" + isPmiHide + " : " + isGmiHide + " : " + has_main_dish);
    return comboItemForm.validate(has_main_dish, isPmiHide, isGmiHide);
  });

  $(document).on('keyup', '.combo-quantity', function() {
    var value = $(this).val();
    var category_id = $(this).attr('category_id');
    var menu_id = $('#combo_item_form').attr('menu_id');
    //alert('value : '+ value + 'category_id : ' + category_id + 'menu_id : ' + menu_id)
    $.ajax({
      url: '/menus/' + menu_id + '/check_items_quantity?value=' + value + '&category_id=' + category_id,
      type: 'GET'
    });
  });

  $(document).on('keyup', '.combo-flow', function() {
    var self = this;
    var value = $(this).val();
    var flows = $('.combo-flow');
    var flow_values = [];
    flows.each(function(index) {
      if ($(this).val() != "" && self != this && value == $(this).val()) {
        alert('Flow number can’t be duplicate.');
        $(self).val('');
        return false;
      }
    });
  });

  $(document).on('keydown', '.combo-mini-input', function(e) {
    return Util.forceNumericOnly(this, e);
  });

  $(document).on('keyup', '.combo-mini-input', function(e) {
    return Util.removeNoneDigitChar(this, e);
  });

  // Preview block
  // =============================================
  var preview = Menu.preview.init({
    wrapper: "div[id^='myModal_menu_']",
    category: "div[id^='myModal_menu_'] #category",
    phone: '.switch-phone select',
    carousel: '.carousel'
  }).runCarousel();

  $(document).on('mouseleave', preview.carousel, function () {
    preview.pauseCarousel(this);
  });

  $(document).on('slid', preview.carousel, function () {
    preview.changeItem(this);
  });

  $(document).on('change', preview.category, function () {
    preview.resetItemByCategory(this);
  });

  $(document).on('change', preview.phone, function () {
    preview.switchPhone(this);
  });

  $(document).on('shown', preview.wrapper, function () {
    preview.alignCenterIndicator(this);
  });

  $(document).on('click', '.item_combo_type', function() {
    var wrapper = $(this).parent();
    var $current_symbol = $(wrapper).find('.item_combo_type_icon');
    if ($current_symbol.hasClass('inactive')) {
      var kclass = $(this).attr('type_combo').toLowerCase();
      $('.item_combo_type_icon').addClass('hide inactive');
      $('.category_combo_type_icon').addClass('hide');
      $('.item_combo_type_sub_icon').addClass('hide');
      $(wrapper).find('.item_combo_type_icon').removeClass('hide inactive').addClass(kclass);
      var menus = $(this).closest('div[id^="wrapper_menu_container_"]');
      var categories = $(this).find('div[id^="Category_"]');
      var combo_item_id = $(this).attr('combo-item-id');

      $.ajax({
        url: '/menus/display_combo_on_build_menu?combo_id=' + combo_item_id,
        type: 'GET'
      });
    } else {
      $('.item_combo_type_icon').addClass('hide inactive');
      $('.category_combo_type_icon').addClass('hide');
      $('.item_combo_type_sub_icon').addClass('hide');
    }

  });

  // Form block
  // =============================================
  var form = Menu.form.init('input, select');

  $(document).on('keypress', form.input, function (event) {
    if (event.keyCode === 13) {
      form.jumpToNextInput(event, this);
    }
  });

  // Build Menu Form block
  // =============================================
  var buildMenuForm = Menu.buildMenuForm.init({
    menu: '#build_menu_menu_id',
    category: '#build_menu_category_id',
    location: '#new_build_menu #location_id'
  });

  $(document).on('change', buildMenuForm.menu + ', ' + buildMenuForm.category, function () {
    buildMenuForm.updateItem(this);
  });

  // Item Form block
  // =============================================
  var itemForm = Menu.itemForm.init({
    form: '#menu_item_form',
    price: '#item_price'
  });

  $(document).on('click', itemForm.form + ' .nested-item', function () {
    return itemForm.validateItemKey();
  });

  $(document).on('change', '#item_is_main_dish', function() {
    // console.log("change");
    itemForm.validateMainDish($('#item_id').val(), this);
  });

  $(document).on('blur', itemForm.price, function (e) {
    itemForm.coercePrice(e.target);
  });

  // All Image Upload
  // =============================================
  var imageUpload = Menu.imageUpload.init({
    fileInput: '.upload-image-menu',
    fakeBtn: '.buttonEmulation'
  });

  $(document).on('click', imageUpload.fakeBtn, function () {
    imageUpload.activeFileInput(this);
  });

  $(document).on('change', imageUpload.fileInput, function() {
    Util.validateOnUploadImage(this);
  });

  // Other
  // =============================================
  $(document).on('click', '#submit_menu_calendar', function () {
    backup_my_date_year = $('#date_year').val();
    backup_my_date_month = $('#date_month').val();
    backup_my_date_day = $('#date_day').val();
    backup_my_date_hour = $('#date_hour').val();
    backup_my_date_minute = $('#date_minute').val();

    backup_repeat_time_hour = $('#date_repeat_hour_from').val();
    backup_repeat_time_minute = $('#date_repeat_minute_from').val();

    backup_repeat_time_to_hour = $('#date_repeat_hour_to').val();
    backup_repeat_time_to_minute = $('#date_repeat_minute_to').val();

    if ((backup_repeat_time_hour + ':' + backup_repeat_time_minute) > (backup_repeat_time_to_hour + ':' + backup_repeat_time_to_minute)) {
      alert('The repeat time is invalid. Please choose again!');
      return false;
    }

    var my_date = Date.parse($('#date_year').val() + '-' + $('#date_month').val() + '-' + $('#date_day').val() + ' ' + $('#date_hour').val() +
        ':' + $('#date_minute').val());
    $('#date_year').val(my_date.getUTCFullYear());
    $('#date_month').val(my_date.getUTCMonth() + 1);
    $('#date_day').val(my_date.getUTCDate());
    $('#date_hour').val(my_date.getUTCHours() < 10 ? ("0" + my_date.getUTCHours()) : my_date.getUTCHours());
    $('#date_minute').val(my_date.getUTCMinutes() < 10 ? ("0" + my_date.getUTCMinutes()) : my_date.getUTCMinutes());

    var today = new Date();
    var month = today.getMonth() + 1;
    var today_string = today.getUTCFullYear() + '-' + month + '-' + today.getUTCDate() + ' ';
    var repeat_time = Date.parse(today_string + $('#date_repeat_hour_from').val() + ':' + $('#date_repeat_minute_from').val());
    $('#date_repeat_hour_from').val(repeat_time.getUTCHours() < 10 ? ("0" + repeat_time.getUTCHours()) : repeat_time.getUTCHours());
    $('#date_repeat_minute_from').val(repeat_time.getUTCMinutes() < 10 ? ("0" + repeat_time.getUTCMinutes()) : repeat_time.getUTCMinutes());

    var repeat_time_to = Date.parse(today_string + $('#date_repeat_hour_to').val() + ':' + $('#date_repeat_minute_to').val());
    $('#date_repeat_hour_to').val(repeat_time_to.getUTCHours() < 10 ? ("0" + repeat_time_to.getUTCHours()) : repeat_time_to.getUTCHours());
    $('#date_repeat_minute_to').val(repeat_time_to.getUTCMinutes() < 10 ? ("0" + repeat_time_to.getUTCMinutes()) : repeat_time_to.getUTCMinutes());

    $('#menu_calendar').submit();

    $('#date_year').val(backup_my_date_year);
    $('#date_month').val(backup_my_date_month);
    $('#date_day').val(backup_my_date_day);
    $('#date_hour').val(backup_my_date_hour);
    $('#date_minute').val(backup_my_date_minute);

    $('#date_repeat_hour_from').val(backup_repeat_time_hour);
    $('#date_repeat_minute_from').val(backup_repeat_time_minute);

    $('#date_repeat_hour_to').val(backup_repeat_time_to_hour);
    $('#date_repeat_minute_to').val(backup_repeat_time_to_minute);

    return false;
  });

  $(document).on('change', '#date_month', function () {
    var year = (new Date()).getFullYear();
    var dateMonth = $(this);
    var dateDay = dateMonth.parent().find('#date_day');

    var append_date = function (date_appended, desc) {
      for (var i in date_appended) {
        if (desc.find("option[value='" + date_appended[i] + "']").length === 0) {
          desc.append('<option value="' + date_appended[i] + '">' + date_appended[i] + '</option>');
        }
      }
    };

    var remove_date = function (date_removed, desc) {
      for (var i in date_removed) {
        if (desc.find("option[value='" + date_removed[i] + "']").length !== 0) {
          desc.find("option[value='" + date_removed[i] + "']").remove();
        }
      }
    };

    switch (dateMonth.val()) {
      case '4':
      case '6':
      case '9':
      case '11':
        remove_date([31], dateDay);
        append_date([29, 30], dateDay);
        break;
      case '2':
        remove_date([29, 30, 31], dateDay);
        var date_appended = (year % 4 == 0 && year % 100) || year % 400 == 0 ? 29 : 28;
        append_date([date_appended], dateDay);
        break;
      default:
        append_date([29, 30, 31], dateDay);
        break;
    }
  });

  $(document).on('click', '.crop-btn a', function () {
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

  $(document).on('click', "div[id^='myModal_image_'] .modal-footer .btn-primary", function () {
    form = $(this).attr('form');

    var rate = $('#' + form + ' #server_avatar_rate').val();
    var width = $('#' + form + ' #server_avatar_crop_w').val() * rate;
    var height = $('#' + form + ' #server_avatar_crop_h').val() * rate;

    var rateItemKey = $('#' + form + ' #item_key_image_rate').val();
    var widthItemKey = $('#' + form + ' #item_key_image_crop_w').val() * rateItemKey;
    var heightItemKey = $('#' + form + ' #item_key_image_crop_h').val() * rateItemKey;

    var rateItem = $('#' + form + ' #item_image_rate').val();
    var widthItem = $('#' + form + ' #item_image_crop_w').val() * rateItem;
    var heightItem = $('#' + form + ' #item_image_crop_h').val() * rateItem;
    //var r ;
    if(widthItemKey > 0 || heightItemKey > 0 || widthItem > 0 || heightItem > 0 ||
      width > 0 || height > 0){
      if (widthItemKey > 50 || heightItemKey > 50) {
        //r = confirm(Util.errorMessageImage(50, 50, " below"));
         alert(Util.errorMessageImage(50, 50, " below", " crop "))
         return false;
      }
      else if(widthItem < 800 || heightItem < 600 || width < 800 || height < 600) {
        //r = confirm(Util.errorMessageImage(800, 600, " above"));
         alert(Util.errorMessageImage(800, 600, " above", " crop "))
         return false;
      }
      else{
        $('#' + form).submit();
        modal = $(this).parents()[1];
        $(modal).modal('hide');
        return false;
      }
      //if (r){
        //$('#' + form).submit();
      //}
      //modal = $(this).parents()[1];
      //$(modal).modal('hide');
      //return false;
    }
  });

  $(document).on('click', '.icon-plus.btn', function () {
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

  $(document).on('click', '.icon-minus.btn', function () {
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

  $(document).on('click', '.header-menu-mgt', function () {
    $(this).find('.togglebtn').trigger("click");
    return false;
  });

  $(document).on('click', '.collapsu', function () {
    $(this).parent().parent().find('.togglebtn').trigger("click");
    return false;
  });


  $(document).on("click", ".rotate_server_image:not(.waiting)", function(){
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
     // $("#image_server_image").css({

     //      // 'margin-top': '-40px',
     //      // 'max-width': '100px'
     //  });
     if (value == 90 || value == 270){
        $("#image_server_image").css({
          'max-height': '165px',
          'margin-top': '12px'
          // 'margin-top': '-40px',
          // 'max-width': '100px'
        });
     }
     else {
        $("#image_server_image").css({
          'margin-top': '',
          'max-height': ''
        });
     }
     $(this).attr('angle', value);
     $("#image_server_image").rotate({ angle:value});
     $('#myModal_image_server_avatar_form .modal-body img').rotate({ angle:value});

     var id =$('#image_server_image').attr('class');
    $.ajax({
      url: 'menus/rotate_server',
      data: {logo: id, direction: value},
      type: 'POST',
      success: function(data) {
        // self.removeClass('waiting');
        setTimeout(function(){
         self.removeClass('waiting');
        }, 2000);
      }
    });
  });

  $(document).on("click", ".rotate_item_key_image:not(.waiting)", function(){
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
     $("#image_item_key_image").rotate({ angle:value});
     $('#myModal_image_item_key_image_form .modal-body img').rotate({ angle:value});

     var id =$('#image_item_key_image').attr('class');
    $.ajax({
      url: 'menus/rotate_item_key',
      data: {logo: id, direction: value},
      type: 'POST',
      success: function(data) {
        setTimeout(function(){
         self.removeClass('waiting');
        }, 2000);
        // self.removeClass('waiting');
      }
    });
  });

  $(document).on("click", ".rotate_item_image:not(.waiting)", function(){
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

     if (value == 90 || value == 270){
        $("#image_item_image").css({
          'max-height': '165px',
          'margin-top': '12px'
          // 'margin-top': '-40px',
          // 'max-width': '100px'
        });
     }
     else {
        $("#image_item_image").css({
          'margin-top': '',
          'max-height': ''
        });
     }

     $(this).attr('angle', value);
     $("#image_item_image").rotate({ angle:value});
     $('#myModal_image_item_image_form .modal-body img').rotate({ angle:value});

     var id =$('#image_item_image').attr('class');
    $.ajax({
      url: 'menus/rotate_item',
      data: {logo: id, direction: value},
      type: 'POST',
      success: function(data) {
        setTimeout(function(){
         self.removeClass('waiting');
        }, 2000);
        // self.removeClass('waiting');
      }
    });
  });
  $(document).on("click", ".playTutorial", function(){
    var vidID = $(this).attr('id');
    $( '#' + vidID + ".tutorialVideo" ).toggle();
  });
});


/* =========MENU OPTION=========== */
function getObjValid(parentClosest){
    var isValidAllOneLine = false;
    var add_on_name = false;
    var price = false;

    var add_on_name_obj = parentClosest.find(".add_on_name");
    var price_obj = parentClosest.find(".price");

    if (add_on_name_obj.val() === ''){
      parentClosest.find('.add_on_name_error').html("Can't be empty!");
    }else{
      if (add_on_name_obj.val().length > 30){
        parentClosest.find('.add_on_name_error').html("Please use between 1 and 30 characters");
      }else{
        add_on_name = true;
        parentClosest.find('.add_on_name_error').html("");
      }
    }

    if (price_obj.val() === ''){
      price_obj.val("0.00");
      price = true;
    }else{
      pattern = /^(\d{1,3})\.(\d*)$/;
      pattern2 = /\d/;
      pattern3 = /^(\d{1,3})\.(\d)$/;
      pattern4 = /^(\d{1,3})$/;
      if (!pattern2.test(price_obj.val())){
        parentClosest.find('.price_error').html("Must be a number");
      }else{
        if (pattern4.test(price_obj.val())){
          price_obj.val(price_obj.val() + ".00")
          price = true;
          parentClosest.find('.price_error').html("");
        }else{
          if (!pattern.test(price_obj.val())){
            parentClosest.find('.price_error').html("Invalid Price number format. Use: xxx.xx");
          }else{
            if (pattern3.test(price_obj.val())){
              price_obj.val(price_obj.val() + "0")
            }else{
              price_obj.val(parseFloat(price_obj.val()).toFixed(2))
            }
            price = true;
            parentClosest.find('.price_error').html("");
          }
        }
      }
    }

    if (add_on_name && price){
      isValidAllOneLine = true;
    }
    return {
      'add_on_name': add_on_name,
      'price': price,
      'isValidAllOneLine': isValidAllOneLine
    }
}

function validateMenuOption(){
  var isValidAll = true;

  if ($("#item_option_name").val() === ''){
    $(".item_option_name_error").removeClass("hide");
    $(".item_option_name_error").html("Can't be empty!");
    isValidAll = false;
  }else{
    if ($("#item_option_name").val().length > 30){
      $(".item_option_name_error").removeClass("hide");
      $(".item_option_name_error").html("Please use between 1 and 30 characters");
    }else{
      $(".item_option_name_error").addClass("hide");
    }
  }
  $(".add-on").each(function(idx){
      var objValid = getObjValid($(this));

      var add_on_name = objValid.add_on_name;
      var price = objValid.price;

      var isValidAllOneLine = objValid.isValidAllOneLine;
      if (!isValidAllOneLine){
        $(this).find(".errors-area").removeClass('hide');
        isValidAll = false;
      }else{
        $(this).find(".errors-area").addClass('hide');
      }
  });
  return isValidAll;
}

$(document).on('change','.add_on_name, .price', function(){
  validateMenuOption();
});

$(document).on('change','#item_option_name', function(){
  if ($("#item_option_name").val() === ''){
    $(".item_option_name_error").addClass("hide");
    $(".item_option_name_error").html("Can't be empty!");
  }else{
    if ($("#item_option_name").val().length > 30){
      $(".item_option_name_error").removeClass("hide");
      $(".item_option_name_error").html("Please use between 1 and 30 characters");
    }else{
      $(".item_option_name_error").addClass("hide");
    }
  }
});

$(document).on('click', ".clone", function() {
  if (validateMenuOption()){
    $(this).closest(".add-on").find(".errors-area").addClass('hide');
    $(this).closest(".add-on").find(".add_on_name_error").html("")
    var $ele_clone = $(".add-on:last").clone();
    $ele_clone.find(".add_on_name").val('')
    $ele_clone.find(".price").val('')
    $ele_clone.find(".selected").prop("checked", false);

    $('.add-on').parent().append($ele_clone);
    $('.add-on').not(":last").find('.clone').hide();
  }
});

$(document).on('click', '#item_option_select_one', function() {
  if($(this).is(":checked")){
    $('.selected').prop("checked", false);
  }
});

$(document).on('click', '.selected', function() {
  if($('#item_option_select_one').is(":checked") && $(".selected").length > 1){
    $('.selected').prop("checked", false);
    $(this).prop("checked", true);
  }
});

  // $(document).off('click', '#submit_menu_option_form');
$(document).on('click', '#submit_menu_option_form', function() {
  var check = validateMenuOption();
  if(check){
    $('#submit_menu_option_form').attr("disabled", "disabled");
    $('#menu_option_form').submit();
  }
});

$(document).on('click', ".delete-add-on", function() {
  var yourclass=".add-on";
  var clonecount = $(yourclass).length;

  if (clonecount == 1){
    $(this).closest(".add-on").find('.selected').prop("checked", false);
    $(this).closest(".add-on").find('.add_on_name').val('');
    $(this).closest(".add-on").find('.price').val('');
  } else {
    $(this).closest(".add-on").remove();
  }

  $('.add-on:last').find('.clone').show();
  validateMenuOption();
  $(".errors-area").addClass('hide');
});

/* =========END MENU OPTION=========== */
