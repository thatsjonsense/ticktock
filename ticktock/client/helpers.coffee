


# Numbers

@formatCommas = (num) ->
  parts = num.toString().split(".")
  parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",")
  return parts.join('.')

@formatDollars = (num) -> '$' + formatCommas(num.toFixed(2))

@formatPercent = (num) -> (num * 100).toFixed(2) + '%'

# Time

@formatMinAgo = (time) -> $.timeago(time)

# Add as Handlebars helpers

@templateHelpers =
  toPercent: (num) -> if num? then formatPercent(num) else 'n/a'
  toDollars: (num) -> if num? then formatDollars(num) else 'n/a' 
  toMinAgo: (time) -> formatMinAgo(time)

for name, helper of templateHelpers
  Handlebars.registerHelper(name,helper)

