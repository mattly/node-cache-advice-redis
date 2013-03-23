assert = require('chai').assert
fakeRedis = require('fakeredis')

cacher = require('../index')

ctx = {}
beforeEach ->
  ctx.redis = redis = fakeRedis.createClient()
  ctx.cacher = cacher({redis})

setKey = (key, val) ->
  (done) -> ctx.redis.set(key, val, done)

op = (op, key, expected) ->
  [target, op] = op.split('.')
  (done) ->
    ctx[target][op] key, (err, actual) ->
      if err then return done(err)
      assert.equal(expected, actual)
      done()

err = (errName, theFn) ->
  (done) ->
    theFn (theErr) ->
      assert.instanceOf(theErr, Error)
      assert.equal(theErr.name, errName)
      done()

describe "setting a key", ->
  describe "when configured with expire", ->
    beforeEach (done) ->
      ctx.cacher.expire = 100
      ctx.cacher.set('key', 'value', done)
    it "sets the key to the JSON value", op('redis.get', 'key', '"value"')
    it "sets an expire on the key", op('redis.ttl', 'key', 100)

  describe "when configured without an expire", ->
    beforeEach (done) ->
      ctx.cacher.set('key', 'value', done)
    it "sets the key to the JSON value", op('redis.get', 'key', '"value"')
    it "does not set an expire on the key", op('redis.ttl', 'key', -1)

describe "getting a key", ->
  describe "when the value is in the cache", ->
    beforeEach(setKey('key', '"value"'))
    it "provides the value", op('cacher.get', 'key', 'value')

  describe "when the value is not in the cache", ->
    it "provides null", op('cacher.get', 'key', null)

  describe "when the value is not JSON-parseable", ->
    beforeEach(setKey('key', '{'))
    it "provides an error", err('SyntaxError', op('cacher.get', 'key'))

  describe "when redis returns an error", ->
    beforeEach ->
      theErr = new Error()
      theErr.name = 'MyError'
      ctx.redis.get = (key, cb) -> if key is 'key' then cb(theErr) else cb()
    it "provides an error", err('MyError', op('cacher.get', 'key'))

describe "deleting a key", ->
  beforeEach(setKey('key','"value"'))

  describe "on success", ->
    beforeEach (done) -> ctx.cacher.del('key', done)
    it "removes the key", op('redis.get', 'key', null)

  describe "when redis returns an error", ->
    beforeEach ->
      theErr = new Error()
      theErr.name = 'MyError'
      ctx.redis.del = (key, cb) -> if key is 'key' then cb(theErr) else cb()
    it "provides the error", err('MyError', op('cacher.del', 'key'))
