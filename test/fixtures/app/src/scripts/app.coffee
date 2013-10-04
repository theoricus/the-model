$ = require "../../../../../bower_components/jquery/jquery.js"
Template = require "../templates/app.jade"
Todo = require "./todo"

class App

  constructor:()->

    @render()

  setup:()->

    @el = $("#todoapp")
    @all_checkbox = @el.find("#toggle-all")[0];
    @input = @el.find("#new-todo")
    @footer = @el.find("#footer")
    @main = @el.find("#main")
    @list = @el.find("#todo-list")

    @events()

  events:()->
    @list.find("li").bind "dblclick", @edit

  render:()->

    Todo.all (todo, raw, err)=>
      unless err
        $("body").append Template "todos":todo
        @setup()

  edit:(e)=>

    li = $ e.currentTarget
    @edit_item li

  edit_item:(li)->
    li.find(".view").css "display":"none"
    li.find(".edit").css "display":"block"
    li.find(".edit").focus()

    li.find(".edit").bind "keypress", (e)=>
      code = e.keyCode || e.which
      if code is 13
        $(e.currentTarget).unbind "keypress"
        @save_item li

  save_item:(li)->
    li.find(".edit").css "display":"none"
    li.find(".view").css "display":"block"


new App
