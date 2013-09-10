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

The difference is passed callback that may exist or not.

## Model

Configuring your model.

````coffeescript
# app/models/user
class User extends AppModel

  @config
    urls:
      'create' : '/users.json'
      'read'   : '/users/:id.json'
      'update' : '/users/:id.json'
      'delete' : '/users/:id.json'
      'all'    : '/users.json'
      'find'   : '/users/find.json'
    keys:
      'name' : String
      'age'  : (val)-> val >= 18 # validates if user is of age
````

## Controller

Using it inside a controller (or anywhere else).

````coffeescript
#app/controllers/users

User = require 'app/models/user'

class Users extends AppController

  # CREATE (static)
  # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  # sync
  record = User.create name: 'foo', age: 20

  # async
  User.create name: 'foo', age:20, (record, status, res)->
    console.log '-----------------------------------'
    console.log 'record created locally and remotely'
    console.log 'record', record
    console.log 'res', res
    console.log 'error', error

  # READ (static)
  # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  # sync
  record = User.read 0

  # async
  User.read 0, (record, res, error)->
    console.log '-----------------------------------'
    console.log 'record read remotely'
    console.log 'record', record
    console.log 'res', res
    console.log 'error', error

  # UPDATE (instance)
  # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  # sync
  record.update name: 'bar', age: 30

  # async
  record.update name: 'bar', age: 30, (record, res, error)->
    console.log '-----------------------------------'
    console.log 'record updated locally and remotely'
    console.log 'record', record
    console.log 'res', res
    console.log 'error', error

  # DELETE (instance)
  # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  # sync
  record.delete()

  # async
  record.delete (res, error)->
    console.log '-----------------------------------'
    console.log 'record deleted locally and remotely'
    console.log 'res', res
    console.log 'error', error

  # ALL (static)
  # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  # sync
  records = User.all()

  # async
  User.all (records, res, error)->
    console.log '-----------------------------------'
    console.log 'records fetched remotely and saved locally, returning all'
    console.log 'records', records
    console.log 'res', res
    console.log 'error', error

  # FIND (static)
  # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  # sync
  records = User.find name: 'foo'

  # async
  User.find (records, res, error)->
    console.log '-----------------------------------'
    console.log 'records fetched remotely and saved locally, finding in both'
    console.log 'records', records
    console.log 'res', res
    console.log 'error', error
````