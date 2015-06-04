{View} = require 'atom'
Subscriber = null
fs = null
path = null

module.exports =
class YunoCommitView extends View
  @content: ->
    @div class: 'yuno-commit', 'Y U NO commit?????'

  initialize: (serializeState) ->
    {Subscriber} = require 'emissary'
    fs ?= require 'fs-plus'
    path ?= require 'path'

    repos = atom.project.getRepositories()
    if repos.length > 0 and repos[0]
      @repo = repos[0]

      @subscriber = new Subscriber()
      @subscriber.subscribeToCommand atom.workspaceView, 'core:save', =>
        setTimeout =>
          changes = 0

          for file in @walkPath(atom.project.getPaths()[0])
            stats = @repo.getDiffStats file
            changes += stats.added
            changes += stats.deleted

          threshold = atom.config.get('yuno-commit.numberOfChangesToShowWarning')
          if threshold < changes
            @show(changes, threshold)
          else
            @hide()
        , 138

  serialize: ->

  destroy: ->
    @detach()

  show: (changes, threshold) ->
    atom.workspaceView.append(this) unless @_showing
    @_showing = true
    scale = Math.exp((changes - threshold) / (threshold * 2))
    this.css('transform', 'scale(' + scale.toFixed(4) + ')')
    this.toggleClass('is-aaaaaaaaa', changes > 2 * threshold)

  hide: ->
    if @hasParent()
      @detach()
    @_showing = false

  walkPath: (directory) ->
    results = []
    list = fs.readdirSync directory

    for file in list
      file = directory + path.sep + file
      stat = fs.lstatSync file
      isHidden = /^\./.test path.basename(file)

      if !isHidden && !stat.isSymbolicLink() && !@repo.isPathIgnored(file)
        if stat && stat.isDirectory()
          results = results.concat @walkPath(file)
        else
          results.push file

    results
