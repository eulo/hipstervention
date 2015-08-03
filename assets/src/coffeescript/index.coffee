# index
$ = require 'jquery'
window.$ = window.jQuery = $
require 'bootstrap'
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
placeholderSupported = typeof $('<input>')[0].placeholder == 'string'

if !placeholderSupported
   $('[placeholder]').focus(()->
     input = $(this)
     if input.val() == input.attr('placeholder')
       input.val('')
       input.removeClass('placeholder')

   ).blur(()->
     input = $(this)
     if input.val() == '' || input.val() == input.attr('placeholder')
       input.addClass('placeholder')
       input.val(input.attr('placeholder'))

   ).blur()

   $('[placeholder]').parents('form').submit ()->
     $(this).find('[placeholder]').each ()->
       input = $(this)
       if input.val() == input.attr('placeholder')
         input.val('')

# Main Logo fadeIn
$.get('assets/img/main_logo.png').done ()->
  $('h1.brand').css
    opacity: 1

# FORM Binds
###
$('select').change ()->
  if $(this).val() == 'SA'
    $('#disclaimer-modal').modal()
    $(this).val('')
###


$.post 'subscribe/index.php', 'list_length=1', (res)->
  if (res.success && res.error)
    $('form').hide()
    #.replaceWith("<div class='row'><h3>#{res.error}</h3></div>");
    $('.free-razor-lead').replaceWith $('.video-section-cont')
  else
    $('form').show()



stop = false;
$('form').submit (event) ->
  if (stop)
    return false;
  if (!$('[name="accept"]').is(":checked"))
    $('form button').text('Accept Terms')
    return false;
  stop = true;
  event.preventDefault()
  $('form button').text('Sending...')
  $.post 'subscribe/index.php', $(this).serialize(), (res) ->
    console.log(res);
    if (!res.success)
      stop = false;
      $('form button').text(res.error || 'Failure, Try again.')
      if (res.field?)
        $("[name='#{res.field}']").css
          borderColor: 'red'
        setTimeout ()->
          $("[name='#{res.field}']").css
            borderColor: 'black'
        , 3000
    else
      $('form button').text('It\'s on the way!')


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
    if $(window).height() > 1080
      imgH = $(window).width() / 1.77
    else
      imgH = 1080
    trans = (1-(scrollTop / imgH *2))
    if trans >= 0 && imgH * trans < imgH
      $('header').height(imgH * (trans))

  if scrollTop > 341 || $(window).width() <= 950 #$('nav').position().top
    $('header .logo').css
      opacity: 1
  else
    $('header .logo').css
      opacity: 0

$(window).scroll throttle_scroll

# resize event
throttle_resize = _.throttle ()->
  if $(window).width() > 768
    if $(window).height() > 1080
      imgH = $(window).width() / 1.77
    else
      imgH = 1080
    $('header').height imgH
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
