EventManager = require 'util/EventManager'
Grid = require 'Grid'
GameUi = require 'gui/Game'
Components = require 'config/Components'

module.exports = class Main
  constructor: (@height, @width) ->
    @eventManager = new EventManager()
    @grid = new Grid @, @height, @width
    @gameUi = new GameUi @grid
    @gameUi.show '#game'
    @grid.setComponent Components.Cell1, 0, 0
    @grid.setComponent Components.Gen2, 0, 1
    @grid.setComponent Components.Cell1, 1, 1
    @grid.setComponent Components.Gen2, 1, 0

  start: ->
    @timer = setInterval =>
      @grid.tick()
      return
    , 100
    return

  stop: ->
    if @timer
      clearInterval @timer
      @timer = null
    return
