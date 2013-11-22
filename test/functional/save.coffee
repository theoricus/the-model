should = do (require 'chai').should
shared = require './shared'

exports.test = ( browser, pass, timeout )->

  describe '[api] - SAVE', ->

    it '[CREATE] should create an item', (done)->

      shared.create_todo browser, false, ()=>

        shared.save_todo browser, (saved)->
          should.equal true, saved
          done()

    it '[UPDATE] should update an item', (done)->

        shared.update_todo browser, false, (saved)->

          should.equal saved, true

          shared.save_todo browser, (saved)->
            should.equal true, saved
            done()

    it '[DELETE] should delete an item', (done)->

        shared.delete_todo browser, false, (deleted)->
          should.equal true, deleted
          shared.save_todo browser, (saved)->
            should.equal true, saved
            done()