should = do (require 'chai').should
shared = require './shared'

exports.test = ( browser, pass, timeout )->
  
  describe '[api] - REMOTE', ->

    record_id = null

    it '[CREATE] should create an item', (done)->

      shared.create_todo browser, true, (saved)->
          should.equal true, saved
          done()


    it '[READ] should read an item based on the ID', (done)->

        browser.eval "window.Todo.read(0).id", (err, id)->

          should.not.exist err

          record_id = id

          shared.read_todo browser, id, true, (_id)->

            should.equal record_id, _id
            done()

    it '[UPDATE] should update an item', (done)->

      shared.update_todo browser, true, (saved)->

          should.equal saved, true
          done()

    it '[FIND] should find an item by an ID', (done)->

      browser.eval "window.Todo.find('#{record_id}').length", (err, found)->

        should.not.exist err
        should.equal found, 1
        done()

    it '[ALL] should return all the items saved remotelly', (done)->

      shared.get_all browser, true, (success)->
        should.equal success, true
        done()

    it '[ALL] should create items if there isnt local', (done)->

      shared.delete_todo browser, false, ()->

        shared.get_all browser, true, (success)->
          should.equal success, true
          done()

    it '[DELETE] should delete an item', (done)->

      shared.delete_todo browser, true, (deleted)->

        should.equal true, deleted
        done()