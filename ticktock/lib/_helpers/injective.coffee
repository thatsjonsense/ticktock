Deps.injective = (init, options) ->
  _value: init ? 0
  _dep: new Deps.Dependency
  _force: !!(options && options.force) ? false
  set: (value) ->
    if (@_value != value) || @_force
      @_value = value
      @changed()
    @
  get: ->
    @depend()
    @_value
  depend: ->
    @_dep.depend()
    @
  changed: ->
    @_dep.changed()
    @
  force: (f) ->
    @_force = !!f
    @