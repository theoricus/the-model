Model = require "../../../../.."

class Todo extends Model

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

    id:"_id"

window.Todo = Todo if window
module.exports = Todo
