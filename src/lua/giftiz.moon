framework = framework or {}

completed = false
buttonVisible = false
_c_framework.giftizSetButtonVisible 0

framework.Giftiz = {
  completeMission: ()->
    if not completed
      print 'COmpleting mission'
      _c_framework.giftizCompleteMission!
      completed = true
  setButtonVisible: (v)->
    if buttonVisible ~= v
      _c_framework.giftizSetButtonVisible(v and 1 or 0)
      buttonVisible = v

}

framework.Ads
