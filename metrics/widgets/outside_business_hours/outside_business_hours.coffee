class Dashing.Outside_business_hours extends Dashing.Widget

  @numberWithCommas = (x) ->
    x.toString().replace /\B(?=(\d{3})+(?!\d))/g, ","

  getPercentage = (current_value, previous_value) ->
    raw_percentage = Math.round((parseInt(current_value) - parseInt(previous_value)) / previous_value * 100)
    pdiff = Math.abs(raw_percentage)
    if pdiff == Number.POSITIVE_INFINITY
      "∞"
    else
      pdiff = pdiff.toLocaleString()
      "#{pdiff}%"

  @accessor 'current_amount', ->
    current = parseInt(@get('current'))

    unless isNaN(current)
      "#{current}"
    else
      "N/A"

  @accessor 'pdifference', ->
    plast = parseInt(@get('plast'))
    current = parseInt(@get('current'))

    if (plast == 0) && (current == 0)
      "0%"
    else if (isNaN(plast)) || (isNaN(current))
      "N/A"
    else
      percentage = getPercentage(current, plast)
      percentage

  @accessor 'ydifference', ->
    ylast = parseInt(@get('ylast'))
    current = parseInt(@get('current'))

    if (ylast == 0) && (current == 0)
      "0%"
    else if (isNaN(ylast)) || (isNaN(current))
      "N/A"
    else
      percentage = getPercentage(current, ylast)
      percentage

  @accessor 'pdiff', ->
    plast = parseInt(@get('plast'))
    current = parseInt(@get('current'))

    if (isNaN(plast)) || (isNaN(current))
      'no-data'
    else
      if current > plast then 'diff-up' else 'diff-down'

  @accessor 'ydiff', ->
    ylast = parseInt(@get('ylast'))
    current = parseInt(@get('current'))

    if (isNaN(ylast)) || (isNaN(current))
      'no-data'
    else
      if current > ylast then 'diff-up' else 'diff-down'

  @accessor 'parrow', ->
    plast = parseInt(@get('plast'))
    current = parseInt(@get('current'))

    unless (isNaN(plast)) || (isNaN(current))
      if current > plast then 'icon-long-arrow-up' else 'icon-long-arrow-down'

  @accessor 'yarrow', ->
    ylast = parseInt(@get('ylast'))
    current = parseInt(@get('current'))

    unless (isNaN(ylast)) || (isNaN(current))
      if current > ylast then 'icon-long-arrow-up' else 'icon-long-arrow-down'

  onData: (data) ->
    if data.status
      # clear existing "status-*" classes
      $(@get('node')).attr 'class', (i,c) ->
        c.replace /\bstatus-\S+/g, ''
      # add new class
      $(@get('node')).addClass "status-#{data.status}"
