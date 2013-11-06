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
      "customer_id":Number

    id:"_id"

  fail_rest:()->

    for key,val of @constructor._config.urls
      @constructor._config.urls[key] = val.toString().replace(/todos/,"todos_error")

  succeed_rest:()->

    for key,val of @constructor._config.urls
      @constructor._config.urls[key] = val.toString().replace(/todos_error/,"todos")

window.Todo = Todo if window
module.exports = Todo
