{View} = require 'space-pen'

module.exports =
class YunoCommitView extends View

  @content: ->
    @div class: 'yuno-commit', 'Y U NO commit?????'

  destroy: ->
    @detach() if @hasParent()

  set: (changes, threshold) ->
    if changes >= threshold
      @show()
      scale = Math.exp((changes - threshold) / (threshold * 2))
      this.css('transform', 'scale(' + scale.toFixed(4) + ')')
      this.toggleClass('is-aaaaaaaaa', changes > 2 * threshold)
    else
      @hide()

  show: (changes, threshold) ->
    atom.views.getView(atom.workspace).appendChild(this[0]) unless @_showing
    @_showing = true

  hide: ->
    @detach() if @hasParent()
    @_showing = false
