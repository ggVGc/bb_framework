
framework = framework or {}

groups = {}

framework.Audio = {
setGlobalMute: (mute)->
  _c_framework.audioSetAllMuted(mute and 1 or 0)

setGroupMute: (groupName, mute)->
  g = groups[groupName]
  if g
    g.muted = mute
    for m in *g.members
      m.setMuted mute
  else
    groups[groupName] =  {muted:mute, members:{}}

new: (nativeAudio)->
  @ = {}

  @play = ->
    if not @group or not @group.muted
      _c_framework.audioPlay(nativeAudio)

  @playLooping = ->
    @.setLooping true
    @.play!

  @playIfNotPlaying = ->
    @.play! if not @.isPlaying!

  @stop = ->
    _c_framework.audioStop nativeAudio

  @setLooping = (loop)->
    _c_framework.audioSetLooping(nativeAudio, loop and 1 or 0)

  @free = ->
    _c_framework.audioFree nativeAudio

  @isPlaying = ->
    _c_framework.audioIsPlaying(nativeAudio)==1

  @setPaused = (pause)->
    _c_framework.audioSetPaused(nativeAudio, pause and 1 or 0)

  @setMuted = (mute)->
    nativeAudio.muted = mute and 1 or 0
    _c_framework.audioSetPaused(nativeAudio, mute and 1 or 0)

  @setGroup = (groupName)->
    if not groupName
      if @group
        ind = _.indexOf @group.members, @
        while ind
          table.remove @group.members, ind
          ind = _.indexOf @group.members, @
      @group = nil
    else
      if not groups[groupName]
        groups[groupName] = {}
        groups[groupName].members = {}
      g = groups[groupName]
      @group = g
      if not _.indexOf g.members, @
        table.insert g.members, @
      @.setMuted g.muted


  return @
}

framework.Audio.fromFile = (path)->
  framework.Audio.new _c_framework.audioLoad(path)

