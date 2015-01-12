class Dashing.Cases_count extends Dashing.Widget
  @accessor 'current', Dashing.AnimatedValue

  @accessor 'current_cases', ->
    current = parseInt(@get('current'))

    unless isNaN(current)
      "#{current}"
    else
      "N/A"

  onData: (data) ->
    if data.status
      # clear existing "status-*" classes
      $(@get('node')).attr 'class', (i,c) ->
        c.replace /\bstatus-\S+/g, ''
      # add new class
      $(@get('node')).addClass "status-#{data.status}"
