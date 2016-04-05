Template = require 'template/grid'
Components = require 'config/Components'
$ = require 'jquery'

module.exports = class GridUi
  constructor: (@grid) ->
    @main = @grid.main
    @_cellWidth = 32

  show: (@gridContainer) ->
    @gridContainer.append($('<div id="gridTable"></div>')
      .width(@grid.width * @_cellWidth)
      .height(@grid.height * @_cellWidth))
    @table = $ '#gridTable'
    @table.html Template @_getGrid @grid
    @elements = @table.find('.tile').toArray()

    @main.eventManager.on 'TilesUpdate', @_updateTiles
    @main.eventManager.on 'StateUpdate', @_updateState

    @table.mouseover (event) =>
      target = $ event.target
      if not target.hasClass 'tile'
        target = target.closest '.tile'
      if not target.hasClass 'tile'
        return
      index = Number target.attr 'data-tile-index'
      tile = @grid.getTile index
      @main.eventManager.emit 'CellHovered', tile
      return
    .mouseleave =>
      @main.eventManager.emit 'CellHovered'
      return
    .click (event) =>
      if not @grid.selectedComponent then return
      target = $ event.target
      index = Number target.attr 'data-tile-index'
      @grid.buyComponent @grid.selectedComponent, index
      return
    return

  _updateTile: (tile) =>
    return unless tile?
    tileElement = $(@elements[tile.index])
    if tile.component.type isnt 'None'
      tileElement.css 'background-image', "url(#{tile.component.image or Components.placeholder.image}), url(#{Components.none.image})"
    else
      tileElement.css 'background-image', "url(#{Components.none.image})"

    lifetimeBar = tileElement.find '.lifetimeBarMax .lifetimeBar'
    if tile.component.lifetime?
      if lifetimeBar.length is 0
        lifetimeBar = tileElement
                      .append "<div class=\"lifetimeBarMax\"><div id=\"lifetimeBar#{tile.index}\" class=\"lifetimeBar\"></div></div>"
                      .find '.lifetimeBarMax .lifetimeBar'
      lifetimeBar.width 100 - Math.ceil(tile.lifetimeValue / tile.component.lifetime * 100) + '%'
    else if lifetimeBar.length isnt 0
      lifetimeBar.parent().remove()

    heatBar = tileElement.find '.heatBarMax .heatBar'
    if tile.component.heatCanTransfer
      if heatBar.length is 0
        heatBar = tileElement
                  .append "<div class=\"heatBarMax\"><div id=\"heatBar#{tile.index}\" class=\"heatBar\"></div></div>"
                  .find '.heatBarMax .heatBar'
      heatBar.width Math.ceil(tile.heatValue / tile.component.maxHeat * 100) + '%'
    else if heatBar.length isnt 0
      heatBar.parent().remove()

    return

  _updateTiles: (tiles) =>
    return unless tiles? or tiles.length is 0
    @_updateTile tile for tile in tiles
    return

  _updateState: (grid, force) =>
    if force or @_tileLastUpdate? and Date.now() - @_tileLastUpdate > 1000 / 30
      for tile in grid.tiles when tile.component.type isnt 'None'
        if tile.component.lifetime?
          lifetimeBar = $("#lifetimeBar#{tile.index}")
          lifetimeBar.css 'width', 100 - Math.ceil(tile.lifetimeValue / tile.component.lifetime * 100) + '%'
        if tile.component.heatCanTransfer
          heatBar = $("#heatBar#{tile.index}")
          heatBar.css 'width', Math.ceil(tile.heatValue / tile.component.maxHeat * 100) + '%'
      @_tileLastUpdate = Date.now()
    else unless @_tileLastUpdate?
      @_tileLastUpdate = Date.now()
    return

  _getGrid: (grid) ->
    gridTable =
      cellWidth: @_cellWidth
      noneImage: Components.none.image
      tiles: []
    for tile in grid.tiles
      gridTable.tiles.push tile.index
    gridTable
