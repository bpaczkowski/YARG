module.exports = (v1, operator, v2, options) ->
  switch operator
    when '==', '==='
      return if v1 is v2 then options.fn this else options.inverse this
    when '!=', '!=='
      return if v1 isnt v2 then options.fn this else options.inverse this
    when '<'
      return if v1 < v2 then options.fn this else options.inverse this
    when '<='
      return if v1 <= v2 then options.fn this else options.inverse this
    when '>'
      return if v1 > v2 then options.fn this else options.inverse this
    when '>='
      return if v1 >= v2 then options.fn this else options.inverse this
    when '&&'
      return if v1 && v2 then options.fn this else options.inverse this
    when '||'
      return if v1 || v2 then options.fn this else options.inverse this
    else
      return options.inverse this