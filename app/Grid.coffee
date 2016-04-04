Tile = require 'Tile'
Components = require 'config/Components'

module.exports = class Grid
  constructor: (@main, @height, @width) ->
    @tiles = (new Tile @, @_1Dto2D(index).column, @_1Dto2D(index).row, index for index in [0...@height * @width])
    @money = 1000000
    @selectedComponent = Components.none
    @tilesToRefresh = []

  _2Dto1D: (row, column) ->
    row * @height + column

  _1Dto2D: (index) ->
    row: Math.floor(index / @height)
    column: index % @height

  # removes duplicate tiles from an array
  _uniqueTileArray: (array) ->
    a = array.concat()
    for i in [0...array.length]
      for j in [i + 1...array.length]
        if a[i]?.index is a[j]?.index
          a.splice j--, 1
    a

  ###
  # 1 parameter: index
  # 2 parameters: row, column
  # returns tile
  ###
  getTile: ->
    if arguments.length is 2
      @tiles[@_2Dto1D(arguments[0], arguments[1])]
    else if arguments.length is 1
      @tiles[arguments[0]]

  tick: ->
    @tickComponents()
    @tickHeat()

    if @tilesToRefresh.length > 0
      @tilesToRefresh = @_uniqueTileArray @tilesToRefresh
      @main.eventManager.emit 'TilesUpdate', @tilesToRefresh
      @tilesToRefresh = []
    @main.eventManager.emit 'StateUpdate', @
    return

  tickComponents: ->
    money = 0
    tilesToRefresh = []
    for tile in @tiles
      changed = false

      # Calculation for 'cell' component type
      if tile.component.type is 'Cell'
        tile.heatValue += tile.component.heatProduction

      # Calculation for 'generator' component type
      if tile.component.type is 'Gen'
        if tile.heatValue < tile.component.heatAbsorption
          absorbed = tile.heatValue
        else
          absorbed = tile.component.heatAbsorption
        tile.heatValue -= absorbed
        money += absorbed * tile.component.heatAbsorbedToMoneyMultiplier

      # Tile lifetime calculation
      if tile.component.type isnt 'None' and tile.component.lifetime?
        if tile.lifetimeValue is tile.component.lifetime
          tile.resetTile()
          changed = true
        else
          tile.lifetimeValue += 1

      # Destroy tile if it gets too hot
      if tile.heatValue > tile.component.maxHeat
        tile.component = Components.none
        tile.resetTile()
        changed = true

      # Push the tile to UI update list
      @tilesToRefresh.push tile if changed

    @addMoney money if money > 0
    return

  tickHeat: ->
    newHeatValues = []
    for tile in @tiles when tile.component.type isnt 'None'
      n = 1
      heat = tile.heatValue

      topTile = tile.getTopTile()
      top = topTile? and topTile.component.type isnt 'None' and topTile.component.heatCanTransfer
      bottomTile = tile.getBottomTile()
      bottom = bottomTile? and bottomTile.component.type isnt 'None' and bottomTile.component.heatCanTransfer
      leftTile = tile.getLeftTile()
      left = leftTile? and leftTile.component.type isnt 'None' and leftTile.component.heatCanTransfer
      rightTile = tile.getRightTile()
      right = rightTile? and rightTile.component.type isnt 'None' and rightTile.component.heatCanTransfer

      if top
        heat += tile.getTopTile().heatValue
        n++
      if bottom
        heat += tile.getBottomTile().heatValue
        n++
      if left
        heat += tile.getLeftTile().heatValue
        n++
      if right
        heat += tile.getRightTile().heatValue
        n++
      newHeatValues.push heat / n
    index = 0
    for tile in @tiles when tile.component.type isnt 'None'
      if tile.heatValue isnt newHeatValues[index]
        tile.heatValue = newHeatValues[index]
      index++
    return

  getTotalHeat: ->
    heat = 0
    (heat += tile.heatValue unless tile.heatValue < 0) for tile in @tiles when tile.component.type isnt 'None'
    heat

  ###
  # sets a tile to the component from the 1st parameter
  # 2nd and 3rd parameter can be either row/column or an index
  ###
  setComponent: ->
    return false if arguments.length < 2
    component = arguments[0]
    if arguments.length is 3
      tile = @getTile arguments[1], arguments[2]
    else if arguments.length is 2
      tile = @getTile arguments[1]

    if tile and tile.type.canBuild
      tile.component = component
      @main.eventManager.emit 'TilesUpdate', [ tile ]
      return true
    return false

  ###
  # buys component from the 1st parameter
  # 2nd and 3rd parameter can be either row/column or an index
  ###
  buyComponent: ->
    return false if arguments.length < 2
    component = arguments[0]
    if arguments.length is 3
      tile = @getTile arguments[1], arguments[2]
    else if arguments.length is 2
      tile = @getTile arguments[1]

    if tile and tile.type.canBuild and
    tile.component.type is 'None' and @money >= component.price
      tile.component = component
      @money -= component.price
      @main.eventManager.emit 'TilesUpdate', [ tile ]
      return true
    return false

  addMoney: (money) ->
    return unless money isnt 0
    @money += money
    @main.eventManager.emit 'OverviewUpdate'
    return
