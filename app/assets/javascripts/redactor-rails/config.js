if (!RedactorPlugins) var RedactorPlugins = {};

RedactorPlugins.advanced = {
  init: function () {
    this.buttonAdd('advanced', 'Advanced', this.pointCallBack);
    this.$btn = $("a.redactor_btn_advanced");
    this.$btn.text('Points');
  },
  pointCallBack: function() {
    this.$btn.parent().html('<input type="text" name="redactor_points" maxlength="10" placeholder="Points" id= "redactor_points" />');
  }
};