$ = require '../../../../../bower_components/jquery/jquery'
Model = require '../../../../..'

base = require '../templates/base'
task = require '../templates/task'

dom = base()
$('body').append dom

$('#new').keypress (ev)->
  if ev.keyCode is 13
    $('#list').append task taskname: $('#new').val()
    $('#new').val ''