local StringUtils={}

function StringUtils:lTrim(s)
	return string.match(s, '[^%s+].*')
end

function StringUtils:rTrim(s)
	return string.match(s, '(.-)%s*$')
end

function StringUtils:toBool(value)
  return not not value
end

function StringUtils:slice(s, start, finish)
    return string.sub(s, start, finish or #s)
end

function StringUtils:startWiths(s, start)
    return string.sub(s, 1, #start) == start
end

function StringUtils:endWiths(s, finish)
    return string.sub(s, -#finish) == finish
end

function StringUtils:count(s, substr)
    local total = 0
    local start = nil
    local finish = 1

    repeat
      start, finish = string.find(s, substr, finish, true)
      if start then total = total + 1 end
    until start == nil

    return total
end

function StringUtils:split(s, pattern)
    local output = {}
    local fpat = '(.-)' .. pattern
    local last_end = 1
    local _s, e, cap = s:find(fpat, 1)

    while _s do
      if _s ~= 1 or cap ~= '' then
        table.insert(output, cap)
      end

      last_end = e+1
      _s, e, cap = s:find(fpat, last_end)
    end

    if last_end <= #s then
      cap = s:sub(last_end)
      table.insert(output, cap)
    end

    return output
end

function StringUtils:capitalize(s)
  if #s == 0 then
    return s
  end

  local output = {}
  output[1] = string.upper(string.sub(s, 1, 1))

  for i=2, #s do
    local character = string.sub(s, i, i)
    table.insert(output, string.lower(character))
  end

  return table.concat(output)
end

function StringUtils:isAscii(s)
  for i=1, #s do
    if string.byte(s:sub(i, i)) > 126 then return false end
  end

  return true
end

function StringUtils:isNumber(s)
  return self:toBool(string.find(s, '^%d+$'))
end

function StringUtils:strReplace(str, oldStr, newStr)
  local result=string.gsub(str, oldStr, newStr )  
  return result
end

return StringUtils