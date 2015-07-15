# index
$ = require 'jquery'
window.$ = window.jQuery = $
require 'bootstrap'
_ = require 'underscore'
Animate = require './animate'

# Modal Video
$('.bs-video-modal-lg').on 'show.bs.modal', (event) ->
  $button = $(event.relatedTarget)
  url = $button.data 'url'
  iframe = "<iframe width='100%' height='520' src='https://www.youtube.com/embed/#{url}' frameborder='0' allowfullscreen></iframe>"
  $modal = $(this)
  $cont = $modal.find('.modal-content').empty()
  $cont.html iframe


# Animation handle
elements = []
menu = []
$('.animation').each () ->
  item = new Animate $(this)
  if $(this).hasClass('animation-hover')
    menu.push item
  else
    elements.push item

_.each menu, (el, i, arr) ->
  el.$el.mouseenter el.mouseIn
  el.$el.mouseleave el.mouseOut
  
throttled = _.throttle ()->
  _.each elements, (el, i, arr) ->
    if el.isInView()
      el.start()
    else
      el.stop()
, 100
$(window).scroll throttled
    
