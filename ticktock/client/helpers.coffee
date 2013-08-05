


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

isNum = (num) -> num? and not isNaN(num)

@templateHelpers =
  toPercent: (num) -> if isNum(num) then formatPercent(num) else 'n/a'
  toDollars: (num) -> if isNum(num) then formatDollars(num) else 'n/a' 
  toDelta: (num) -> if isNum(num) then (if num > 0 then '+' else '') + formatCommas(num.toFixed(2)) else 'n/a'
  toMinAgo: (time) -> formatMinAgo(time)
  toLocalTime: (time) -> time.format('{DOW} {h}:{mm}:{ss}{tt}')
  toJSON: (obj) -> prettify obj

for name, helper of templateHelpers
  Handlebars.registerHelper(name,helper)
