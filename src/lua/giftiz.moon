framework = framework or {}

completed = false

framework.Giftiz = {
  completeMission: ()->
    if not completed
      print 'COmpleting mission'
      _c_framework.giftizCompleteMission!
      completed = true

}

framework.Ads
