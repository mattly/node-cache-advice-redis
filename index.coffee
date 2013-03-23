module.exports = (config) ->
  if not config.redis
    do ->
      if config.url
        {hostname, port, auth} = require('url').parse(config.url)
      else {hostname, port, auth} = config
      hostname or= 'localhost'
      port or= 6379
      config.redis = require('redis').createClient(port, hostname)
      if auth
        password = auth.split(':')[1]
        config.redis.auth(password)

  cache =
    redis: config.redis
    namespace: config.namespace
    expire: config.expire

  namespace = (key) ->
    if cache.namespace then "#{cache.namespace}:#{key}" else key

  cache.set = (key, data, callback) ->
    key = namespace(key)
    data = JSON.stringify(data)
    if cache.expire
      cache.redis.setex(key, cache.expire, data, callback)
    else cache.redis.set(key, data, callback)

  cache.get = (key, callback) ->
    key = namespace(key)
    cache.redis.get key, (err, result) ->
      if err then return callback(err)
      try
        callback(err, JSON.parse(result))
      catch e
        callback(e)

  cache.del = (key, callback) ->
    key = namespace(key)
    cache.redis.del(key, callback)

  cache

