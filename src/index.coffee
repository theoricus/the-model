_ = require 'lodash'
$ = require '../bower_components/jquery/jquery'
Pivot = require "the-pivot"

###*
  The Model class is responsible for saving data locally and remotelly requesting web-services.

  @class Model
###

class Model extends Pivot

  ###
  @property {Number} Stores the local ID of the object (client id).
  ###
  cid   : null

  ###
  @property {Object} Stores the instances attributes
  ###
  keys: null

  ###
  @property {Object} ID's key name, it might change to "_id" if the webservices return data from mongodb.
  ###
  id:"id"

  ###
    Responsible for configuring the Models rest URLs, attributes and ID's key name.

    @param config {Object} Object containing the REST urls, and the Model attributes.
    @example
      class Todo extends Model

        @configure

          urls:
            'all':'http://localhost:3000/todos'
            'create':'http://localhost:3000/todos'
            'read':'http://localhost:3000/todos/:id'
            'update':'http://localhost:3000/todos/:id'
            'delete':'http://localhost:3000/todos/:id'

          keys:
            "title":String
            "done":Boolean

          id:"_id"

  ###
  @configure:( config )->

    @klass = @.toString().match(/function\s(.*)\(\)/)[1]

    @_config  = urls: {}, keys: {}
    @_records = []
    @_last_action=null
    @klass=""

    # configure urls ending points
    for method, i in ["create", "read", "update", "delete", "all", "find"]
      if (url = config.urls[method])?
        @_config.urls[method] = url

    # configure keys and types
    for key, type of config.keys
      @_config.keys[key] = type

    @id = config.id if config.id

    @extend new Pivot

  _init:(dict)->
    @keys = {}
    @cid = @constructor._records.length
    @set dict

  ###

    Global validate method, will perform simple validations for native types
    as well as run custom validations against the given methods in configuration

    Validates the attributes values against the 'types' setted in the `@configure` method.

    @param key {String} Attribute to be validated
    @param val {String} Value to validate

  ###
  validate : (key, val)->
    checker = @constructor._config.keys[key]

    # validate against native types (Number, String, Array, Object, Date)
    if /native code/.test checker
      switch ("#{checker}".match /function\s(\w+)/)[1]
        when 'String' then return (typeof val is 'string')
        when 'Number' then return (typeof val is 'number')
        when 'Boolean' then return (typeof val is 'boolean')
        when 'Array' then return (val instanceof checker)
        when 'Object' then return (typeof val is 'object')
        when 'Date' then return (val instanceof checker)

    # validates against the given method
    else
      return (val instanceof checker)


  ### --------------------------------------------------------------------------
    Getter / Setter
  -------------------------------------------------------------------------- ###
  get:(keyumn)->
    return @keys[keyumn]

  # set 'prop', 'val'
  # set prop: 'val', prop2: 'val2'
  set:(args...)->

    # if a dictionary is given, set all keys individually
    if args.length is 1
      dict = args[0]
      for key, val of dict
        if @constructor._config.keys[key]
          @set key, val
        else if key isnt @constructor.id
          @[key] = val
        else if key is @constructor.id
          @["id"] = val
      return dict

    # otherwise set the given key / val
    key = args[0]
    val = args[1]
    if @validate key, val
      return @keys[key] = val
    else
      throw new Error "Invalid type for keyumn '#{key}' = #{val}"


  ### --------------------------------------------------------------------------
    CURD and helpful methods
  -------------------------------------------------------------------------- ###

  @_create:(props)->
    keys = {}
    record = new @

    for k, v of props
      if @_config.keys[k]
        keys[k] = v
      else
        record[k] = v

    if props[@id]
      keys.id = props[@id]

    record._init keys
    @_records.push record
    record

  @create:(props, callback)->

    @_last_action = "create"

    # returns created model if callback isn't specified
    unless callback?
      record = (@_create props)
      @trigger "create", record
      @trigger "change", record
      return record

    # sends request to server and handles response
    req = @fetch @_config.urls.create, 'POST', props
    req.done (data)=>
      record = @_create data
      @trigger "create", record
      @trigger "change", record
      callback record, null
    req.error (error)-> callback null, error


  @read:(id, callback)->
    found = ((_.find @_records, id:id) or (_.find @_records, cid:id))

    unless callback?
      return found

    # sends request to server and handles response
    req = @fetch (@_config.urls.read.replace /(\:\w+)$/, found?.id or id), 'GET'
    req.done (data)->
      record = found.update(data) || (@create data)
      callback record, null
    req.error (error)->
      callback null, error


  update:(keys, callback)->
    @set keys
    @constructor._last_action = "update"

    unless callback?
      @trigger "update", @
      @trigger "change", @
      return @

    # sends request to server and handles response
    url = @constructor._config.urls.update.replace /(\:\w+)$/, @id
    req = @constructor.fetch url, 'PUT', keys
    req.done (data)=>
      @trigger "update"
      @trigger "change"
      callback @, null
    req.error (error)=> callback null, error


  delete:(callback)->
    for record, i in @constructor._records
      @constructor._records.splice i, 1 if record is @

    @constructor._last_action = "delete"

    unless callback?
      @trigger "change", @
      @trigger "delete", @
      return true

    # sends request to server and handles response
    url = @constructor._config.urls.delete.replace /(\:\w+)$/, @id
    req = @constructor.fetch url, 'DELETE'
    req.done (data)=>
      @trigger "change"
      @trigger "delete"
      callback true, null
    req.error (error)=> callback false, error


  @all:( callback )->
    # returns local version if callback isn't specified
    return @_records unless callback?

    # sends request to server and handles response
    req = @fetch @_config.urls.all, 'GET'
    req.done (data)=>

      for keys in ([].concat data)
        found = _.find @_records, {id:keys[@id]}
        unless found
          @create keys
        else
          found.update keys

      callback data, null
    req.error (error)->
      callback null, error

  @find:( keys )->
    # returns local version
    if typeof keys is "object"
      keys = {keys:keys}
      return _.where @_records, keys
    else
      found = _.where @_records, {id:keys}

      if found.length
        return found
      else
        return _.where @_records, {cid:keys}


  save:( callback )=>

    done = (data)-> callback?(data, null)
    error = (error)-> callback?(null, error)

    switch @constructor._last_action

      when "create"
        url = @constructor._config.urls.create
        req = @constructor.fetch url, 'POST', @keys
        req.done (data)=>
          @update data
          done data
        req.error error
      when "update"
        url = @constructor._config.urls.update.replace /(\:\w+)$/, @id
        req = @constructor.fetch url, 'PUT', @keys
        req.done done
        req.error error
      when "delete"
        url = @constructor._config.urls.delete.replace /(\:\w+)$/, @id
        req = @constructor.fetch url, 'DELETE'
        req.done done
        req.error error


  ### --------------------------------------------------------------------------
    Middleware
  -------------------------------------------------------------------------- ###

  @fetch:( url, type, data )->
    req = {url, type, data}

    # sets dataType to json if url ends .json
    req.dataType = 'json'

    # return request obj to be listened / handled
    return $.ajax req

# exporting
if exports and module and module.exports
  module.exports = Model
