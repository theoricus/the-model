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

        it '[CREATE] should create a local item', (done)->

            todo_title = "new todo"

            browser.elementById 'new-todo', (err, el) ->

              browser.type el, todo_title, (err)->

                browser.type el, SPECIAL_KEYS['Enter'], (err)->

                  browser.eval "window.Todo.read(0).get('title')", (err, title)->

                    should.not.exist err
                    should.equal title, todo_title

                    done()      



        it '[UPDATE] should update a local item', (done)->

          updated_title = "updated todo"

          browser.eval "window.Todo.read(0).cid", (err, id)->

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

                          done()




