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

      describe 'LOCAL', ->

        it '[CREATE] should create an item', (done)->

            todo_title = "new todo"

            browser.elementById 'new-todo', (err, el) ->

              browser.type el, todo_title, (err)->

                browser.type el, SPECIAL_KEYS['Enter'], (err)->

                  browser.eval "window.Todo.read(0).get('title')", (err, title)->

                    should.not.exist err
                    should.equal title, todo_title

                    done()

        it '[READ] should read an item based on the CID', (done)->

          browser.eval "window.Todo.read(0).cid", (err, cid)->

            should.not.exist err
            should.equal 0, 0

            done()

        it '[UPDATE] should update an item', (done)->

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

                        done()

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




