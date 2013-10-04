###
Port of MicroEvent in Coffeescript with some naming modifications
and a new 'once' method.

Original project:
https://github.com/jeromeetienne/microevent.js
###
class MicroEvent
  _init_event:-> @_listn or @_listn = {}
  _create_event:(e)-> @_init_event()[e] or  @_init_event()[e] = []
  on:(e, f)-> (@_create_event e).push f
  off:(e, f)-> (t.splice (t.indexOf f), 1) if (t = @_init_event()[e])?
  once:(e, f)-> @on e, (t = => (@off e, t) && f.apply @, arguments)
  emit:(e, p)-> l p for l in t if (t = @_init_event()[e])?; 0
  @include=(t)-> t::[p] = @::[p] for p of @::; 0
  @extend: (obj) ->
    for key, value of obj
      @[key] = value
    @

module.exports = MicroEvent
