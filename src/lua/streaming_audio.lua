
framework = framework or {}

framework.StreamingAudio = {}

function framework.StreamingAudio.new(path)
  local M = {}

  local audio = _c_framework.audioLoad(path)

  function M.play()
    _c_framework.audioPlay(audio)
  end

  function M.stop()
    _c_framework.audioStop(audio)
  end

  function M.setLooping(loop)
    local v = 0
    if loop then v = 1 end
    _c_framework.audioSetLooping(audio, v)
  end

  function M.free()
    _c_framework.audioFree(audio)
  end
  function M.isFinished()
    return  _c_framework.audioIsFinished(audio)==1
  end

  if audio then
    return M
  end
end

