{WorkspaceView} = require 'atom'
YunoCommit = require '../lib/yuno-commit'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "YunoCommit", ->
  activationPromise = null

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    activationPromise = atom.packages.activatePackage('yuno-commit')

  describe "when the yuno-commit:toggle event is triggered", ->
    it "attaches and then detaches the view", ->
      expect(atom.workspaceView.find('.yuno-commit')).not.toExist()

      # This is an activation event, triggering it will cause the package to be
      # activated.
      atom.workspaceView.trigger 'yuno-commit:toggle'

      waitsForPromise ->
        activationPromise

      runs ->
        expect(atom.workspaceView.find('.yuno-commit')).toExist()
        atom.workspaceView.trigger 'yuno-commit:toggle'
        expect(atom.workspaceView.find('.yuno-commit')).not.toExist()
