_ = require 'lodash'

module.exports = class Model

  @_config  = urls: {}, keys: {}
  @_records = []
  @_last_action:null

  cid   : null
  _keys: null



  ### --------------------------------------------------------------------------
    Configures model
  -------------------------------------------------------------------------- ###
  @configure:( config )->
    # configure urls ending points
    for method, i in ["create", "read", "update", "delete", "all", "find"]
      if (url = config.urls[method])?
        @_config.urls[method] = url 

    # configure keys and types
    for key, type of config.keys
      @_config.keys[key] = type


  ### --------------------------------------------------------------------------
    Constructor
  -------------------------------------------------------------------------- ###

  _init:(dict)->
    @_keys = {}
    @cid = @_guid()
    @set dict

  _guid:()=>
    @constructor._records.length

  ### --------------------------------------------------------------------------
    Global validate method, will perform simple validations for native types
    as well as run custom validations against the given methods in configuration
  -------------------------------------------------------------------------- ###
  validate : (key, val)->
    checker = @constructor._config.keys[key]

    # validate against native types (Number, String, Array, Object, Date)
    if /native code/.test checker
      switch ("#{checker}".match /function\s(\w+)/)[1]
        when 'String' then return (typeof val is 'string')
        when 'Number' then return (typeof val is 'number')
        else return (val instanceof type)

    # validates against the given method
    else
      return checker val


  ### --------------------------------------------------------------------------
    Getter / Setter
  -------------------------------------------------------------------------- ###
  get:(keyumn)->
    return @_keys[keyumn]

  # set 'prop', 'val'
  # set prop: 'val', prop2: 'val2'
  set:(args...)->

    # if a dictionary is given, set all keys individually
    if args.length is 1
      dict = args[0]
      for key, val of dict
        if @constructor._config.keys[key]
          @set key, val
        else
          @[key] = val
      return dict

    # otherwise set the given key / val
    key = args[0]
    val = args[1]
    if @validate key, val
      return @_keys[key] = val
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
  
    record._init keys
    @_records.push record
    record

  @create:(props, callback)->

    @_last_action = "create"

    # returns created model if callback isn't specified
    unless callback?
      return (@_create props)

    # sends request to server and handles response
    req = @fetch @_config.urls.create, 'POST', keys
    req.done (data)=> 
      record = @_create props
      callback record, data, null
    req.error (error)-> callback record, null, error


  @read:(id, callback)->
    found = ((_.find @_records, id:id) or (_.find @_records, cid:id))

    @_last_action = "read"

    return found unless callback?

    # sends request to server and handles response
    req = @fetch (@_config.urls.read.replace /(\:\w+)/, found?.id or id), 'GET'
    req.done (data)-> 
      record = found.update(data) || (@create data)
      callback record, data, null
    req.error (error)-> 
      callback found, null, error


  update:(keys, callback)->
    @set keys
    @constructor._last_action = "update"
    return keys unless callback?

    # sends request to server and handles response
    url = @constructor._config.urls.update.replace /(\:\w+)/, @id
    req = @constructor.fetch url, 'PUT', keys
    req.done (data)=> callback @, data, null
    req.error (error)=> callback @, null, error


  delete:(callback)->
    for record, i in @constructor._records
      @constructor._records.splice i, 1 if record is @

    @constructor._last_action = "delete"

    return true unless callback?

    # sends request to server and handles response
    url = @constructor._config.urls.delete.replace /(\:\w+)/, @id
    req = @constructor.fetch url, 'DELETE'
    req.done (data)=> callback true, data, null
    req.error (error)=> callback false, null, error


  @all:( callback )->
    # returns local version if callback isn't specified
    @_last_action = "all"
    return @_records unless callback?

    # sends request to server and handles response
    req = @fetch @_config.urls.all, 'GET'
    req.done (data)=>

      for keys in ([].concat data)
        found = _.find @_records, {id:keys.id}
        unless found
          @create keys
        else
          found.update keys

      callback do @all, data, null
    req.error (error)->
      callback do @all, null, error

  @find:( keys )->
    # returns local version
    if typeof keys is "object"
      keys = {_keys:keys}
      return _.where @_records, keys
    else
      return _.where @_records, {id:keys}


  save:( callback )=>

    done = (data)-> callback?(data, null)
    error = (error)-> callback?(null, error)
    
    switch @constructor._last_action

      when "create"
        url = @constructor._config.urls.create
        req = @constructor.fetch url, 'POST', @_keys
        req.done (data)=>
          @update data
          done data
        req.error error
      when "update"
        url = @constructor._config.urls.update.replace /(\:\w+)/, @id
        req = @constructor.fetch url, 'PUT', @_keys
        req.done done
        req.error error
      when "delete"
        url = @constructor._config.urls.delete.replace /(\:\w+)/, @id
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