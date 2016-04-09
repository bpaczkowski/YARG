module.exports = (optionalValue) ->
  console.log('Current Context')
  console.log('====================')
  console.log(@)
  if optionalValue?
    console.log('Value')
    console.log('====================')
    console.log(optionalValue)
  return
