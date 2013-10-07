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
    @new.bind "keypress", @add_todo

  fetch:()->

    Todo.all (todos, raw, err)=>

  render:(todos)->
    $("body").empty()
    @setup()

  create:(item)=>

    dom = $(TemplateItem item)

    dom.bind "click", @reset_list
    dom.find("label").bind "dblclick", @edit_title
    dom.find(".toggle").bind "click", @edit_done
    dom.find(".destroy").bind "click", @delete_item

    @list.append dom

  reset_list:(e)=>

    lis = @list.find("li")

    @update_item $(li) for li in lis

  add_todo:(e)=>
    code = e.keyCode || e.which

    if code is 13

      if $(e.currentTarget).val().length

        Todo.create "title":$(e.currentTarget).val(), "done":"false"

  delete_item:(e)=>
    li = $($(e.currentTarget).parent().parent())
    item = Todo.read(li.data("id"))
    item.delete()
    li.remove()

  edit_done:(e)=>
    li = $($(e.currentTarget).parent().parent())
    @update_item li

  edit_title:(e)=>
    li = $($(e.currentTarget).parent().parent())

    li.find(".view").css "display":"none"
    li.find(".edit").css "display":"block"
    li.find(".edit").focus()

    li.find(".edit").bind "keypress", (e)=>
      code = e.keyCode || e.which
      if code is 13
        $(e.currentTarget).unbind "keypress"
        @update_item li

  update_item:(li)->
    item = Todo.read(li.data("id"))
    checked = li.find(".toggle").is(":checked")
    item.update "title":li.find(".edit").val(), "done":"#{checked}"

    li.find(".edit").css "display":"none"
    li.find(".view").css "display":"block"
    $("##{item.id}").find(".edit").val(item.get("title"))
    $("##{item.id}").find(".view").find("label").text(item.get("title"))



new App
