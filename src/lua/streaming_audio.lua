
framework = framework or {}

framework.StreamingAudio = {}
framework.StreamingAudio.setMute = function(mute)
  _c_framework.audioSetMuted(mute and 1 or 0);
end

function framework.StreamingAudio.new(nativeAudio)
  local M = {}

  function M.play()
    _c_framework.audioPlay(nativeAudio)
  end
  function M.playLooping()
    M.setLooping(true)
    _c_framework.audioPlay(nativeAudio)
  end
  function M.playIfNotPlaying()
    if not M.isPlaying() then
      M.play()
    end
  end

  function M.stop()
    _c_framework.audioStop(nativeAudio)
  end

  function M.setLooping(loop)
    local v = 0
    if loop then v = 1 end
    _c_framework.audioSetLooping(nativeAudio, v)
  end

  function M.free()
    _c_framework.audioFree(nativeAudio)
  end
  function M.isPlaying()
    return  _c_framework.audioIsPlaying(nativeAudio)==1
  end

  return M
end


function framework.StreamingAudio.fromFile(path)
  return framework.StreamingAudio.new(_c_framework.audioLoad(path))
end
