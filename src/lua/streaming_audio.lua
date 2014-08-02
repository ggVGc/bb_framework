
framework = framework or {}

framework.StreamingAudio = {}

function framework.StreamingAudio.new(path)
  local M = {}

  local audio = _c_framework.streamingAudioLoad(path)

  function M.play()
    _c_framework.streamingAudioPlay(audio)
  end

  function M.stop()
    _c_framework.streamingAudioStop(audio)
  end

  function M.setLooping(loop)
    local v = 0
    if loop then v = 1 end
    _c_framework.streamingAudioSetLooping(audio, v)
  end

  function M.free()
    _c_framework.streamingAudioFree(audio)
  end

  if audio then
    return M
  end
end

