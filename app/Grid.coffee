Tile = require 'Tile'
Components = require 'config/Components'

module.exports = class Grid
  constructor: (@main, @height, @width) ->
    @tiles = (new Tile @, @_1Dto2D(index).column, @_1Dto2D(index).row, index for index in [0...@height * @width])
    @money = 1000
    @selectedComponent = Components.none

  _2Dto1D: (row, column) ->
    row * @height + column

  _1Dto2D: (index) ->
    row: Math.floor(index / @height)
    column: index % @height

  getTile: (row, column) ->
    @tiles[@_2Dto1D(row, column)]

  tick: ->
    changed = @tickComponents()
    changed = @tickHeat()
    if changed
      @main.eventManager.emit 'StateUpdate', @
    return

  tickComponents: ->
    changed = false
    money = 0
    for tile in @tiles
      if tile.component.type is 'None' and tile.heatValue isnt 0
        tile.heatValue = 0
        changed = true
      if tile.component.type is 'Cell'
        tile.heatValue += tile.component.heatProduction
        changed = true
      if tile.component.type is 'Gen'
        if tile.heatValue < tile.component.heatAbsorption
          absorbed = tile.heatValue
        else
          absorbed = tile.component.heatAbsorption
        tile.heatValue -= absorbed
        changed = true
        money += absorbed * tile.component.heatAbsorbedToMoneyMultiplier
      if tile.component?.lifetime?
        if tile.lifetimeValue == tile.component.lifetime
          tile.resetTile()
          @main.eventManager.emit 'GridUpdate', @
        else
          tile.lifetimeValue += 1
      if tile.heatValue > tile.component.maxHeat
        tile.component = Components.none
        @main.eventManager.emit 'GridUpdate', @
    @addMoney money if money > 0
    changed

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
    changed = false
    index = 0
    for tile in @tiles when tile.component.type isnt 'None'
      if tile.heatValue isnt newHeatValues[index]
        tile.heatValue = newHeatValues[index]
        changed = true
      index++
    changed

  getTotalHeat: ->
    heat = 0
    (heat += tile.heatValue unless tile.heatValue < 0) for tile in @tiles when tile.component.type isnt 'None'
    heat

  setComponent: (component, row, column) ->
    tile = @getTile row, column
    if tile and tile.type.canBuild
      tile.component = component
      @main.eventManager.emit 'GridUpdate', @
      return true
    return false

  buyComponent: (component, row, column) ->
    tile = @getTile row, column
    if tile and tile.type.canBuild and
    tile.component.type is 'None' and @money >= component.price
      tile.component = component
      @money -= component.price
      @main.eventManager.emit 'GridUpdate', @
      return true
    return false

  addMoney: (money) ->
    return unless money isnt 0
    @money += money
    @main.eventManager.emit 'OverviewUpdate'
    return
