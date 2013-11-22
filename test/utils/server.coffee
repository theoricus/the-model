fs = require 'fs'
url = require 'url'
path = require 'path'
express = require 'express'
istanbul = require 'istanbul-middleware'

api = require '../fixtures/api'

root = path.join __dirname, '..', 'fixtures', 'app', 'public'
index = path.join root, 'index.html'

app = null

matcher = (req)->
    parsed = url.parse req.url
    return parsed.pathname.match /__split__\/lib\/index\.js/

exports.start = (coverage, done)->
  if coverage
    istanbul.hookLoader __dirname, verbose: true

  app = express()

  if coverage
    app.use '/coverage', istanbul.createHandler verbose: true, resetOnGet: true
    console.log "ROOOOOOT"
    console.log root
    console.log "MATHCER"
    console.log matcher
    app.use istanbul.createClientHandler root, matcher: matcher
    app.use express.static root
  else
    app.use express.static root

  app.use (req, res)->
    if ~(req.url.indexOf '.')
      res.statusCode = 404
      res.end 'File not found: ' + req.url
    else
      res.end (fs.readFileSync index, 'utf-8')

  app.use app.router
  app.listen 8080
  console.log "Todo app running on port 8080"

  api.start done

exports.close = ->
  app?.close()
  api?.close()