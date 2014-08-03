# Description:
#   Get National Rail live departure information
#
# Dependencies:
#   None
#
# Configuration:
#   HUBOT_DEFAULT_STATION - set the default from station (nearest to your home/office)
#
# Commands:
#   hubot: trains from <departure station> to <arrival station>
#   hubot: trains to <arrival station>
#
# Notes:
#   Inspired by the work of JamieMagee - this version doesn't need
#   you to remember the station codes as it uses a fuzzy search to
#   find the station you're looking for.
#
# Author:
#  John Hamelink <john@farmer.io>


module.exports = (robot) ->
  getTrainTimes = (msg, from, to) ->
    robot.http("http://ojp.nationalrail.co.uk/service/ldb/liveTrainsJson").query(
      departing: "true"
      liveTrainsFrom: from.code
      liveTrainsTo: to.code
    ).get() (err, res, body) ->
      json = JSON.parse(body)
      if json.trains.length
        msg.reply "Next trains from: #{from.name} to #{to.name}:"
        i = 0

        while i < json.trains.length
          station = json.trains[i]
          if i < 5
            response = "The #{station[1]} to #{station[2]}"
            response += " at platform #{station[4]}"  if station[4].length
            response += " is #{/[^;]*$/.exec(station[3])[0].trim().toLowerCase()}"
            msg.send response
          i++
      else
        msg.reply "Sorry, there's no trains today"

  getStation = (msg, query, callback) ->
    robot.http("http://ojp.nationalrail.co.uk/find/stationsDLRLU/" + encodeURIComponent(query)).get() (err, res, body) ->
      json = JSON.parse(body)
      if json.length
        station =
          code: json[0][0]
          name: json[0][1]

        callback station
      else
        msg.reply "Couldn't find station: " + query

  robot.hear /trains from (.+) to (.+)/i, (msg) ->
    from = msg.match[1]
    to = msg.match[2]
    from = process.env.HUBOT_DEFAULT_STATION  if from.length is 0
    getStation msg, from, (station) ->
      from = station
      getStation msg, to, (station) ->
        to = station
        getTrainTimes msg, from, to

  robot.hear /trains to (.+)/i, (msg) ->
    fromCode = process.env.HUBOT_DEFAULT_STATION
    from = null
    to = msg.match[1]
    getStation msg, fromCode, (station) ->
      from = station
      getStation msg, to, (station) ->
        to = station
        getTrainTimes msg, from, to
