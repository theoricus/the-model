# The Model

Model layer for [Theoricus](https://github.com/theoricus/theoricus) framework.

# Usage Draft

Simple draft demonstrating of how use this.

## Model

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
      'age'  : (val)-> return val >= 18 # validates if user is of age
````

## Controller

````coffeescript
#app/controllers/users

User = require 'app/models/user'

class Users extends AppController

  # CREATE
  # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  # sync
  record = User.create name: 'anderson', age: 29

  # async
  User.create name: 'anderson', age:29, (record, status, res)->
    console.log '-----------------------------------'
    console.log 'record created locally and remotely'
    console.log 'record', record
    console.log 'res', res
    console.log 'error', error

  # READ
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

  # UPDATE
  # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  # sync
  record.update name: 'arboleya', age: 30

  # async
  record.update name: 'arboleya', age: 30, (record, res, error)->
    console.log '-----------------------------------'
    console.log 'record updated locally and remotely'
    console.log 'record', record
    console.log 'res', res
    console.log 'error', error

  # DELETE
  # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  # sync
  record.delete()

  # async
  record.delete (res, error)->
    console.log '-----------------------------------'
    console.log 'record deleted locally and remotely'
    console.log 'res', res
    console.log 'error', error

  # ALL
  # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  # sync
  records = do User.all

  # async
  User.all (records, res, error)->
    console.log '-----------------------------------'
    console.log 'records fetched remotely and saved locally, returning all'
    console.log 'records', records
    console.log 'res', res
    console.log 'error', error

  # FIND
  # ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  # sync
  records = do User.find name: 'anderson'

  # async
  User.find (records, res, error)->
    console.log '-----------------------------------'
    console.log 'records fetched remotely and saved locally, finding in both'
    console.log 'records', records
    console.log 'res', res
    console.log 'error', error
````