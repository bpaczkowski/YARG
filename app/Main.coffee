EventManager = require 'util/EventManager'
Grid = require 'Grid'
GameUi = require 'gui/Game'
Components = require 'config/Components'
Research = require 'config/Research'

module.exports = class Main
  constructor: (@height, @width) ->
    @eventManager = new EventManager()
    @grid = new Grid @, @height, @width
    @money = 20000
    @research = {}
    @gameUi = new GameUi @grid
    @gameUi.show()
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

  addResearchLevel: (research, value) ->
    if @research[research]?
      @research[research] += value
    else
      @research[research] = value

  buyResearchLevel: (research, value) ->
    return false unless Research[research]?
    return false if Research[research].maxLevel? and @research[research]? and @research[research] + value >= Research[research].maxLevel
    price = @getResearchPrice(research)
    if @money >= price
      @addResearchLevel research, value
      @addMoney(-price)
      return true
    return false

  getResearchLevel: (research) ->
    if @research[research]?
      return @research[research]
    return 0

  getResearchPrice: (research, value) ->
    return unless Research[research]?
    if value?
      level = value
    else if @research[research]?
      level = @research[research]
    else
      level = 0
    base = Research[research].basePrice
    mult = Research[research].priceMult
    price = base * Math.pow(mult, level)
    return price

  # accepts either tile or component as parameter
  # calculates heat production/absorption multiplier
  getTileHeatMultiplier: (data) ->
    component = data.component or data
    if component.type is 'Cell'
      if @research.CellProduction1?
        1 + Research.CellProduction1.heatProductionMult * @research.CellProduction1
      else
        1
    else if component.type is 'Gen'
      if @research.GenAbsorption1?
        1 + Research.GenAbsorption1.heatAbsorptionMult * @research.GenAbsorption1
      else
        1

  canBuyResearch: (research, value) ->
    if Research[research].maxLevel? and @research[research]? and @research[research] + (value or 1) >= Research[research].maxLevel
      return 'MaxLevel'
    if @money >= @getResearchPrice research, value
      return 'CanBuy'
    else
      return 'NotEnoughMoney'
