


# Numbers

@formatCommas = (num) ->
  parts = num.toString().split(".")
  parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ",")
  return parts.join('.')

@formatDollars = (num) -> '$' + formatCommas(num.toFixed(2))

@formatPercent = (num) -> (num * 100).toFixed(2) + '%'









formatDollars = (num) ->

  if not num? then return 'n/a'
  sign = if num then '+' else '-'
  abs = Math.abs(num)
  commas = formatCommas abs.toFixed(2)

  "#{sign}$#{commas}"



# Time

@formatMinAgo = (time) -> $.timeago(time)

# Add as Handlebars helpers

isNum = (num) -> num? and not isNaN(num)

@templateHelpers =
  toPercent: (num) -> if isNum(num) then (if num > 0 then '+' else '') + formatPercent(num) else 'n/a'
  toDollars: (num) -> formatDollars num 
  toDelta: (num) -> if isNum(num) then (if num > 0 then '+' else '') + formatCommas(num.toFixed(2)) else 'n/a'
  toMinAgo: (time) -> formatMinAgo(time)
  toRelativeTime: (time) -> time.relative()
  toLocalTime: (time) -> time.format('{DOW} {h}:{mm}:{ss}{tt}')
  toJSON: (obj) -> prettify obj


for name, helper of templateHelpers
  Handlebars.registerHelper(name,helper)
