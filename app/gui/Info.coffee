Template = require 'template/info'

module.exports = class InfoUi
  constructor: (@main) ->

  show: (@infoContainer) ->
    @main.eventManager.on 'ComponentHovered', @_componentHovered
    @main.eventManager.on 'ComponentClicked', @_componentClicked
    @main.eventManager.on 'CellHovered', @_cellHovered
    @main.eventManager.on 'StateUpdate', @_updateState
    @main.eventManager.emit 'CellHovered'
    return

  hide: ->
    return false unless @infoContainer?
    @main.eventManager.off 'ComponentHovered', @_componentHovered
    @main.eventManager.off 'ComponentClicked', @_componentClicked
    @main.eventManager.off 'CellHovered', @_cellHovered
    @main.eventManager.off 'StateUpdate', @_updateState
    @infoContainer.html ''
    @infoContainer = null

  _componentHovered: (component) =>
    if not component and @component
      @infoContainer.html Template { @component }
    else
      @infoContainer.html Template { component }
    return

  _componentClicked: (component) =>
    if not component and @component
      @component = null
      @main.eventManager.emit 'ComponentHovered'
    else if component
      @component = component
      @main.eventManager.emit 'ComponentHovered', @component
    return

  _cellHovered: (@tile) =>
    if @component and @tile
      @infoContainer.html Template {
        buying: true,
        canBuild: @tile.type.canBuild and @tile.component.type is 'None',
        canBuy: @main.money >= @component.price
      }
    if not @component
      @infoContainer.html Template { @tile }
    return

  _updateState: =>
    if not @component and @tile
      @infoContainer.html Template { @tile }
    else if @component and @tile
      @infoContainer.html Template {
        buying: true,
        canBuild: @tile.type.canBuild and @tile.component.type is 'None',
        canBuy: @main.money >= @component.price
      }
    return
