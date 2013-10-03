$ = require "../../../../../bower_components/jquery/jquery.js"
Template = require "../templates/app.jade"
Todo = require "./todo"

class App

  constructor:()->

    # @render()
    # @el = $(".todoapp")

    # @setup()

  setup:()->

    @all_checkbox = @el.find("#toggle-all")[0];
    @input = @el.find("#new-todo")
    @footer = @el.find("#footer")
    @main = @el.find("#main")
    @list = @el.find("#todo-list")

  render:()->

    Todo.all ()->
      console.log "teste"

new App
