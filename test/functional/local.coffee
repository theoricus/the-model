should = do (require 'chai').should
shared = require './shared'

exports.test = ( browser, pass, timeout )->

  describe '[api] - LOCAL', ->

    it '[CREATE] should create an item', (done)->

        shared.create_todo browser, false, (saved)->
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

        shared.update_todo browser, false, (saved)->

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

      shared.delete_todo browser, false, (deleted)->

        should.equal true, deleted
        done()