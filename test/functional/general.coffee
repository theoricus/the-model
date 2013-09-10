should = do (require 'chai').should

exports.test = ( browser, pass, timeout )->

  describe '[general]', ->

    describe '[input]', ->
      it 'wait until main input is visible', (done)->
        browser.waitForElementById 'new', timeout, (err)->
          should.not.exist err
          pass done

    describe '[list]', ->
      it 'should be empty on startup', (done)->
        browser.eval '$("#list").children().length', (err, children_len)->
          should.not.exist err
          children_len.should.equal 0
          pass done