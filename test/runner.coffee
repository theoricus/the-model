wd = require 'wd'
fsu = require 'fs-util'
path = require 'path'

env = process.argv.join(' ').match(/--env=([^\s]+)/)[1]
coverage = /--coverage/.test process.argv.join(' ')

browsers = do (require './utils/browsers')[env]
hook = require './utils/hook'
server = require './utils/server'


# compute timeout notify_sauce_labs flag based on env
if env is 'local'
  timeout = 10000
  notify_sauce_labs = false
else
  timeout = 15000
  notify_sauce_labs = true


# base url to test
base_url = "http://localhost:8080/"


# list of test files
files_base_path = (path.join __dirname, 'functional')
# files = fsu.find (path.join __dirname, 'functional'), /\.coffee$/m
files = ["general", "local", "remote", "save", "remote_error"]


# sauce connect config
sauce_conf = 
  hostname: 'localhost'
  port: '4445'
  user: process.env.SAUCE_USERNAME
  pwd: process.env.SAUCE_ACCESS_KEY


# mounting suites
# ------------------------------------------------------------------------------

before (done)->
  # starts server
  server.start coverage, ->
    console.log '\n\n'
    done()

# 1st root test suite - based on env
describe "[#{env}]", ->

  # loop through all browser configs
  for caps in browsers

    # computes session name based on the last two tags
    caps.name = (caps.tags.slice 2 ).join '_'

    # when testing local
    if env is 'local'

      # ignores platform and browser version
      caps.platform = caps.version = caps['record-video'] = null
      delete caps.platform
      delete caps.version
      delete caps['record-video']

    # 2nd root suite - based on browser
    describe "[#{caps.name}]", ->

      # INIT WD
      if env is 'local' or caps.name is 'phantomjs'
        browser = do wd.remote
      else
        console.log 'using sauce labs'
        browser = wd.remote sauce_conf

      # SET MOCHA HOOKS
      pass = hook @, browser, caps, base_url, notify_sauce_labs, coverage

      for file in files
        
        {test} = require "#{files_base_path}/#{file}"
        if test
          test browser, pass, timeout