# Description:
#   Receive notifications of uptime failures
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   None
#
# URLS:
#   /hubot/uptime

module.exports = (robot) ->

  robot.router.get "/hubot/uptime", (req, res) ->
    url = req.query.monitorURL
    name = req.query.monitorFriendlyName
    alert_type = req.query.alertType
    alert = ""
    if req.query.alertDetails
      alert = req.query.alertDetails

    alert_type = "Down" if alert_type == "1"
    alert_type = "Up"

    result_string = "ALERT: #{name} (#{url}) has been marked as #{alert_type}"
    result_string = "#{result_string} - #{alert}" if alert.length > 0
    robot.messageRoom "All", result_string
    res.end "OK"
