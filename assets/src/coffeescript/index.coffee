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
  if !$(this).is(':visible')
    return
  item = new Animate $(this)
  if $(this).hasClass('animation-hover')
    menu.push item
  else
    elements.push item

_.each menu, (el, i, arr) ->
  el.$el.mouseenter el.mouseIn
  el.$el.mouseleave el.mouseOut

# scroll event
throttle_scroll = _.throttle ()->
  _.each elements, (el, i, arr) ->
    if el.isInView()
      el.start()
    else
      el.stop()
, 1000
$(window).scroll throttle_scroll

# resize event
throttle_resize = _.throttle ()->
  if $(window).width() > 768
    $('header').height 900
  else
    $('header').height 1076/640 * $(window).width()
  $('.animation:visible').each () ->
    $(this).find('div').css
      marginLeft: ($(this).width() - $(this).find('div').width()) / 2 + 'px'
  ###
  $('h2').each ()->
    diff = ($(this).height() - $(this).find('.animation').height()) / 2
    $(this).css
      marginTop: "-#{diff}px"
      marginBottom: "-#{diff}px"
  ###
, 400
$(window).resize throttle_resize
throttle_resize()
