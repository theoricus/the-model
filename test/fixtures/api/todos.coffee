
mongo = require "mongodb"
BSON = mongo.BSONPure

db = null

general_handler = (res, data)->
    res.send data

exports.set_db = (database)-> db = database

exports.all = (req, res)->
  db.all (data, err)->
    unless err
      for item in res
        item.id = item._id
      res.send data
    else
      res.status 500
      res.render('500', { error: err });

exports.read = (req, res)->
  id = req.params.id
  console.log "Retrieving todo #{id}"

  db.read id, (data, err)=>
    unless err
      general_handler res, data
    else
      general_handler res, err

exports.create = (req, res)->
  todo = req.body

  for key, value of todo
    todo[key] = true if todo[key] is "true"
    todo[key] = false if todo[key] is "false"
    todo[key] = 0 if todo[key] is "0"

  db.create todo, (data, err)=>
    unless err
      general_handler res, data
    else
      general_handler res, err

exports.update = (req, res)->
  id = req.params.id
  todo = req.body

  console.log "Updating todo #{id}"
  console.log (JSON.stringify todo)

  db.update id,todo, (data, err)=>
    unless err
      general_handler res, data
    else
      general_handler res, err

exports.delete = (req, res)->
  id = req.params.id
  console.log "Deleting todo #{id}"

  db.delete id, (data, err)=>
    unless err
      general_handler res, data
    else
      general_handler res, err
