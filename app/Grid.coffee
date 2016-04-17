Tile = require 'Tile'
Components = require 'config/Components'

module.exports = class Grid
  constructor: (@main, @height, @width) ->
    @tiles = (new Tile @, @_1Dto2D(index).column, @_1Dto2D(index).row, index for index in [0...@height * @width])
    tile.setNeighboringTiles() for tile in @tiles
    @selectedComponent = Components.none
    @tilesToRefresh = []

  # converts row/column location to index value
  _2Dto1D: (row, column) ->
    row * @height + column

  # converts index value to row/column location
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

    if @tilesToRefresh.length > 0
      @tilesToRefresh = @_uniqueTileArray @tilesToRefresh
      @main.eventManager.emit 'TilesUpdate', @tilesToRefresh
      @tilesToRefresh = []
    @main.eventManager.emit 'StateUpdate', @
    return

  tickComponents: ->
    money = 0
    for tile in @tiles
      changed = false

      # Destroy tile if it gets too hot
      if tile.heatValue > tile.component.maxHeat
        tile.component = Components.none
        tile.resetTile()
        changed = true

      # Tile lifetime calculation
      if tile.component.type isnt 'None' and tile.component.lifetime?
        if tile.lifetimeValue is tile.component.lifetime
          oldComponent = tile.component
          tile.resetTile()
          if @main.research.AutoReplacePlutonium and oldComponent.codename is 'Cell1'
            @buyComponent oldComponent, tile.index, true
          else
            changed = true
        else
          tile.lifetimeValue += 1

      # Calculation for 'cell' component type
      if tile.component.type is 'Cell'
        neighbors = tile.getAcceptingNeighbors()
        if neighbors.length is 0
          tile.resetTile()
          changed = true
        else
          heatProduction = tile.component.heatProduction * @main.getTileHeatMultiplier tile
          heat = heatProduction / neighbors.length
          neighbor.heatValue += heat for neighbor in neighbors

      # Push the tile to UI update list
      @tilesToRefresh.push tile if changed

    # Gen has its own loop so all Gens get heated up before they start absorbing heat
    for tile in @tiles
      # Calculation for 'generator' component type
      if tile.component.type is 'Gen'
        heatAbsorption = tile.component.heatAbsorption * @main.getTileHeatMultiplier tile
        if tile.heatValue < heatAbsorption
          absorbed = tile.heatValue
        else
          absorbed = heatAbsorption
        tile.heatValue -= absorbed
        money += absorbed * tile.component.heatAbsorbedToMoneyMultiplier

    @main.addMoney money if money > 0
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
  # buys component at the specified tile index
  ###
  buyComponent: (component, index, dontRefreshTile) ->
    component = component
    tile = @getTile index

    if tile and tile.type.canBuild and
    tile.component.type is 'None' and @main.money >= component.price
      tile.component = component
      @main.addMoney -component.price
      @main.eventManager.emit 'TilesUpdate', [ tile ] unless dontRefreshTile
      return true
    return false
