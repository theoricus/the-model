should = do (require 'chai').should
SPECIAL_KEYS = require "wd/lib/special-keys"
coffee = require 'coffee-script'

exports.test = ( browser, pass, timeout )->

  describe '[general]', ->

    describe '[configuring]', ->
      it 'should raise async timeout limit for execute method', (done)->
        browser.setAsyncScriptTimeout 5000, (err)->
          should.not.exist err
          done()

    describe '[api]', ->

      save_todo=(cb)->

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

      get_title = (todo_title, cb)->
        browser.eval "window.Todo.read(0).get('title')", (err, title)->

          should.not.exist err
          should.equal title, todo_title
          cb?()

      create_todo = (remote=false, cb)->

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
                    

      update_todo = (remote, cb)->

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

      delete_todo = (remote=false, cb)->

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

      get_all = (remote=false,cb)->

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


      read_todo = (id, remote=false, cb)->

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

      describe 'LOCAL', ->

        it '[CREATE] should create an item', (done)->

            create_todo false, (saved)->
              should.equal true, saved
              done()

        it '[CREATE:ERROR] should throw an error if the attribute value type is wrong', (done)->

            browser.eval "window.Todo.create({'title':'wrong todo', 'done':'1'}).get('title')", (err, title)->
              should.exist err
              done()

        it '[CREATE:ERROR] should throw an error if the attribute type is wrong', (done)->

            browser.eval "window.TodoTypes.create({'title':'type todo', 'done':false, 'owners':['hems','drimba','nybras'],'config':{'editable':false},'date':new Date(),'todo':new window.Todo}).get('title')", (err, title)->
              should.not.exist err
              should.equal 'type todo', title
              done()

        it '[READ] should read an item based on the CID', (done)->

          browser.eval "window.Todo.read(0).cid", (err, cid)->

            should.not.exist err
            should.equal 0, 0

            done()

        it '[UPDATE] should update an item', (done)->

            update_todo false, (saved)->

              should.equal true, saved
              done()


        it '[FIND] should find an item by an filter object', (done)->

          browser.eval "window.Todo.find({title:'updated todo'}).length", (err, found)->

            should.not.exist err
            should.equal found, 1
            done()

        it '[FIND] should find an item by a CID', (done)->

          browser.eval "window.Todo.find(0).length", (err, found)->

            should.not.exist err
            should.equal found, 1
            done()

        it '[DELETE] should delete an item', (done)->

          delete_todo false, (deleted)->

            should.equal true, deleted
            done()


      describe 'REMOTE', ->

        record_id = null

        it '[CREATE] should create an item', (done)->

          create_todo true, (saved)->
              should.equal true, saved
              done()


        it '[READ] should read an item based on the ID', (done)->

            browser.eval "window.Todo.read(0).id", (err, id)->

              should.not.exist err

              record_id = id

              read_todo id, true, (_id)->

                should.equal record_id, _id
                done()

        it '[UPDATE] should update an item', (done)->

          update_todo true, (saved)->

              should.equal saved, true
              done()

        it '[FIND] should find an item by an ID', (done)->

          browser.eval "window.Todo.find('#{record_id}').length", (err, found)->

            should.not.exist err
            should.equal found, 1
            done()

        it '[ALL] should return all the items saved remotelly', (done)->

          get_all true, (success)->
            should.equal success, true
            done()

        it '[ALL] should create items if there isnt local', (done)->

          delete_todo false, ()->

            get_all true, (success)->
              should.equal success, true
              done()

        it '[DELETE] should delete an item', (done)->

          delete_todo true, (deleted)->

            should.equal true, deleted
            done()

      describe 'LOCAL AND REMOTE', ->

        it '[CREATE] should create an item', (done)->

            create_todo false, ()->

              save_todo (saved)->
                should.equal true, saved
                done()

        it '[UPDATE] should update an item', (done)->

            update_todo false, (saved)->

              should.equal saved, true

              save_todo (saved)->
                should.equal true, saved
                done()

        it '[DELETE] should delete an item', (done)->

            delete_todo false, (deleted)->
              should.equal true, deleted
              save_todo (saved)->
                should.equal true, saved
                done()

      describe 'REMOTE:ERROR', ->

        it "should shutdown the API", (done)->
          browser.eval "window.todo.fail_rest()", ()->
            done()

        it 'should create locally and fail to save remotelly', (done)->

            create_todo false, ()->

              save_todo (saved)->
                should.equal false, saved
                done()

        it 'should update locally and fail save remotelly', (done)->

            update_todo false, (saved)->

              should.equal true, saved

              save_todo (saved)->
                should.equal false, saved
                done()

        it 'should delete locally and fail save remotelly', (done)->

            delete_todo false, ()->

              save_todo (saved)->
                should.equal false, saved
                done()

        it 'should fail to create remotelly', (done)->

            create_todo true, (saved)->
              should.equal false, saved
              done()

        it 'should fail to update remotelly', (done)->

          create_todo false, (saved)->

            update_todo true, (saved)->
              should.equal false, saved
              done()

        it 'should fail to read remotelly', (done)->

          browser.eval "window.Todo.read(0).id", (err, id)->

            record_id = id

            read_todo id, true, (_id)->

              should.not.equal record_id, _id
              done()

        it 'should fail to delete remotelly', (done)->

            delete_todo true, (deleted)->
              should.equal false, deleted
              done()

        it 'should fail to return all the items saved remotelly', (done)->

          get_all true, (success)->
            should.equal success, false
            done()





