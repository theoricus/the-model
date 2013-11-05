Model = require "../../../../.."
$ = require "../../../../../bower_components/jquery/jquery.js"
Template = require "../templates/app.jade"
TemplateItem = require "../templates/item.jade"
Todo = require "./todo"
TodoType = require "./todo_types"

class App

  constructor:()->

    Todo.on "create", @create
    $("body").append Template()
    @setup()

    @fetch()

  setup:()->

    @el = $("#todoapp")
    @all_checkbox = @el.find("#toggle-all")[0]
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

    window.todo = Todo.read(0);
    
    dom = $(TemplateItem item)
    dom.attr("data-edit", false)
    dom.find("label").bind "dblclick", @edit_title
    dom.find(".toggle").bind "click", @edit_done
    dom.find(".destroy").bind "click", @delete_item
    dom.bind "click", @reset_list

    @list.append dom

  reset_list:(e)=>
    li_dom = $(e.currentTarget)

    return if li_dom.attr("data-edit") is "true"

    lis = @list.find("li")

    for li in lis
      if $(li).attr("data-edit") is "true"
        @update_item $(li)

  add_todo:(e)=>
    code = e.keyCode || e.which

    if code is 13

      if $(e.currentTarget).val().length

        unless window.remote
          Todo.create "title":$(e.currentTarget).val(), "done":false, "customer_id":0
        else

          Todo.create {"title":$(e.currentTarget).val(), "done":false, "customer_id":0}, (record, raw, error)->

            console.log "record", record
            console.log "raw", raw
            console.log "error", error




  delete_item:(e)=>
    li = $($(e.currentTarget).parent().parent())
    item = Todo.read(li.data("cid"))
    unless window.remote
      item.delete()
      li.remove()
    else
      item.delete (deleted)->
        li.remove() if deleted


  edit_done:(e)=>
    li = $($(e.currentTarget).parent().parent())
    @update_item li
    li.attr("data-edit", true)

  edit_title:(e)=>
    li = $($(e.currentTarget).parent().parent())
    li.attr("data-edit", true)

    li.find(".view").css "display":"none"
    li.find(".edit").css "display":"block"
    li.find(".edit").focus()

    li.find(".edit").bind "keypress", (e)=>
      code = e.keyCode || e.which
      if code is 13
        $(e.currentTarget).unbind "keypress"
        @update_item li

  update_item:(li)->
    item = Todo.read(li.data("cid"))
    checked = li.find(".toggle").is(":checked")

    unless window.remote
      console.log ("title":li.find(".edit").val(), "done":checked)
      item.update "title":li.find(".edit").val(), "done":checked
    else
      item.update "title":li.find(".edit").val(), "done":checked, (record, raw, err)->
        console.log "record", record
        console.log "raw", raw
        console.log "error", error

    li.find(".edit").css "display":"none"
    li.find(".view").css "display":"block"
    $("#todo_#{item.cid}").find(".edit").val(item.get("title"))
    $("#todo_#{item.cid}").find(".view").find("label").text(item.get("title"))
    li.attr("data-edit", false)



new App
