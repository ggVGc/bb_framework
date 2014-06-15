string.lastIndexOf = (str, findStr)->
  #str - string.find(string.reverse(str), findStr)+1

string.endsWith = (str, ending)->
  s,e = string.find str, ending
  e == #str
