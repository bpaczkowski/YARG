Template = require 'template/components'
Components = require 'config/Components'
$ = require 'jquery'

module.exports = class ComponentsUi
  constructor: (@main) ->
    @template = Template

  show: (@componentsContainer) ->
    @componentsContainer.html @template {
      components: @_getComponents(),
      placeholder: Components.placeholder
    }
    @table = @componentsContainer.find '#componentsTable'
    @table.mouseover (event) =>
      target = $ event.target
      if target.attr('component') and Components[target.attr 'component']
        @main.eventManager.emit 'ComponentHovered', Components[target.attr 'component']
      else
        @main.eventManager.emit 'ComponentHovered'
      return
    .mouseleave =>
      @main.eventManager.emit 'ComponentHovered'
      return
    .click (event) =>
      target = $ event.target
      if target.attr('component') and Components[target.attr 'component']
        if not @componentElement? or not @componentElement.is target
          @componentElement.removeClass 'selected' if @componentElement?
          @componentElement = target
          @componentElement.addClass 'selected'
          @component = Components[target.attr 'component']
          @main.eventManager.emit 'ComponentClicked', @component
          @main.grid.selectedComponent = @component
        else
          @componentElement.removeClass 'selected'
          @componentElement = null
          @component = null
          @main.eventManager.emit 'ComponentClicked'
          @main.grid.selectedComponent = null
      return

  _getComponents: ->
    results = {}
    for component of Components
      if not Components[component].canBuy? or Components[component].canBuy
        results[component] = Components[component]
    results