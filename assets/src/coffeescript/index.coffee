# index
$ = require 'jquery'
window.$ = window.jQuery = $
require 'bootstrap'

$('.bs-video-modal-lg').on 'show.bs.modal', (event) ->
  $button = $(event.relatedTarget)
  url = $button.data 'url'
  iframe = "<iframe width='100%' height='520' src='https://www.youtube.com/embed/#{url}' frameborder='0' allowfullscreen></iframe>"
  $modal = $(this)
  $cont = $modal.find('.modal-content').empty()
  $cont.html iframe
