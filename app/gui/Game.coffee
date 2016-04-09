Template = require 'template/game'
GridUi = require 'gui/Grid'
InfoUi = require 'gui/Info'
OverviewUi = require 'gui/Overview'
ComponentsUi = require 'gui/Components'
ResearchUi = require 'gui/Research'
$ = require 'jquery'

module.exports = class GameUi
  constructor: (@grid) ->
    @main = @grid.main
    @grid = new GridUi @grid
    @info = new InfoUi @main
    @overview = new OverviewUi @main
    @components = new ComponentsUi @main
    @research = new ResearchUi @main

  show: ->
    @gameContainer = $ '#app'
    @gameContainer.html Template()
    @grid.show $ '#grid'
    @info.show $ '#info'
    @overview.show $ '#overview'
    @components.show $ '#components'
    @research.start()
    return
