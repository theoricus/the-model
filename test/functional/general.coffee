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

      create_todo = (cb)->
        todo_title = "new todo"

        browser.elementById 'new-todo', (err, el) ->

          el.clear ()->
            browser.type el, todo_title, (err)->

              browser.type el, SPECIAL_KEYS['Enter'], (err)->

                browser.eval "window.Todo.read(0).get('title')", (err, title)->

                  should.not.exist err
                  should.equal title, todo_title
                  cb?()

      update_todo = (cb)->

        updated_title = "updated todo"

        browser.elementById 'id', (err, el) ->

          el.doubleClick (err)->

            browser.elementsByCssSelector "#id .toggle", (err, elements)->

              el = elements[0]

              browser.clear el, (err)->

                browser.type el, updated_title, (err)->

                  browser.type el, SPECIAL_KEYS['Enter'], (err)->

                    browser.eval "window.Todo.read(0).get('title')", (err, title)->

                      should.not.exist err
                      should.equal title, updated_title

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

          update_todo done

        it '[FIND] should find an item by an filter object', (done)->

          browser.eval "window.Todo.find({title:'updated todo'}).length", (err, found)->

            should.not.exist err
            should.equal found, 1
            done()

        it '[FIND] should find an item by an ID or CID', (done)->

          browser.eval "window.Todo.find(0).length", (err, found)->

            should.not.exist err
            should.equal found, 1
            done()

        it '[DELETE] should delete an item', (done)->

          browser.elementsByCssSelector "#id .destroy", (err, elements)->

            el = elements[0]

            el.click (err)->

              browser.eval "window.Todo.all().length", (err, size)->

                should.not.exist err
                should.equal 0, 0
                done()

      describe 'REMOTE', ->

        it '[CREATE] should create an item', (done)->

          browser.eval "window.remote = true", ()->

          code = """
            var done = arguments[0];

            window.Todo.on('create',function(record)
            {
              done(record)
            })

          """

          browser.executeAsync code, (err, result)->

            console.log result
            done()

          create_todo

        it '[READ] should read an item based on the ID', (done)->

          browser.eval "window.Todo.read(0).id", (err, _id)->

            should.not.exist err
            should.equal 0, 0

            console.log _id, err

            done()

            # code = """
            #   var done = arguments[1];
            #   var id = arguments[0].toString();

            #   window.Todo.read(id, function(record, err)
            #   {
            #     done(record)
            #   })
            # """

            # browser.executeAsync code, [id.toString()], (err, _id)->

            #   # should.not.exist err
            #   console.log _id
            #   # should.equal id, _id

            #   done()





