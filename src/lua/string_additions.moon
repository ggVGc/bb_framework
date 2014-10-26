string.lastIndexOf = (str, findStr)->
  #str - string.find(string.reverse(str), findStr)+1

string.endsWith = (str, ending)->
  start = #str-#ending+1
  return str\sub(start) == ending



string.split = (self, sSeparator, nMax, bRegexp) ->
  assert sSeparator ~= ''
  assert nMax == nil or nMax >= 1
  aRecord = {}
  if self\len! > 0
      bPlain = not bRegexp
      nMax = nMax or -1

      nField=1
      nStart=1
      nFirst,nLast = self\find sSeparator, nStart, bPlain
      while nFirst and nMax ~= 0
          aRecord[nField] = self\sub nStart, nFirst-1
          nField = nField+1
          nStart = nLast+1
          nFirst,nLast = self\find sSeparator, nStart, bPlain
          nMax = nMax-1
      aRecord[nField] = self\sub nStart
  return aRecord

