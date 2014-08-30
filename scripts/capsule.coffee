# Description:
#   Search Capsule CRM for contacts
#
# Configuration:
#   HUBOT_CAPSULE_SUBDOMAIN - set the capsule account name
#   HUBOT_CAPSULE_API_TOKEN - set the capsule API key
#   HUBOT_CAPSULE_DEBUG - set whether to run in debug mode
# Commands:
#   hubot: capsule search <search term>
#
# Author:
#  John Hamelink <john@farmer.io>


module.exports = (robot) ->

  # Debug flag
  isDebug = () ->
    if process.env.HUBOT_CAPSULE_DEBUG
      return true if process.env.HUBOT_CAPSULE_DEBUG == "true"
      return false if process.env.HUBOT_CAPSULE_DEBUG == "false"
    return false

  # Build the base URL for the capsule API
  apiUrl = () ->
    ret = "https://" + process.env.HUBOT_CAPSULE_API_TOKEN
    ret += ":x@" + process.env.HUBOT_CAPSULE_SUBDOMAIN
    ret += ".capsulecrm.com/api/"
    ret

  # Build the base URL for the capsule website
  webUrl = () ->
    ret = "https://" + process.env.HUBOT_CAPSULE_SUBDOMAIN
    ret += ".capsulecrm.com"
    ret

  # Build the url for a person/org
  partyUrl = (id) ->
    "#{webUrl()}/party/#{id}"

  # Build a reply for a person
  replyPerson = (person, msg) ->
    ret = "Person: "
    ret += "#{person['title']} " if person['title']
    ret += "#{person['firstName']} " if person['firstName']
    ret += "#{person['lastName']} " if person['lastName']
    ret += "- " if person['jobTitle'] || person['organisationName']
    ret += "#{person['jobTitle']} " if person['jobTitle']
    ret += "at #{person['organisationName']} " if person['organisationName']
    ret += "- #{partyUrl person['id']}"
    msg.reply ret

  # Build a reply for an org
  replyOrg = (org, msg) ->
    ret = "Organisation: "
    ret += "#{org['name']} " if org['name']
    ret += "- #{partyUrl org['id']}"
    msg.reply ret

  # Handle the search query
  handleSearch = (parties, msg, search_term) ->
    if parties["@size"] == "0"
      msg.reply "No search results for #{search_term}"
    for key, value of parties
      if key == "person"
        if Array.isArray value
          for person in value
            replyPerson person, msg
        else
          replyPerson value, msg
      if key == "organisation"
        if Array.isArray value
          for org in value
            replyOrg org, msg
        else
          replyOrg value, msg


  robot.hear /capsule search (.+)/i, (msg) ->
    search_term = msg.match[1]
    msg.reply "Searching for contacts matching '#{search_term}'..."
    robot.http("#{apiUrl()}party?q=#{search_term}").header('accept', 'application/json').get() (err, res, body) ->
      msg.reply "Error: #{err}" if err
      json = JSON.parse body
      msg.reply body if isDebug()
      handleSearch json["parties"], msg, search_term
