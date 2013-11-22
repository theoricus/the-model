should = do (require 'chai').should
shared = require './shared'

exports.test = ( browser, pass, timeout )->

  describe 'REMOTE:ERROR', ->

    it "should shutdown the API", (done)->
      browser.eval "window.todo.fail_rest()", ()->
        done()

    it 'should create locally and fail to save remotelly', (done)->

        shared.create_todo browser, false, ()->

          shared.save_todo browser, (saved)->
            should.equal false, saved
            done()

    it 'should update locally and fail save remotelly', (done)->

        shared.update_todo browser, false, (saved)->

          should.equal true, saved

          shared.save_todo browser, (saved)->
            should.equal false, saved
            done()

    it 'should delete locally and fail save remotelly', (done)->

        shared.delete_todo browser, false, ()->

          shared.save_todo browser, (saved)->
            should.equal false, saved
            done()

    it 'should fail to create remotelly', (done)->

        shared.create_todo browser, true, (saved)->
          should.equal false, saved
          done()

    it 'should fail to update remotelly', (done)->

      shared.create_todo browser, false, (saved)->

        shared.update_todo browser, true, (saved)->
          should.equal false, saved
          done()

    it 'should fail to read remotelly', (done)->

      browser.eval "window.Todo.read(0).id", (err, id)->

        record_id = id

        shared.read_todo browser, id, true, (_id)->

          should.not.equal record_id, _id
          done()

    it 'should fail to delete remotelly', (done)->

        shared.delete_todo browser, true, (deleted)->
          should.equal false, deleted
          done()

    it 'should fail to return all the items saved remotelly', (done)->

      shared.get_all browser, true, (success)->
        should.equal success, false
        done()