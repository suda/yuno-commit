YunoCommitView = require './yuno-commit-view'
{ Observable } = require 'rx'
{ execFile } = require 'child_process'

intents = ->

  save = Observable.create (observer) ->
    atom.commands.add 'atom-workspace', 'core:save', (event) ->
      observer.onNext(event)

  repositories = atom.project.getRepositories()

  repositoryStatusUpdates = Observable.from(repositories)
    .flatMap (repository) ->
      if repository
        Observable.create (observer) ->
          repository.onDidChangeStatuses (event) ->
            observer.onNext(event)
      else
        Observable.empty()

  refresh: Observable.merge(save, repositoryStatusUpdates).delay(138)


model = (intents) ->

  repositoryPath = ->
    atom.project.getRepositories()[0]?.getWorkingDirectory()

  diffNumStat = (repositoryPath) ->
    Observable.fromNodeCallback(execFile)('git', ['diff', '--numstat'], cwd: repositoryPath)
    .map ([stdout, stderr]) -> stdout

  diffStat = (repositoryPath) ->
    diffNumStat(repositoryPath)
    .map (stdout) ->
      stdout
        .split /\r\n|\r|\n/
        .map (x) -> x.trim()
        .filter (x) -> x
        .map (x) -> x.split(/\s+/).slice(0, 2).map((n) -> +n).reduce((a, b) -> a + b)
        .reduce ((a, b) -> a + b), 0
    .catch (err) -> Observable.just(err)

  refresh = intents.refresh.map(repositoryPath).startWith(repositoryPath())

  changes = refresh.map(diffStat).merge(1)

  threshold = Observable.create (observer) ->
    atom.config.observe 'yuno-commit-plus.numberOfChangesToShowWarning', (threshold) ->
      observer.onNext(threshold)

  { changes, threshold }

module.exports =
  yunoCommitView: null

  activate: ->
    @view = new YunoCommitView()
    @model = model(intents())

    state = Observable.combineLatest(
      @model.changes, @model.threshold,
      (changes, threshold) -> { changes, threshold })

    @subscription = state.subscribe ({ changes, threshold }) =>
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
