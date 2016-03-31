module.exports =
  placeholder:
    canBuy: false
    image: 'img/components/placeholder.png'
  none:
    canBuy: false
    codename: 'None'
    name: 'None'
    type: 'None'
    image: 'img/components/empty_tile.png'
    heatCanTransfer: false
  HeatPipe:
    canBuy: false
    codename: 'HeatPipe'
    name: 'Heat pipe'
    type: 'HeatPipe'
    image: 'img/components/placeholder.png'
    heatCanTransfer: true
    price: 50
  Cell1:
    codename: 'Cell1'
    name: 'Plutonium Cell MK I'
    type: 'Cell'
    image: 'img/components/cell.png'
    heatCanTransfer: true
    heatProduction: 20
    maxHeat: 100
    price: 500
    lifetime: 100
  Gen1:
    codename: 'Gen1'
    name: 'Steam generator MK I'
    type: 'Gen'
    image: 'img/components/steam-turbine.png'
    heatCanTransfer: true
    heatAbsorption: 5
    maxHeat: 50
    heatAbsorbedToMoneyMultiplier: .1
    price: 250
  Gen2:
    codename: 'Gen2'
    name: 'Steam generator MK II'
    type: 'Gen'
    image: 'img/components/steam-turbine.png'
    heatCanTransfer: true
    heatAbsorption: 20
    maxHeat: 150
    heatAbsorbedToMoneyMultiplier: .4
    price: 2000