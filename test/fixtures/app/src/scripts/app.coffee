$ = require "../../../../../bower_components/jquery/jquery.js"
Template = require "../templates/app.jade"
TemplateItem = require "../templates/item.jade"
Todo = require "./todo"

class App

  constructor:()->

    Todo.on "create", @create
    $("body").append Template()
    @setup()

    @fetch()

  setup:()->

    @el = $("#todoapp")
    @all_checkbox = @el.find("#toggle-all")[0];
    @input = @el.find("#new-todo")
    @footer = @el.find("#footer")
    @main = @el.find("#main")
    @list = @el.find("#todo-list")
    @new = @el.find "#new-todo"

    @events()

  events:()->
    @new.bind "keypress", @add


  fetch:()->

    Todo.all (todos, raw, err)=>

  render:(todos)->
    $("body").empty()
    @setup()

  add:(e)=>
    console.log "code"
    code = e.keyCode || e.which
    if code is 13
      if $(e.currentTarget).val().length
        Todo.create "title":$(e.currentTarget).val(), "done":"false"

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

  create:(item)=>
    dom = $(TemplateItem item.keys)
    dom.bind "dblclick", @edit
    @list.append dom


new App
