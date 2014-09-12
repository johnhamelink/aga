# Description:
#   Send / Receive social info
#
# Dependencies:
#   None
#
# Configuration:
#   HUBOT_FEED_SERVER - The server to get the stats from
#
# Commands:
#   None
#
# URLS:
#   /hubot/social/sync

module.exports = (robot) ->

  process.env.HUBOT_FEED_SERVER = "http://feed-buffer.herokuapp.com"

  robot.router.post "/hubot/social/sync", (req, res) ->
    arg = req.body
    res.end "OK"
    robot.messageRoom '146776_marketing@conf.hipchat.com', "Social article sync completed: #{arg.downloaded} entries downloaded, #{arg.queued} entries queued, #{arg.pruned} entries pruned."

  robot.respond /show social stats$/i, (msg) ->
    robot.http("#{process.env.HUBOT_FEED_SERVER}/stats").get() (err, res, body) ->
      profiles = JSON.parse(body)
      for profile in profiles
        if profile['name'] == 'Facebook Page'
          msg.send "\n
  #{profile['name']}: \n
  - Likes: #{profile['likes']} \n
  - Impressions: #{profile['impressions']} \n
  - Negative Feedback: #{profile['negative_feedback']} \n
  - Queued Posts: #{profile['queued_posts']} \n
  - Sent Today: #{profile['sent_today']}"
        if profile['name'] == 'Twitter'
          msg.send "\n
  #{profile['name']}: \n
  - Followers: #{profile['followers']} \n
  - Queued Posts: #{profile['queued_posts']} \n
  - Sent Today: #{profile['sent_today']}"
        if profile['name'] == 'LinkedIn Company Page'
          msg.send "\n
  #{profile['name']}: \n
  - Connections: #{profile['connections']} \n
  - Queued Posts: #{profile['queued_posts']} \n
  - Sent Today: #{profile['sent_today']}"
        if profile['name'] == 'Google+ Page'
          msg.send "\n
  #{profile['name']}: \n
  - +1s: #{profile['plusOnes']} \n
  - Queued Posts: #{profile['queued_posts']} \n
  - Sent Today: #{profile['sent_today']}"
        msg.send "\n"
