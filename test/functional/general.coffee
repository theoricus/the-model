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

      get_title = (todo_title, cb)->
        browser.eval "window.Todo.read(0).get('title')", (err, title)->

          should.not.exist err
          should.equal title, todo_title
          cb?()

      create_todo = (cb, remote)->
        todo_title = "new todo"

        browser.elementById 'new-todo', (err, el) ->

          el.clear ()->
            browser.type el, todo_title, (err)->

              browser.type el, SPECIAL_KEYS['Enter'], (err)->

                if remote
                  browser.waitForCondition "window.Todo.all().length > 0", (err, boolean)->
                    should.not.exist err
                    get_title todo_title, cb
                else
                  get_title todo_title, cb
                    

      update_todo = (id, cb)->

        updated_title = "updated todo"

        browser.elementById id, (err, el) ->

          el.doubleClick (err)->

            browser.elementsByCssSelector "##{id} .edit", (err, elements)->

              should.not.exist err

              el = elements[0]

              browser.clear el, (err)->

                should.not.exist err

                browser.type el, updated_title, (err)->

                  should.not.exist err

                  browser.type el, SPECIAL_KEYS['Enter'], (err)->

                    should.not.exist err

                    browser.eval "window.Todo.all().length", (err, length)->

                      should.not.exist err
                      should.equal 1, length

                      browser.eval "window.Todo.read(0).get('title')", (err, title)->

                        should.not.exist err
                        should.equal title, updated_title

                        cb?()

      delete_todo = (id, cb)->

        browser.elementsByCssSelector "##{id} .destroy", (err, elements)->

            el = elements[0]

            el.click (err)->

              browser.eval "window.Todo.all().length", (err, size)->

                should.not.exist err
                cb?()

      describe 'LOCAL', ->

        it '[CREATE] should create an item', (done)->

            create_todo ()->
              done()

        it '[READ] should read an item based on the CID', (done)->

          browser.eval "window.Todo.read(0).cid", (err, cid)->

            should.not.exist err
            should.equal 0, 0

            done()

        it '[UPDATE] should update an item', (done)->

            update_todo "todo_0", done

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

          delete_todo "todo_0", done

      describe 'REMOTE', ->

        record_id = null

        it '[CREATE] should create an item', (done)->

          browser.eval "window.remote = true", ()->

          create_todo ()->

            browser.waitForCondition "window.Todo.all().length > 0", (err, boolean)->

              should.not.exist err
              console.log boolean
              should.equal true, boolean
              done()


        it '[READ] should read an item based on the ID', (done)->

          browser.eval "window.remote = true", ()->

            browser.eval "window.Todo.read(0).id", (err, id)->

              should.not.exist err

              record_id = id

              code = """
                var done = arguments[1];
                var id = arguments[0].toString();

                window.Todo.read(id, function(record, err)
                {
                  done(record.id)
                })
              """

              browser.executeAsync code, [record_id.toString()], (err, _id)->

                should.not.exist err
                should.equal record_id, _id

                done()

        it '[UPDATE] should update an item', (done)->

          update_todo "todo_0", done

        it '[FIND] should find an item by an ID', (done)->

          browser.eval "window.Todo.find('#{record_id}').length", (err, found)->

            should.not.exist err
            should.equal found, 1
            done()

        it '[DELETE] should delete an item', (done)->

          delete_todo "todo_0", done

      describe 'LOCAL AND REMOTE', ->

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
                should.equal true, saved

                cb?()

        it '[CREATE] should create an item', (done)->

          browser.eval "window.remote = false", ()->

            create_todo ()->

              save_todo done

        it '[UPDATE] should update an item', (done)->

          browser.eval "window.remote = false", ()->

            update_todo "todo_0", ()->

              save_todo done

        it '[DELETE] should delete an item', (done)->

          browser.eval "window.remote = false", ()->

            delete_todo "todo_0", ()->

              save_todo done





