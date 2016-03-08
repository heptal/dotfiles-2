-- Return the sorted keys of a table
function tableKeys(t)
  local keys={}
  for k, v in pairs(t) do
    table.insert(keys, k)
  end
  table.sort(keys)
  return keys
end

function ppairs(t)
  for k,v in pairs(t) do print(k,v) end
end

function tableSet(t)
  local hash = {}
  local res = {}
  for _, v in ipairs(t) do
    if not hash[v] then
      res[#res + 1] = v
      hash[v] = true
    end
  end
  return res
end

function tableMerge(t1, t2)
  for k, v in pairs(t2) do
    t1[k] = v
  end
  return t1
end

function tableContains(t, key)
  for i, v in ipairs(t) do
    if v == key then return i end
  end
end

function tableSubrange(t, first, last)
  local sub = {}
  for i=first,last do
    sub[#sub + 1] = t[i]
  end
  return sub
end

function tableCompare(t1, t2)
  local t1Keys, t2Keys = tableKeys(t1), tableKeys(t2)
  if #t1Keys ~= #t2Keys then return false end
  for _, key in ipairs(t1Keys) do
    if t1[key] ~= t2[key] then return false end
  end
  return true
end

function hex(num) return string.format("%x", num) end
