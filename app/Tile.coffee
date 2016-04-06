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

  setNeighboringTiles: ->
    @topTile = @grid.tiles[@grid._2Dto1D(@y - 1, @x)] if @y > 0
    @bottomTile = @grid.tiles[@grid._2Dto1D(@y + 1, @x)] if @y < @grid.height - 1
    @leftTile = @grid.tiles[@grid._2Dto1D(@y, @x - 1)] if @x > 0
    @rightTile = @grid.tiles[@grid._2Dto1D(@y, @x + 1)] if @x < @grid.width - 1
    return

  getAcceptingNeighbors: ->
    neighbors = []
    neighbors.push @topTile if @topTile? and @topTile.component.canAcceptHeat
    neighbors.push @bottomTile if @bottomTile? and @bottomTile.component.canAcceptHeat
    neighbors.push @leftTile if @leftTile? and @leftTile.component.canAcceptHeat
    neighbors.push @rightTile if @rightTile? and @rightTile.component.canAcceptHeat
    neighbors

  resetTile: ->
    @lifetimeValue = 0
    @heatValue = 0
    @waterValue = 0
    @steamValue = 0
    @component = Components.none
