# index
$ = require 'jquery'
window.$ = window.jQuery = $
#require 'bootstrap'
_ = require 'underscore'
Animate = require './animate'

# Modal Video
###
$('.bs-video-modal-lg').on 'show.bs.modal', (event) ->
  $button = $(event.relatedTarget)
  url = $button.data 'url'
  iframe = "<iframe width='100%' height='520' src='https://www.youtube.com/embed/#{url}' frameborder='0' allowfullscreen></iframe>"
  $modal = $(this)
  $cont = $modal.find('.modal-content').empty()
  $cont.html iframe
###

# Main Logo fadeIn
$.get('assets/img/main_logo.png').done ()->
  $('h1.brand').css
    opacity: 1
    marginTop: '160px'

# Facebook share
$('.share-fb').click (event)->
  event.preventDefault()
  if FB?
    FB.ui
      method: 'share'
      href: 'http://thehipstervention.com/'
    , (response) ->

# Mobile menu
menu_state = false
$('.open-menu').click (event) ->
  event.preventDefault()
  if menu_state
    menu_state = false
    $('nav').height 64
  else
    menu_state = true
    $('nav').height 471

$('.section-link').click (event)->
  event.preventDefault();
  menu_state = false
  $('nav').height 64
  topdiff = $($(this).attr('href')).position().top;
  $('html,body').animate({ scrollTop: topdiff }, 400);

$('.back-to-top-button, nav .logo').click (event)->
  event.preventDefault();
  $('html,body').animate({ scrollTop: 0 }, 400);


# Animation handle
elements = []
menu = []
$('.animation').each () ->
  if $(this).hasClass('animation-hover') && !$(this).is(':visible')
    return
  item = new Animate $(this), false
  if $(this).hasClass('animation-hover')
    menu.push item
  else
    elements.push item

# Bind them
_.each menu, (el, i, arr) ->
  el.$el.mouseenter el.mouseIn
  el.$el.mouseleave el.mouseOut
  $("nav a[href=##{el.$el.prop('href').split('#')[1]}]").mouseenter el.mouseIn
  $("nav a[href=##{el.$el.prop('href').split('#')[1]}]").mouseleave el.mouseOut

# Load them
i = 0
ani_arr = elements.concat(menu)
ani_cb = () ->
  if i+1 < ani_arr.length
    ani_arr[++i].load ani_cb
ani_arr[i].load ani_cb

# scroll event
throttle_scroll = ()->
  _.each elements, (el, i, arr) ->
    if el.isInView()
      el.start()
    else
      el.stop()

  scrollTop =  $(window).scrollTop()
  $('.back-to-top-cont').css
    opacity: if scrollTop  > 1000 then 1 else 0

  if $(window).width() > 768
    trans = (1-(scrollTop / 1080 *2))
    if trans >= 0 && 1080 * trans < 1080
      $('header').height(1080 * (trans))

  if scrollTop > 341 || $(window).width() <= 768 #$('nav').position().top
    $('header .logo').css
      opacity: 1
  else
    $('header .logo').css
      opacity: 0

$(window).scroll throttle_scroll

# resize event
throttle_resize = _.throttle ()->
  if $(window).width() > 768
    $('header').height 1080
  else
    $('header').height 1076/640 * $(window).width()
  $('.animation:visible').each () ->
    $(this).find('div').css
      marginLeft: ($(this).width() - $(this).find('div').width()) / 2 + 'px'
  $('.news-box').height $('.news-box').width()
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
