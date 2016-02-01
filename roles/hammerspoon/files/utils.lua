-- Return the sorted keys of a table
function tableKeys(tab)
  local keys={}
  for k,v in pairs(tab) do table.insert(keys,k) end
  table.sort(keys)
  return keys
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
  for i = 1, #t2 do
    t1[#t1 + 1] = t2[i]
  end
  return t1
end

function tableContains(t, key)
  for i, v in ipairs(t) do
    if v==key then return i end
  end
end
