Template = require 'template/research'
$ = require 'jquery'
Research = require 'config/Research'

module.exports = class ResearchUi
  constructor: (@main) ->

  start: ->
    $('#showResearchButton').click @show

  show: =>
    $('#app').append Template()
    @container = $ '#researchArea'
    $('#closeResearchButton').click @hide

  hide: =>
    @container.parent().remove()
