Components = require 'config/Components'

module.exports =
  GenAbsorption1:
    codename: 'GenAbsorption1'
    name: 'Generator Heat Absorption'
    description: 'Increases all generators heat absorption by 10% per level.'
    image: Components.Gen1.image
    basePrice: 2000
    priceIncrease: 1.15
    heatAbsorptionMult: 1.1
  CellProduction1:
    codename: 'CellProduction1'
    name: 'Cell Heat Production'
    description: 'Increases all cells heat production by 10% per level.'
    image: Components.Cell1.image
    basePrice: 2000
    priceIncrease: 1.15
    heatProductionMult: 1.1
