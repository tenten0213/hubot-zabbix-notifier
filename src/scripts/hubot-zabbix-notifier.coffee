# Notifies about Zabbix alerts
#
# Dependencies:
#   "url": ""
#   "querystring": ""
#
# Configuration:
#   Configure Zabbix Actions - Remote command.
#   echo -e "@all [{TRIGGER.SEVERITY}] {TRIGGER.NAME}:\n""{ITEM.VALUE1}" | /opt/hubot-zabbix-notifier/hubot_room_message -r 123 -o example.com
#
# Commands:
#   None
#
# URLS:
#   POST /hubot/zabbix-notify?room=<room>
#
# Author:
#   tenten0213

'use strict'

url = require('url')
querystring = require('querystring')
util = require('util')

class ZabbixNotifier
  constructor: (robot) ->
    @robot = robot

  error: (err, body) ->
    console.log "zabbix-notify error: #{err.message}. Data: #{util.inspect(body)}"
    console.log err.stack

  dataMethodJSONParse: (req,data) ->
    return false if typeof req.body != 'object'

    ret = Object.keys(req.body).filter (val) ->
      val != '__proto__'

    try
      if ret.length == 1
        return JSON.parse ret[0]
    catch err
      return false

    return false

  dataMethodRaw: (req) ->
    return false if typeof req.body != 'object'
    return req.body

  process: (req, res) ->
    query = querystring.parse(url.parse(req.url).query)

    res.end('')

    envelope = {}
    envelope.user = {}
    envelope.user.room = envelope.room = query.room if query.room

    data = null

    filterChecker = (item, callback) ->
      return if data

      ret = item(req)
      if (ret)
        data = ret
        return true

    [@dataMethodJSONParse, @dataMethodRaw].forEach(filterChecker)
    @robot.send envelope, decodeURIComponent("#{data.message}")

module.exports = (robot) ->
  robot.zabbix_notifier = new ZabbixNotifier robot

  robot.router.post "/hubot/zabbix-notify", (req, res) ->
    robot.zabbix_notifier.process req, res
