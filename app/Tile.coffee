Components = require 'config/Components'
Tiles = require 'config/Tiles'

module.exports = class Tile
  constructor: (@grid, @x, @y, @index) ->
    @main = @grid.main
    @lifetimeValue = 0
    @heatValue = 0
    @waterValue = 0
    @steamValue = 0
    @type = Tiles.Empty
    @component = Components.none

  resetTile: ->
    @lifetimeValue = 0
    @heatValue = 0
    @waterValue = 0
    @steamValue = 0
    @component = Components.none

  getTopTile: ->
    if @y > 0
      @grid.tiles[@grid._2Dto1D(@y - 1, @x)]

  getBottomTile: ->
    if @y < @grid.height - 1
      @grid.tiles[@grid._2Dto1D(@y + 1, @x)]

  getLeftTile: ->
    if @x > 0
      @grid.tiles[@grid._2Dto1D(@y, @x - 1)]

  getRightTile: ->
    if @x < @grid.width - 1
      @grid.tiles[@grid._2Dto1D(@y, @x + 1)]