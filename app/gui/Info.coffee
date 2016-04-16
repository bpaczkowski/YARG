Template = require 'template/info'

# TODO: rewrite this whole mess of a class, including the template
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

  _componentClicked: (component) =>
    if not component and @component
      @component = null
      @main.eventManager.emit 'ComponentHovered'
    else if component
      @component = component
      @main.eventManager.emit 'ComponentHovered', @component
    return

  _componentHovered: (component) =>
    if not component and @component
      @infoContainer.html Template @_getTemplateData 'component', @component
    else
      @infoContainer.html Template @_getTemplateData 'component', component
    return

  _cellHovered: (@tile) =>
    if @component and @tile
      @infoContainer.html Template @_getTemplateData 'buying'
    if not @component
      @infoContainer.html Template @_getTemplateData 'tile', @tile
    return

  _updateState: =>
    if not @component and @tile
      @infoContainer.html Template @_getTemplateData 'tile', @tile
    else if @component and @tile
      @infoContainer.html Template @_getTemplateData 'buying'
    return

  _getTemplateData: (infoType, data) ->
    results =
      infoType: infoType
    switch infoType
      when 'buying'
        results.canBuild = @tile.type.canBuild and @tile.component.type is 'None'
        results.canBuy = @main.money >= @component.price
      when 'tile'
        return unless data?
        results.tileType = data.type.type
        results.name = data.component.name
        if data.component.heatProduction
          results.heatProduction = data.component.heatProduction * @main.getTileHeatMultiplier data
        if data.component.heatAbsorption
          results.heatAbsorption = data.component.heatAbsorption * @main.getTileHeatMultiplier data
        if data.component.heatStore? and data.component.heatStore
          results.heatStore = true
          results.heatValue = data.heatValue.toFixed 0
          results.maxHeat = data.component.maxHeat
        if data.component.lifetime?
          results.lifetimeValue = data.component.lifetime - data.lifetimeValue
          results.maxLifetime = data.component.lifetime
      when 'component'
        return unless data?
        results.name = data.name
        results.price = data.price
        results.lifetime = data.lifetime
        if data.heatProduction
          results.heatProduction = data.heatProduction * @main.getTileHeatMultiplier data
        if data.heatAbsorption
          results.heatAbsorption = data.heatAbsorption * @main.getTileHeatMultiplier data
    results
