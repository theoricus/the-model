should = do (require 'chai').should

coffee = require 'coffee-script'

exports.test = ( browser, pass, timeout )->

  describe '[general]', ->

    describe '[configuring]', ->
      it 'should raise async timeout limit for execute method', (done)->
        browser.setAsyncScriptTimeout 5000, (err)->
          should.not.exist err
          done()

    # describe '[js-injection]', ->

    #   it 'should execute async method on model', (done)->

    #     code = coffee.compile """
    #       # getting model
    #       Model = require '../../../lib/index'

    #       # striping params and done callback
    #       [a, b, done] = arguments

    #       # executes method, passing params and firing callback
    #       Model.blabla a, b, done
    #       Model.blabla a, b, -> done()
    #     """, bare: on

    #     browser.executeAsync code, ['AA', 'BB'], (err, res)->
    #       should.not.exist err
    #       # res.should.be.equal ???

    #       console.log '==============='
    #       console.log 'err', err
    #       console.log 'res', res
    #       console.log '==============='

    #       done()
