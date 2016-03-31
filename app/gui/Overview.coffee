Template = require 'template/overview'

module.exports = class OverviewUi
  constructor: (@main) ->
    @template = Template

  show: (@overviewContainer) ->
    @main.eventManager.on 'OverviewUpdate', @_overviewUpdate
    @main.eventManager.emit 'OverviewUpdate'
    return

  hide: ->
    return unless @overviewContainer?
    @main.eventManager.off 'OverviewUpdate', @_overviewUpdate
    @overviewContainer.html ''
    @overviewContainer = null

  _overviewUpdate: (force) =>
    if force or @_lastUpdate and Date.now() - @_lastUpdate > 1000 / 60
      @overviewContainer.html @template { money: @main.grid.money }
      @_lastUpdate = Date.now()
    else unless @_lastUpdate?
      @_lastUpdate = Date.now()
    return