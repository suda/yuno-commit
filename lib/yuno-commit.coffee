YunoCommitView = require './yuno-commit-view'
{ Observable } = require 'rx'
{ execFile } = require 'child_process'

intents = ->

  save川: Observable.create (observer) ->
    atom.commands.add 'atom-workspace', 'core:save', (event) ->
      observer.onNext(event)


model = (intents) ->

  repositoryPath = ->
    atom.project.getRepositories()[0]?.getWorkingDirectory()

  diffNumStat川 = (repositoryPath) ->
    Observable.fromNodeCallback(execFile)('git', ['diff', '--numstat'], cwd: repositoryPath)
    .map ([stdout, stderr]) -> stdout

  diffStat川 = (repositoryPath) ->
    diffNumStat川(repositoryPath)
    .map (stdout) ->
      stdout
        .split /\r\n|\r|\n/
        .map (x) -> x.trim()
        .filter (x) -> x
        .map (x) -> x.split(/\s+/).slice(0, 2).map((n) -> +n).reduce((a, b) -> a + b)
        .reduce ((a, b) -> a + b), 0
    .catch (err) -> Observable.just(err)

  refresh川 = intents.save川.map(repositoryPath).startWith(repositoryPath())

  refresh川.map(diffStat川).merge(1)


module.exports =
  yunoCommitView: null

  activate: ->
    @view = new YunoCommitView()
    @model = model(intents())
    @subscription = @model.subscribe (changes) => @update(changes)

  update: (changes) ->
    threshold = atom.config.get('yuno-commit.numberOfChangesToShowWarning')
    @view.set(changes, threshold)

  deactivate: ->
    @view.detach()
    @subscription.dispose()

  config:
    numberOfChangesToShowWarning:
      type: 'integer'
      default: 50
