module.exports = (context) ->
  ret = 
    r: (op, args...) ->
      (done) ->
        context.redis[op](args..., done)

    c: (op, args...) ->
      (done) ->
        context.cacher[op](args..., done)
