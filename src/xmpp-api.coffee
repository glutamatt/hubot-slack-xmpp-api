xmpp = require 'hubot-xmpp'
slack = require 'hubot-slack'
https = require 'https'

exports.use = (robot) ->
  
  adapter = xmpp.use robot
  Slack = slack.use robot
  
  adapter.send = (envelope, strings...) ->
    [channel] = envelope.room.split '@'

    strings.forEach (str) =>
      str = @escapeHtml str
      args =
        username   : @robot.name
        channel    : "\##{channel}"
        text       : str
        token      : process.env.HUBOT_SLACK_API_TOKEN

      https.get "https://slack.com/api/chat.postMessage?#{@serialize args}"
  
  adapter.escapeHtml = (string) ->
    Slack.escapeHtml string

  adapter.unescapeHtml = (string) ->
    Slack.unescapeHtml string
  
  adapter.serialize = (obj, prefix) ->
    str = []
    for p, v of obj
      k = if prefix then prefix + "[" + p + "]" else p
      if typeof v == "object"
        str.push(serialize(v, k))
      else
        str.push(encodeURIComponent(k) + "=" + encodeURIComponent(v))
    str.join("&")

  return adapter
