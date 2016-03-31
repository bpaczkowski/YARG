Template = require 'template/grid'
Components = require 'config/Components'
$ = require 'jquery'

module.exports = class GridUi
  constructor: (@grid) ->
    @template = Template
    @main = @grid.main
    @_cellWidth = 32

  show: (@gridContainer) ->
    @gridContainer.append($('<div id="gridTable"></div>')
      .width(@grid.width * @_cellWidth)
      .height(@grid.height * @_cellWidth))
    @table = $ '#gridTable'

    @main.eventManager.on 'StateUpdate', @_stateUpdate
    @main.eventManager.on 'GridUpdate', (grid) =>
      @table.html @template @_getGrid @grid
      @elements = @table.find('.tile').toArray()
      @main.eventManager.emit 'StateUpdate', @grid, true
    @main.eventManager.emit 'GridUpdate', @grid

    @table.mouseover (event) =>
      target = $ event.target
      if not target.hasClass 'tile'
        target = target.closest '.tile'
      if not target.hasClass 'tile'
        return
      x = Number target.attr 'data-tile-x'
      y = Number target.attr 'data-tile-y'
      tile = @grid.getTile y, x
      @main.eventManager.emit 'CellHovered', tile
      return
    .mouseleave =>
      @main.eventManager.emit 'CellHovered'
      return
    .click (event) =>
      if not @grid.selectedComponent then return
      target = $ event.target
      x = Number target.attr 'data-tile-x'
      y = Number target.attr 'data-tile-y'
      @grid.buyComponent @grid.selectedComponent, y, x
      return
    return

  _updateTile: (tile) =>
    return unless tile?
    tileElement = @table.find('.tile[data-tile-x=' + tile.x + '][data-tile-y=' + tile.y + ']')
    tileElement.width Math.ceil(tile.heatValue / tile.component.maxHeat * 100) + '%'
    return

  _updateTiles: (tiles) =>
    return unless tiles?
    _updateTile tile for tile in tiles
    return

  _stateUpdate: (grid, force) =>
    if force or @_tileLastUpdate? and Date.now() - @_tileLastUpdate > 1000 / 60
      for tile in grid.tiles
        continue unless tile.component.type isnt 'None'
        if tile.component.heatCanTransfer
          heatBar = $(@elements[tile.index]).find '.heatBarMax .heatBar'
          heatBar.width Math.ceil(tile.heatValue / tile.component.maxHeat * 100) + '%'
        if tile.component.lifetime?
          lifetimeBar = $(@elements[tile.index]).find '.lifetimeBarMax .lifetimeBar'
          lifetimeBar.width 100 - Math.ceil(tile.lifetimeValue / tile.component.lifetime * 100) + '%'
      @_tileLastUpdate = Date.now()
    else unless @_tileLastUpdate?
      @_tileLastUpdate = Date.now()
    return

  _getGrid: (grid) ->
    gridTable =
      tableWidth: grid.width * @_cellWidth
      tableHeight: grid.height * @_cellWidth
      cellWidth: @_cellWidth
      noneImage: Components.none.image
      tiles: []
    for tile in grid.tiles
      gridTable.tiles.push
        x: tile.x
        y: tile.y
        occupied: tile.component.type isnt 'None'
        heatBar: tile.component?.heatCanTransfer
        lifeBar: tile.component?.lifetime?
        image: tile.component.image or Components.placeholder.image
    gridTable