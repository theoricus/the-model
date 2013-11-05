Model = require "../../../../.."
Todo = require "./todo"

class TodoTypes extends Model

  @configure

    urls:
      'all':'http://localhost:3000/todos'
      'create':'http://localhost:3000/todos'
      'read':'http://localhost:3000/todos/:id'
      'update':'http://localhost:3000/todos/:id'
      'delete':'http://localhost:3000/todos/:id'

    keys:
      "title":String
      "done":Boolean
      "owners":Array
      "config":Object
      "date":Date
      "todo":Todo

    id:"_id"

window.TodoTypes = TodoTypes if window
module.exports = TodoTypes
