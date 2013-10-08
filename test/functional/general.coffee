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

      it 'should create a local item', (done)->

        browser.get "http://localhost:8080/", ()->

          todo_title = "new todo"

          browser.elementById 'new-todo', (err, el) ->

            browser.type el, todo_title, (err)->

              browser.type el, SPECIAL_KEYS['Enter'], (err)->

                browser.elementByCssSelector "#id label", (err, el)->

                  browser.eval "window.Todo.read(0).get('title')", (err, title)->

                    should.not.exist err
                    should.equal title, todo_title

                    done()
