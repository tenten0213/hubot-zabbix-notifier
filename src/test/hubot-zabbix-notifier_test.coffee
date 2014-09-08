'use strict'
process.env.PORT = 0 # pick a random port for this test
Hubot = require('hubot')
Path = require('path')
request = require('supertest')
sinon = require('sinon')

adapterPath = Path.join Path.dirname(require.resolve 'hubot'), "src", "adapters"
robot = Hubot.loadBot adapterPath, "shell", true, "MochaHubot"

hubot_zabbix_notifier = require('../scripts/hubot-zabbix-notifier')(robot)

test_data = [
  {
    "name": "notify",
    "expected_out": "@all message",
    "body": {
      "message": "@all message"
    }
  }
]

url = "/hubot/zabbix-notify?room=tenten"

for test in test_data then do (test) ->
  describe test.name, ()->
    before (done) ->
      robot.adapter.send = sinon.spy()
      endfunc = (err, res) ->
        throw err if err
        do done
      request(robot.router)
        .post(url)
        .send(JSON.stringify(test.body))
        .expect(200)
        .end(endfunc)
    it 'Robot sent out respond', ()->
      robot.adapter.send.called.should.be.true
    it 'Robot sent to right room', ()->
      send_arg = robot.adapter.send.getCall(0).args[0]
      send_arg.room.should.eql 'tenten'
    it 'Robot sent right message', ()->
      robot.adapter.send.getCall(0).args[1].should.eql test.expected_out

