# Description:
#   Receive notifications of Tinfoil scans
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
#   /hubot/tinfoil/started
#   /hubot/tinfoil/finished

Util = require 'util'

module.exports = (robot) ->

  robot.router.post "/hubot/tinfoil/started", (req, res) ->

    status = req.body.scan_started_webhook.scan.status
    site = req.body.scan_started_webhook.site.name
    result_string = "Started Tinfoil scan of #{site}: #{status}"
    robot.messageRoom "146776_engineering@conf.hipchat.com", result_string
    res.end "OK"
    
  robot.router.post "/hubot/tinfoil/finished", (req, res) ->

    status = req.body.scan_finished_webhook.scan.status
    site = req.body.scan_finished_webhook.site.name
    result_string = "Finished Tinfoil scan of #{site}: #{status}"
    robot.messageRoom "146776_engineering@conf.hipchat.com", result_string
    res.end "OK"
