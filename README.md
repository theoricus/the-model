# The Model

Model layer for [Theoricus](https://github.com/theoricus/theoricus) framework.

[![Stories in Ready](https://badge.waffle.io/theoricus/the-model.png)](http://waffle.io/theoricus/the-model)  

[![Build Status](https://travis-ci.org/theoricus/the-model.png?branch=master)](https://travis-ci.org/theoricus/the-model) [![Coverage Status](https://coveralls.io/repos/theoricus/the-model/badge.png)](https://coveralls.io/r/theoricus/the-model) [![Dependency Status](https://gemnasium.com/theoricus/the-model.png)](https://gemnasium.com/theoricus/the-model)

<!-- Uncomment this block after first public release in NPM
[![NPM version](https://badge.fury.io/js/theoricus.png)](http://badge.fury.io/js/theoricus)
-->

# Usage Drafts

Simple draft demonstrating how this should work.

> Attention, is a **WIP**! Do not use it yet.

## Main concept

 1. `Sync` calls **never** touch database, everything is local
 1. `Async` calls **always** touches database, everything is remote and local
 1. Some methods are `static` only, others are `static` and `local` (instance)

The difference is the passed callback that may exist or not.

## Model

Configuring your model.

````coffeescript
# app/models/user
class User extends AppModel
  
  # general config method
  @config
    
    # url ending points
    urls:
      create: '/users.json'
      read: '/users/:id.json'
      update: '/users/:id.json'
      delete: '/users/:id.json'
      all: '/users.json'
      find: '/users/find.json'
    
    # properties and validation methods
    keys:
      name: String
      age: (val)-> val >= 18 # validates if user is of age
    
    # default name for id property, the default is `id`
    id: 'id'

    # you may want to change that, mongodb for instance uses `_id`
    # id: '_id'
````

## Controller

Using it inside a controller (or anywhere else).

````coffeescript
#app/controllers/users

User = require 'app/models/user'

class Users extends AppController

  # CREATE (static)
  # ----------------------------------------------------------------------------

  # sync
  record = User.create name: 'foo', age: 20

  # async
  User.create name: 'foo', age:20, (err, record)->
    if err?
      console.log 'err', err
    else
      console.log 'record created locally and remotely'
      console.log 'record', record

  # READ (static)
  # ----------------------------------------------------------------------------

  # sync
  record = User.read 0

  # async
  User.read 0, (err, record)->
    if err?
      console.log 'err', err
    else
      console.log 'record read remotely'
      console.log 'record', record

  # UPDATE (static and instance)
  # ----------------------------------------------------------------------------

  # sync
  User.update 0, name: 'bar', age: 30
  record.update name: 'bar', age: 30

  # async
  User.update 0, name: 'bar', age: 30, (err, record)-> #...
  record.update name: 'bar', age: 30, (err, record)->
    if err?
      console.log 'err', err
    else
      console.log 'record updated locally and remotely'
      console.log 'record', record

  # DELETE (static / instance)
  # ----------------------------------------------------------------------------

  # sync
  User.delete 0
  record.delete()

  # async
  User.delete 0, (err, record)-> # ...
  record.delete (err, record)->
    if err?
      console.log 'err', err
    else
      console.log 'record deleted locally and remotely'
      console.log 'record', record

  # ALL (static)
  # ----------------------------------------------------------------------------

  # sync
  records = User.all()

  # async
  User.all (err, records)->
    if err?
      console.log 'err', err
    else
      console.log 'records fetched remotely and saved locally, returning all'
      console.log 'records', records

  # FIND (static)
  # ----------------------------------------------------------------------------

  # sync
  records = User.find name: 'foo'

  # async
  User.find name: 'foo', (err, records)->
    if err?
      console.log 'err', err
    else
      console.log 'records fetched remotely and saved locally, finding in both'
      console.log 'records', records
````