Template = require 'template/game'
GridUi = require 'gui/Grid'
InfoUi = require 'gui/Info'
OverviewUi = require 'gui/Overview'
ComponentsUi = require 'gui/Components'
$ = require 'jquery'

module.exports = class GameUi
  constructor: (@grid) ->
    @template = Template
    @main = @grid.main
    @grid = new GridUi @grid
    @info = new InfoUi @main
    @overview = new OverviewUi @main
    @components = new ComponentsUi @main

  show: (@gameContainer) ->
    @gameContainer = $ @gameContainer
    @gameContainer.html @template
    @grid.show @gameContainer.find '#grid'
    @info.show @gameContainer.find '#info'
    @overview.show @gameContainer.find '#overview'
    @components.show @gameContainer.find '#components'
    return
