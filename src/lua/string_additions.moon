string.lastIndexOf = (str, findStr)->
  #str - string.find(string.reverse(str), findStr)+1

string.endsWith = (str, ending)->
  start = #str-#ending+1
  return str\sub(start) == ending

