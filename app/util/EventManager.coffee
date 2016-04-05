module.exports = class EventManager
  constructor: ->
    @channels = {}

  on: (name, callback) ->
    @channels[name] = [] unless @channels[name]?
    @channels[name].push context: @, callback: callback
    return

  off: (name, callback) ->
    for sub, i in @channels[name]
      @channels[name].splice(i, 1) if sub.callback is callback

  emit: (name, data...) ->
    unless @channels[name]?
      console.error('Non-existent event was emitted: ' + name)
      return
    for sub in @channels[name]
      #console.info("Event: #{name}")#, Stack:")
      #console.info(new Error().stack)
      sub.callback.apply(sub.context, data)
