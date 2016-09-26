#= require ./index

# TODO refactor -- create separate fileUploader class
@app.methods.checkImageSize = ->
  return unless window.FileReader && window.File && window.FileList && window.Blob

  $(document).on 'change', '#item_image_form .upload-image-menu', ->
    f = this.files[0]
    return if typeof f is 'undefined'

    if f.size > 4000000 || f.fileSize > 4000000
       alert 'Allowed file size exceeded. (Max. 4 MB)'
       @value = null
       return false

