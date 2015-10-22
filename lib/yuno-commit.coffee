YunoCommitView = require './yuno-commit-view'
{ Observable } = require 'rx'
{ execFile } = require 'child_process'

intents = ->

  save川 = Observable.create (observer) ->
    atom.commands.add 'atom-workspace', 'core:save', (event) ->
      observer.onNext(event)

  repositories = atom.project.getRepositories()

  return refresh川: save川.delay(138) unless repositories[0]

  repositoryStatusUpdates川 = Observable.from(repositories)
    .flatMap (repository) ->
      Observable.create (observer) ->
        repository.onDidChangeStatuses (event) ->
          observer.onNext(event)

  refresh川: Observable.merge(save川, repositoryStatusUpdates川).delay(138)


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

  refresh川 = intents.refresh川.map(repositoryPath).startWith(repositoryPath())

  changes川 = refresh川.map(diffStat川).merge(1)

  threshold川 = Observable.create (observer) ->
    atom.config.observe 'yuno-commit-plus.numberOfChangesToShowWarning', (threshold) ->
      observer.onNext(threshold)

  { changes川, threshold川 }

module.exports =
  yunoCommitView: null

  activate: ->
    @view = new YunoCommitView()
    @model = model(intents())

    state川 = Observable.combineLatest(
      @model.changes川, @model.threshold川,
      (changes, threshold) -> { changes, threshold })

    @subscription = state川.subscribe ({ changes, threshold }) =>
      @update(changes, threshold)

  update: (changes, threshold) ->
    @view.set(changes, threshold)

  deactivate: ->
    @view.detach()
    @subscription.dispose()

  config:
    numberOfChangesToShowWarning:
      type: 'integer'
      default: 50
