module.exports = (assert) ->
  mod =
    equal: (fn, expected) ->
      (done) ->
        fn (err, actual) ->
          if err then done(err)
          assert.equal(actual, expected)
          done()
    error: (fn, name) ->
      (done) ->
        fn (err) ->
          assert.instanceOf(err, Error)
          assert.equal(err.name, name)
          done()
  mod

