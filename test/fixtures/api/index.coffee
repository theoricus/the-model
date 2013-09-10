express = require "express"
todos = require "./todos"

app = null

exports.start = ->
  app = express()

  app.set "title", "TodoMVC"
  app.use express.logger("dev")
  app.use express.bodyParser()

  app.all "/*", (req, res, next) ->
    res.header "Access-Control-Allow-Origin", "*"
    res.header "Access-Control-Allow-Headers", "Cache-Control, Pragma, Origin, Authorization, Content-Type, X-Requested-With"
    res.header "Access-Control-Allow-Methods", "GET, PUT, POST, DELETE"
    next()

  app.all "/*", (req, res, next) ->
    return next()  if req.method.toLowerCase() isnt "options"
    res.send 204

  app.get "/todos", todos.all
  app.get "/todos/:id", todos.read
  app.post "/todos", todos.create
  app.put "/todos/:id", todos.update
  app.delete "/todos/:id", todos.delete

  app.listen 3000
  console.log "JSON REST Api running on port 3000"

exports.close = ->
  app.close()