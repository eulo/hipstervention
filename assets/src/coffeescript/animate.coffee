_ = require 'underscore'

module.exports =
class Animate
  data: {}
  loaded: false
  playing: false
  frame: null
  keys: []
  fps: 8
  interval: null
  offscreenDiff: 100
  noAni: false

  constructor: ($el, load_flag) ->
    @$el = $el
    @$div = $ '<div>'
    if load_flag
      @load()

  load: (callback) =>
    self = @
    @img_src = @$el.data('img')
    @json_src = @$el.data('json')
    if $(window).width() <= 480
      if @$el.parent()[0].nodeName.toLowerCase() == 'h2'
        @noAni = true
        @img_src = @img_src.replace('.png', '_still.png')
      else
        @img_src = @img_src.replace('.png', '_mobile.png')
      @json_src = @json_src.replace('.json', '_mobile.json')

    $.get @json_src, (res) =>
      @data = res.frames
      @img_obj = new Image()
      @img_obj.onload = ->
        self.loaded = true
        self.setup()
        if callback
          callback()
      @img_obj.src = @img_src

  setup: () =>
    dim = @getFirst @data
    @$el.empty()
    @$el.append @$div

    if @noAni
      @$div.css
        backgroundImage: "url(#{@img_src})"
        width: @img_obj.width
        height: @img_obj.height
        backgroundRepeat: "no-repeat"
        backgroundPosition: "center"

      @$div.css
        marginLeft: (@$el.width() - @$div.width()) / 2 + 'px'

    else
      @$div.css
        backgroundImage: "url(#{@img_src})"
        width: dim.frame.w
        height: dim.frame.h
        backgroundPosition: "-#{dim.frame.x}px -#{dim.frame.y}px"

    if !@noAni
      @$div.css
        marginLeft: (@$el.width() - @$div.width()) / 2 + 'px'

    @keys = _.keys @data

  start: () =>
    if !@loaded || @playing || @noAni
      return
    @playing = true
    self = @
    @interval = setInterval () ->
      if self.frame == null
        self.frame = 0
      else
        if self.frame + 1 >= self.keys.length
          self.frame = 0
        else
          self.frame = self.frame + 1

      self.$div.css
        width: self.data[self.keys[self.frame]].frame.w
        height: self.data[self.keys[self.frame]].frame.h
        backgroundPosition: "-#{self.data[self.keys[self.frame]].frame.x}px -#{self.data[self.keys[self.frame]].frame.y}px"

    , 1000 / @fps

  stop: () ->
    @playing = false
    clearInterval @interval

  mouseIn: () =>
    if !@loaded || @playing
      return
    @playing = true
    self = @
    setTimeout ()=>
      self.playing = false
    , 1000
    @interval = setInterval () ->
      if self.frame == null
        self.frame = 0
      else
        if self.frame + 1 < self.keys.length
          self.frame = self.frame + 1
        else
          clearInterval self.interval

      item = self.data[self.keys[self.frame]]
      if !item?
        return

      self.$div.css
        width: item.frame.w
        height: item.frame.h
        backgroundPosition: "-#{item.frame.x}px -#{item.frame.y}px"

    , 1000 / 10

  mouseOut: () =>
    if !@loaded
      return
    clearInterval @interval
    self = @
    @interval = setInterval () ->
      if self.frame - 1 >= 0
        self.frame = self.frame - 1
      else
        clearInterval self.interval

      item = self.data[self.keys[self.frame]]
      if !item?
        return

      self.$div.css
        width: item.frame.w
        height: item.frame.h
        backgroundPosition: "-#{item.frame.x}px -#{item.frame.y}px"

    , 1000 / 10

  getFirst: (obj) ->
    for i of obj
      if obj.hasOwnProperty(i) && typeof(i) != 'function'
        return obj[i]
    return false

  isInView: ()->
    $window = $(window)

    docViewTop = $window.scrollTop()
    docViewBottom = docViewTop + $window.height()

    elemTop = @$div.offset().top
    elemBottom = elemTop + @$div.height()

    return ((elemBottom - @offscreenDiff <= docViewBottom) && (elemTop + @offscreenDiff >= docViewTop))
