
mongo = require "mongodb"
BSON = mongo.BSONPure

db = null

general_handler = (res, err)->
  unless err
    res.id = res._id
    res.send res
  else
    res.send err

exports.set_db = (database)-> db = database

exports.all = (req, res)->
  db.all (data, err)->
    unless err
      for item in res
        item.id = item._id
      res.send data
    else
      res.send err

exports.read = (req, res)->
  id = req.params.id
  console.log "Retrieving todo #{id}"

  db.read id, general_handler

exports.create = (req, res)->
  todo = req.body
  db.create todo, general_handler

exports.update = (req, res)->
  id = req.params.id
  todo = req.body

  console.log "Updating todo #{id}"
  console.log (JSON.stringify todo)

  db.update id, todo, general_handler

exports.delete = (req, res)->
  id = req.params.id
  console.log "Deleting todo #{id}"

  db.delete id, general_handler
