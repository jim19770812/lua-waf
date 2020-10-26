local TableUtils={}

function TableUtils:nums(tableObj)
    local count = 0
    for k, v in pairs(tableObj) do
        count = count + 1
    end
    return count
end

function TableUtils:keys(tableObj)
    local keys = {}
    if t == nil then
        return keys;
    end
    for k, v in pairs(tableObj) do
        keys[#keys + 1] = k
    end
    return keys
end

function TableUtils:values(tableObj)
    local values = {}
    if t == nil then
        return values;
    end
    for k, v in pairs(tableObj) do
        values[#values + 1] = v
    end
    return values
end

function TableUtils:containKey(tableObj, key )
    for k, v in pairs(tableObj) do
        if key == k then
            return true;
        end
    end
    return false;
end

function TableUtils:containValue(tableObj, value )
    for k, v in pairs(tableObj) do
        if value == v then
            return true;
        end
    end
    return false;
end

function TableUtils:getKeyByValue(tableObj, value )
    for k, v in pairs(tableObj) do
        if value == v then
            return k;
        end
    end
end

function TableUtils:merge(destTableObj, srcTableObj)
    for k, v in pairs(srcTableObj) do
        destTableObj[k] = v
    end
end

function TableUtils:indexOfArray(arrayObj, value)
  for i=1, #arrayObj do
      if arrayObj[i] == value then
        return i
      end
  end
  return 0
end

return TableUtils