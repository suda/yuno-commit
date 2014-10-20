{View} = require 'atom'

module.exports =
class YunoCommitView extends View
  @content: ->
    @div class: 'yuno-commit', 'Y U NO commit?????'

  initialize: (serializeState) ->
    repos = atom.project.getRepositories()
    if repos.length > 0
      repo = repos[0]
      repo.onDidChangeStatus (event) ->
        console.log 'onDidChangeStatus', event


  serialize: ->

  destroy: ->
    @detach()

  show: ->
    atom.workspaceView.append(this)

  hide: ->
    if @hasParent()
      @detach()
