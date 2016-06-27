#
# Evaluate the strength of a password.
#
# - `msg` is the string to evaluate.
#
@app.factory 'evaluateStrength', ['$window', (win) ->
  (msg) ->
    pe = new PasswordEvaluator msg
    space = Math.pow pe.keyspace(), msg.length
    speed = PW_CRACKING_BOTS * PW_CRACKING_SPEED
    seconds = space / speed
    
    if seconds < 1
      I18n.t 'accounts.password.hint.very_short'
    else if seconds > 60 * 60 * 24 * 365 * 100 * 100 # 100 centuries
      I18n.t 'accounts.password.hint.very_long'
    else
      [time, unit] = pe.humanTime seconds
      pe.crackTimeText time, unit
]

# Evaluate the strength of a password.
class PasswordEvaluator
  constructor: (password) ->
    @password = password
    
  # Determines the size of the keyspace for the password.
  keyspace: ->
    n = 0
    if @password.match(/[a-z]/)
      n += 25
    if @password.match(/[A-Z]/)
      n += 25
    if @password.match(/[0-9]/)
      n += 10
    if @password.match(/[^a-zA-Z0-9]/)
      n += 20 # conservative guess for special characters
    n
    
  # Convert a number of seconds into a more human-understandable time unit.
  #
  # Return an array of size 2: time and unit.
  # For example [3, 'seconds'] or [8, 'hours']
  humanTime: (s) ->
    s = 0 unless s
    if s <= 60 # less than 60 seconds
      [s, 'seconds']
    else if s <= 60 * 60 # less than 60 minutes
      [s/60, 'minutes']
    else if s <= 60 * 60 * 24 # less than 24 hours
      [s/(60*60), 'hours']
    else if s <= 60 * 60 * 24 * 7 # less than 7 days
      [s/(60*60*24), 'days']
    else if s <= 60 * 60 * 24 * 60 # less than 60 days
      [s/(60*60*24*7), 'weeks']
    else if s <= 60 * 60 * 24 * 365 # less than 365 days
      [s/(60*60*24*30), 'months']
    else if s <= 60 * 60 * 24 * 365 * 100 # less than 100 years
      [s/(60*60*24*365), 'years']
    else
      [s/(60*60*24*365*100), 'centuries']
      
  # Displays a localized message to the user explaining the time it would
  # take to crack a string given the time and unit (as outputted by `humanTime`).
  crackTimeText: (time, unit) ->
    time = Math.round time
    unit = 'x_'+unit
    if unit == 'x_hours' || unit == 'x_years'
      unit = 'about_'+unit
    I18n.t 'accounts.password.hint.text', {
      time: I18n.t("datetime.distance_in_words.#{unit}", { count: time })
    }
    
    
# Expose the `PasswordEvaluator` class to the world.
root = exports ? window
root.PasswordEvaluator = PasswordEvaluator