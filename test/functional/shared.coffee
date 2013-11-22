should = do (require 'chai').should

exports.save_todo = (browser,cb)->

  code = """
        var done = arguments[0];

        window.todo.save(function(data, err)
        {
          if( err )
            done(false)
          else
            done(true)
        })
      """

  browser.executeAsync code, (err, saved)->

        should.not.exist err

        cb?(saved)


exports.get_title = (browser, todo_title, cb)->
  browser.eval "window.Todo.read(0).get('title')", (err, title)->

    should.not.exist err
    should.equal title, todo_title
    cb?()


exports.create_todo = (browser, remote=false, cb)->

  code = """
        var finished = arguments[1];
        var callback = arguments[0];

        if(callback == "false")
        {
          window.todo = window.Todo.create({"title":"new todo", "done":false, "customer_id":0});
          finished(true)
        }
        else
        {
          window.todo = window.Todo.create({"title":"new todo", "done":false, "customer_id":0},function(record, error)
          {
            if( error )
              finished(false)
            else
              finished(true)
          })
        }

      """

  browser.executeAsync code, [remote.toString()], (err, saved)->
    should.not.exist err
    cb saved


exports.update_todo = (browser, remote, cb)->

  updated_title = "updated todo"

  code = """
        var finished = arguments[1];
        var callback = arguments[0];

        if(callback == "false")
        {
          window.todo.update({"title":"updated todo"});
          finished(window.todo.get('title') === "updated todo")
        }
        else
        {
          window.todo.update({"title":"updated todo"},function(record, error)
          {
            if( error )
              finished(false)
            else
              finished(window.todo.get('title') === "updated todo")
          })
        }

      """

  browser.executeAsync code, [remote.toString()], (err, saved)->
    should.not.exist err
    cb saved

exports.delete_todo = (browser, remote=false, cb)->

  code = """
        var finished = arguments[1];
        var callback = arguments[0];

        if(callback == "false")
        {
          window.todo.delete();
          finished(window.Todo.all().length === 0)
        }
        else
        {
          window.todo.delete(function(record, error)
          {
            if(error)
              finished(false)
            else
              finished(window.Todo.all().length === 0)
          })
        }

      """

  browser.executeAsync code, [remote.toString()], (err, deleted)->
    should.not.exist err
    cb deleted


exports.get_all = (browser, remote=false,cb)->

  code = """
        var finished = arguments[1];
        var callback = arguments[0];

        if(callback == "false")
        {
          finished(window.Todo.all().length > 0)
        }
        else
        {
          window.Todo.all(function(records, error)
          {
            if(error)
              finished(false)
            else
              finished(window.Todo.all().length > 0)
          })
        }

      """

  browser.executeAsync code, [remote.toString()], (err, success)->
    should.not.exist err
    cb success

exports.read_todo = (browser, id, remote=false, cb)->

  code = """
          var done = arguments[2];
          var id = arguments[0].toString();
          var callback = arguments[1];

          if(callback == "false")
          {
            var record = window.Todo.read(id);
            done(record.id)
          }
          else
          {
            window.Todo.read(id, function(record, err)
            {
              if(err)
                done(false)
              else
                done(record.id)
            }) 
          }

        """

  browser.executeAsync code, [id.toString(), remote.toString()], (err, _id)->

    should.not.exist err

    cb(_id)

