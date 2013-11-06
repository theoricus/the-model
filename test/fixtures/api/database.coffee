mongo = require "mongodb"

Server = mongo.Server
MongoDatabase = mongo.Db
BSON = mongo.BSONPure

module.exports = class Database

  constructor:(@name, done)->
    @mongoUri = process.env.MONGOLAB_URI or process.env.MONGOHQ_URL or "mongodb://localhost/todos_db"

    MongoDatabase.connect @mongoUri, (err, @db)=>
      unless err
        @db.createCollection "todos", ()->
      else
        @db.collection.remove {}, ()->
          @db.createCollection "todos", ()->

      done @

  all:(callback)->
    @db.collection @name, strict:true, (err, collection)=>

      unless err
        collection.find().toArray (err, items)=>

          unless err
            callback items, null
          else
            callback null, {"error":"Couldn't retrive #{@name} collection"}

      else
        @_collection_access_error callback

  read:(id, callback)->
    @db.collection @name, (err, collection)=>

      unless err
        collection.findOne {"_id":new BSON.ObjectID(id)}, (err, item)=>
          unless err
            callback item, null
          else
            callback null, {"error":"Todo not found: #{id}"}

      else
        @_collection_access_error callback

  delete:(id, callback)->

    @db.collection @name, (err, collection)=>
      unless err
        collection.remove {"_id": new BSON.ObjectID(id)}, {safe:false}, (err, result)=>
          unless err
            callback {}, null
          else
            callback null, {"error":"Couldn't delete todo #{id}"}
      else
        @_collection_access_error callback

  update:(id, todo, callback)->

    @db.collection @name, (err, collection)=>

      unless err
        collection.update "_id": new BSON.ObjectID(id), todo, safe:false, (err, result)=>

          unless err
            callback todo, null
          else
            callback null, {"error":"Error updating todo #{id}"}
      else
        @_collection_access_error callback

  create:(todo, callback)->
    @db.collection @name, (err, collection)=>

      unless err

        collection.insert todo, safe:false, (err, result)=>

          unless err
            callback result[0], null
          else
            callback null, {"error":"Couldn't create todo"}

      else
        @_collection_access_error callback

  _collection_access_error:(callback)->
    callback null, {"error":"Couldn't connect to #{@name} collection"}
