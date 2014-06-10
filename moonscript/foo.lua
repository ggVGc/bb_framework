local ls = {
  1,
  2,
  3,
  4,
  5
}
local i1, i2 = 1, -1
do
  local _accum_0 = { }
  local _len_0 = 1
  local _max_0 = i2
  for _index_0 = i1, _max_0 < 0 and #ls + _max_0 +1 or _max_0 do
    local x = ls[_index_0]
    _accum_0[_len_0] = x
    _len_0 = _len_0 + 1
  end
  ls = _accum_0
end
for _index_0 = 1, #ls do
  local x = ls[_index_0]
  print(x)
end
