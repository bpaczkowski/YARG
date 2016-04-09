Template = require 'template/overview'

module.exports = class OverviewUi
  constructor: (@main) ->

  show: (@overviewContainer) ->
    @main.eventManager.on 'OverviewUpdate', @_overviewUpdate
    @main.eventManager.emit 'OverviewUpdate', true
    return

  hide: ->
    return unless @overviewContainer?
    @main.eventManager.off 'OverviewUpdate', @_overviewUpdate
    @overviewContainer.html ''
    @overviewContainer = null

  _overviewUpdate: (force) =>
    if force or @_lastUpdate and Date.now() - @_lastUpdate > 1000 / 30
      @overviewContainer.html Template { money: @main.money }
      @_lastUpdate = Date.now()
    else unless @_lastUpdate?
      @_lastUpdate = Date.now()
    return
