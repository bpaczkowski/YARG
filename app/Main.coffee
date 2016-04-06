EventManager = require 'util/EventManager'
Grid = require 'Grid'
GameUi = require 'gui/Game'
Components = require 'config/Components'

module.exports = class Main
  constructor: (@height, @width) ->
    @eventManager = new EventManager()
    @grid = new Grid @, @height, @width
    @money = 20000
    @gameUi = new GameUi @grid
    @gameUi.show '#app'
    @setupTestGrid()

  addMoney: (money) ->
    return unless money isnt 0
    @money += money
    @eventManager.emit 'OverviewUpdate'
    return

  setupTestGrid: ->
    for row in [0...@height]
      for column in [0...@width]
        if row % 2 is 0
          if column % 2 is 0
            @grid.setComponent Components.Cell1, row, column
          else
            @grid.setComponent Components.Gen2, row, column
        else
          if column % 2 isnt 0
            @grid.setComponent Components.Cell1, row, column
          else
            @grid.setComponent Components.Gen2, row, column
    return

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
