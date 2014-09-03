# Description:
#   This script takes a whiteboard image cleans it up for easy reading
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot: whiteboard me <url>
#
# Notes:
#   Makes use of a whiteboard cleaning API
#
# Author:
#  John Hamelink <john@farmer.io>


module.exports = (robot) ->

  fs = require 'fs'
  child = require 'child_process'
  util = require 'util'

  baseApi ='http://api.o2b.ru'
  requestApi = baseApi + '/whiteboardcleaner/upload'

  deleteFile = (path) ->
    child.exec "rm #{path}"

  downloadFile = (url, msg) ->
    fileName = url.match(/([^\/]+$)/)[0]
    child.exec "curl #{url} > #{fileName}", (err, stdout, stderr) ->
      throw err if err
      file = { name: fileName, path: "#{fileName}" }
      uploadFile file, msg

  uploadFile = (file, msg) ->
    curl = "curl -q --form flowFilename=#{file['name']} --form file=@#{file['path']} #{requestApi}"
    child.exec curl, (err, stdout, stderr) ->
      throw err if err
      json = JSON.parse stdout
      msg.send baseApi + json['data']['url_get']
      deleteFile(file['path'])


  robot.respond /whiteboard me (.+)/i, (msg) ->
    msg.send "Scrub Scrub..."
    url = msg.match[1]
    tmp = downloadFile(url, msg)
    msg.send tmp['path']
