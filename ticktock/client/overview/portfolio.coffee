priceMovers = (canvas, stocks) ->
  root = d3.select(canvas)
  data = stocks.slice(0)

  tiles = root.selectAll('.tile').data(data, (s) -> s._id)
  tiles.enter()
    .append('div')
    .attr('class','tile')
    .html((s) -> Template.portfolio_tiles_stock s)
  tiles.exit()
    .remove()

  tiles.order()

  tiles.select('.symbol')
    .text((s) -> s.symbol)

  tiles.select('.gain')
    .text((s) -> templateHelpers.toPercent s.gainRelative)
    .classed('up', (s) -> s.up)
    .classed('down', (s) -> not s.up)

  tiles.on 'mouseenter', (d) ->
    line = $("[data-symbol=#{d.symbol}]")
    line.attr('data-active',true)

  tiles.on 'mouseleave', (d) ->
    line = $("[data-symbol=#{d.symbol}]")
    line.attr('data-active',false)

Template.portfolio_tiles.rendered = ->
  div_tiles = @find '.tiles'

  Deps.autorun ->
    stocks = _.sortBy currentStocks(), (s) -> -s.gainRelative
    priceMovers div_tiles, stocks
