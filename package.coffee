github = 'github.com/mattly/node-cache-advice-redis'
tags = 'cache functional aspect-oriented-programming redis'.split(' ')
info =
  name: 'cache-advice-redis'
  description: 'interface for cache-advice, using redis'
  version: '0.0.1'
  author: 'Matthew Lyon <matthew@lyonheart.us>'
  keywords: tags
  tags: tags
  homepage: "https://#{github}"
  repository: "git://#{github}.git"
  bugs: "https://#{github}/issues"

  dependencies:
    'redis': '0.8.x'

  devDependencies:
    fakeredis: '0.1.1'
    # deal with it
    'coffee-script': '1.6.x'
    # test runner / framework
    mocha: '1.8.x'
    # assertions helper
    chai: '1.4.x'

  scripts:
    # preinstall
    # postinstall
    # poststart
    prepublish: "make build"
    # pretest
    test: "make test"

  main: 'index.js'
  engines: { node: '*' }

console.log(JSON.stringify(info, null, 2))


