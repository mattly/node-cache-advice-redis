assert = require('chai').assert
assert.cb = require('./cb')(assert)
fakeRedis = require('fakeredis')

cacher = require('../index')

ctx = {}
{r,c} = require('./helpers')(ctx)

beforeEach ->
  ctx.redis = redis = fakeRedis.createClient()
  ctx.cacher = cacher({redis})

describe "setting a key", ->
  describe "when configured with expire", ->
    beforeEach (done) ->
      ctx.cacher.expire = 100
      ctx.cacher.set('key', 'value', done)
    it("sets the key to JSON value", assert.cb.equal(r('get','key'), '"value"'))
    it("sets an expireon the key", assert.cb.equal(r('ttl','key'), 100))

  describe "when configured without an expire", ->
    beforeEach(c('set', 'key', 'value'))
    it("sets the key to the JSON value", assert.cb.equal(r('get','key'), '"value"'))
    it("does not set an expire on the key", assert.cb.equal(r('ttl','key'), -1))

describe "getting a key", ->
  describe "when the value is in the cache", ->
    beforeEach(r('set', 'key', '"value"'))
    it("provides the value", assert.cb.equal(c('get','key'), 'value'))

  describe "when the value is not in the cache", ->
    it("provides null", assert.cb.equal(c('get','key'), null))

  describe "when the value is not JSON-parseable", ->
    beforeEach(r('set', 'key', '{'))
    it("provides an error", assert.cb.error(c('get','key'), 'SyntaxError'))

  describe "when redis returns an error", ->
    beforeEach ->
      theErr = new Error()
      theErr.name = 'MyError'
      ctx.redis.get = (key, cb) -> if key is 'key' then cb(theErr) else cb()
    it "provides the error", assert.cb.error(c('get','key'), 'MyError')

describe "deleting a key", ->
  beforeEach(r('set','key','"value"'))

  describe "on success", ->
    beforeEach (done) -> ctx.cacher.del('key', done)
    it("removes the key", assert.cb.equal(r('get','key'), null))

  describe "when redis returns an error", ->
    beforeEach ->
      theErr = new Error()
      theErr.name = 'MyError'
      ctx.redis.del = (key, cb) -> if key is 'key' then cb(theErr) else cb()
    it "provides the error", assert.cb.error(c('del','key'), 'MyError')
