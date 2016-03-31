module.exports = (value) ->
  value.toFixed(2).toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',')