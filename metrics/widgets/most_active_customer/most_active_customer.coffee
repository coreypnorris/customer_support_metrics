class Dashing.Most_active_customer extends Dashing.Widget

  @accessor 'first_value', ->
    name = @get('name')
    count = @get('count')

    if !name || name.length == 1
      "N/A"
    else
      "#{name} (#{count})"


  @accessor 'second_value', ->
    email = @get('email')

    if email.length >= 29
      trimmedEmail = email.substring(0, 27);
      dots = "..."
      email = trimmedEmail.concat(dots)

    if email != ""
      "#{email}"

  @accessor 'no_data', ->
    email = @get('email')
    count = @get('count')

    if (!email || email.length == 1) && (!count || count.length == 1)
      "no_data"
