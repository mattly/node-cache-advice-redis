assert = require('chai').assert
assert.cb = require('./cb')(assert)
fakeRedis = require('fakeredis')
cacher = require('../index')

ctx = {}
{r,c} = require('./helpers')(ctx)

beforeEach ->
  ctx.redis = fakeRedis.createClient()
  ctx.cacher = cacher({redis: ctx.redis})

describe "client setup", ->

describe "namespace", ->
  namespace = "foo"
  checkNamespace = (done) ->
    ctx.cacher.set 'key', 'bar', (e) ->
      assert.cb.equal(r('get',"#{namespace}:key"),'"bar"')(done)

  it "uses namespace provided at setup", (done) ->
    ctx.cacher = cacher({redis: ctx.redis, namespace})
    assert.equal(ctx.cacher.namespace, namespace)
    checkNamespace(done)

  it "uses namespace provided after setup", (done) ->
    ctx.cacher.namespace = namespace
    checkNamespace(done)

describe "expire", ->
  expire = 100
  checkExpire = (done) ->
    ctx.cacher.set 'key', 'bar', (e) ->
      assert.cb.equal(r('ttl','key'),100)(done)

  it "uses an expire provided at setup", (done) ->
    ctx.cacher = cacher({redis: ctx.redis, expire})
    assert.equal(ctx.cacher.expire, expire)
    checkExpire(done)

  it "uses an expire provided after setup", (done) ->
    ctx.cacher.expire = expire
    checkExpire(done)
