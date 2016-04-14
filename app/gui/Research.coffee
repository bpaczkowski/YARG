Template = require 'template/research'
$ = require 'jquery'
Research = require 'config/Research'
FormatMoney = require 'helpers/formatMoney'

module.exports = class ResearchUi
  constructor: (@main) ->
    @buttonTimeouts = {}

  start: ->
    $('#showResearchButton').click @show

  show: =>
    $('#app').append Template @_getResearch()
    @container = $ '#researchArea'
    @main.eventManager.on 'OverviewUpdate', @_moneyUpdate
    $('#closeResearchButton').click @hide
    @container.find('.buyResearchButton').click (event) =>
      target = $ event.target
      codename = target.attr 'data-research-codename'
      return unless codename?
      if @main.canBuyResearch(codename)
        @main.buyResearchLevel codename, 1
        researchItem = $ "##{codename}"
        researchItem.find('.researchLevel').text @main.getResearchLevel codename
        researchItem.find('.researchPrice').text FormatMoney @main.getResearchPrice codename
      else
        target.text 'Not enough money!'
        if not @buttonTimeouts[codename]?
          @buttonTimeouts[codename] = setTimeout(@_restoreBuyText.bind(null, target, codename), 2000)
      return
    return

  hide: =>
    @main.eventManager.off 'OverviewUpdate', @_moneyUpdate
    @container.parent().remove()

  _moneyUpdate: (force) =>
    if force or @_lastUpdate and Date.now() - @_lastUpdate > 1000 / 30
      $('#researchMoney').text FormatMoney @main.money
      @_lastUpdate = Date.now()
    else unless @_lastUpdate?
      @_lastUpdate = Date.now()
    return

  _restoreBuyText: (button, codename) =>
    button.text 'Buy'
    @buttonTimeouts[codename] = null
    return

  _getResearch: ->
    results =
      money: @main.money
      research: []
    for codename, research of Research
      results.research.push
        codename: codename
        name: research.name
        level: @main.getResearchLevel codename
        price: @main.getResearchPrice codename
        description: research.description
        image: research.image
    results
