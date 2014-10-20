YunoCommitView = require './yuno-commit-view'

module.exports =
  yunoCommitView: null

  activate: (state) ->
    @yunoCommitView = new YunoCommitView(state.yunoCommitViewState)

  deactivate: ->
    @yunoCommitView.destroy()

  serialize: ->
    yunoCommitViewState: @yunoCommitView.serialize()
