var tz = jstz.determine();
createCookie('timezone', tz.name(), 1);

updateSort('sort');
function createCookie(name,value,days) {
    if (days) {
        var date = new Date();
        date.setTime(date.getTime()+(days*24*60*60*1000));
        var expires = "; expires="+date.toGMTString();
    }
    else var expires = "";
    document.cookie = name+"="+value+expires+"; path=/";
}

function updateSort(name){
  var index = -1;
  $("#contact_table th").on("click", function(){
      index = $("#contact_table th").index($("#contact_table th"));
      document.cookie = name+"="+index+"; path=/";
  });
}

var Util = (function($) {
  var Util = {
    /**
     * Redesign validation function to integrate live validation easier
     * @param  {string} model - model validated
     * @param  {object} config - rules definition
     * @return {void} implement live validation to restaurant form
     */
    validate: function(model, config) {
      var form = {};

      for (var element in config) {

        // Auto binding an instanceof LiveValidation
        form[element] = new LiveValidation(model.modelName + "_" + element);
        var el_validation = config[element];

        // Auto mapping validation rules
        // el_validation.forEach(function(args_validation) {
        //   if (!(args_validation instanceof Array)) {
        //     args_validation = [args_validation];
        //   }
        //   form[element].add.apply(form[element], args_validation);
        // });

        $.each(el_validation, function(index, args_validation) {
          if (!(args_validation instanceof Array)) {
            args_validation = [args_validation];
          }
          form[element].add.apply(form[element], args_validation);
        });

      }

      return form;
    },

    enableValidate: function(form, fields) {
      if (!(fields instanceof Array)) {
        fields = [fields];
      }
      fields.forEach(function(field) {
        form[field].enable();
      });
    },

    disableValidate: function(form, fields) {
      if (!(fields instanceof Array)) {
        fields = [fields];
      }
      fields.forEach(function(field) {
        form[field].disable();
      });
    },

    forceNumericOnly: function(scope, e) {
      // Allow special chars + arrows
      if (e.keyCode == 46 || e.keyCode == 8 || e.keyCode == 9
          || e.keyCode == 27 || e.keyCode == 13
          || ((e.keyCode == 67 || e.keyCode == 86 || e.keyCode == 88 || e.keyCode == 65) && e.ctrlKey === true)
          || (e.keyCode >= 35 && e.keyCode <= 39)){
              return;
      } else {
        // If it's not a number stop the keypress
        if (e.shiftKey || (e.keyCode < 48 || e.keyCode > 57) && (e.keyCode < 96 || e.keyCode > 105 )) {
            e.preventDefault();
        }
      }
    },

    removeNoneDigitChar: function(scope, e) {
      $(scope).val($(scope).val().replace(/([^0-9]*)/g, ""));
    },

    checkFileExtension: function(filename, exarray) {
      validextension = false;
      lastpoint = filename.lastIndexOf('.');
      extension = filename.substring(lastpoint + 1, filename.length);
      for (var i = 0; i < exarray.length; i++) {
        if (exarray[i].toLowerCase() === extension.toLowerCase()) {
          validextension = true;
          break;
        }
      }

      return validextension;
    },

    getFileSize: function(sizeInByte) {
      if (sizeInByte > 0) {
        return (sizeInByte / (1024 * 1024))
      }
    },

    //Function upload file image.
    getFileImage: function(element) {
      pathFile = $(element).val();
      if(pathFile && pathFile.trim() !== "") {
        pathFileArr = pathFile.split("\\");
        fileName = pathFileArr[pathFileArr.length - 1];
        form = $($(element).parents()[2]).attr('id');
        $($(element).parents()[2]).find("input[id$='crop_x']").val(0);
        $($(element).parents()[2]).find("input[id$='crop_y']").val(0);
        $($(element).parents()[2]).find("input[id$='crop_w']").val(0);
        $($(element).parents()[2]).find("input[id$='crop_h']").val(0);
        $($(element).parents()[2]).find("input[id$='rate']").val(1);
        //alert(form);
        $('#' + form + '.imageUpload').submit();
      }
    },

    //Function check firefox or chrome
    checkBrower: function(){
      // Check if browser is Firefox
      if (navigator.userAgent.indexOf('Firefox') != -1
      && parseFloat(navigator.userAgent.substring(navigator.userAgent.indexOf('Firefox') + 8)) >= 3.6){//Firefox
      // Simulating choose file for firefox
      //alert('fdfd')
      //$('.uploadImageLogo').html("");
        $('.buttonEmulation').removeClass('hide');
        $('.bootstrap-filestyle').addClass('hidebootstrap-filestyle');
       // $('#location_logo_image').removeClass('filestyle');
        //filestyle hidebutton upload-image-menu
      } else {
        //$('.uploadImageLogo').html("<%= f.file_field :image,:class=>'filestyle hidebutton upload-image-menu', :tabindex => 3, "data-input"=>'false', "data-buttonText"=>"Choose Logo", "data-classInput"=>"input-small" %>");
        $('.buttonEmulation').addClass('hide');
        $('.bootstrap-filestyle').removeClass('hidebootstrap-filestylehidebootstrap-filestyle');
        //$('.upload-image-menu').addClass('filestyle');
      }
    },

    errorMessageImage: function(width, height,position,action){
      return "To get the best quality picture please use images that are "+ width+"x" +height+" and" + position +"."
        +"\nPlease" + action + "other image."
    },

    validateOnUploadImage: function(element, id) {
      if (element.files[0] === undefined) { return false; } //TODO remove when moving functionality to a separate CoffeeScript class

      var exarray = ["jpg", "bmp", "jpeg", "tiff", "max", "png"];
      var validextension = Util.checkFileExtension(element.files[0].name, exarray);
      var filesize = Util.getFileSize(element.files[0].size);
      var _URL = window.URL || window.webkitURL;
      var img = new Image();
      if (filesize > 6) {
        $(element).wrap('<form>').closest('form').get(0).reset();
        $(element).unwrap();
        return alert("Image files must be less than 6 MB.");
      } else if(!validextension){
        $(element).wrap('<form>').closest('form').get(0).reset();
        $(element).unwrap();
        return alert("You must upload an image file with one of the "
            + "following extensions: bmp, jpeg, jpg, tiff, max, png");
      }

      img.onload = function() {
        var width = this.width;
        var height = this.height;
        if ((element.id === 'item_key_image_image') && (width > 50 || height > 50)) {
          $(element).wrap('<form>').closest('form').get(0).reset();
          $(element).unwrap();
          return alert(Util.errorMessageImage(50, 50, " below", " choose "))
        }
        else if((width < 800 || height < 600) && element.id != 'item_key_image_image' && element.id != 'location_logo_image') {
          $(element).wrap('<form>').closest('form').get(0).reset();
          $(element).unwrap();
          return alert(Util.errorMessageImage(800, 600, " above", " choose "))
        }
          Util.getFileImage(element);
      };
      if(element.files[0] != null) {
        img.src = _URL.createObjectURL(element.files[0]);
      }
    },

    resize_image: function(width, height) {
      var originWidth = width;
      var originHeight = height;
      var width = originWidth;
      if (width > 500) {
        width = 500;
      }
      var rate = originWidth / width;
      var height = originHeight / rate;
      // console.log("height :" +height)
      // console.log("width :" +width)
      // console.log("rate :" +rate)
      return {
        'width': width,
        'height': height,
        'rate': rate
      }
    }
  }

  return Util;
})($);
