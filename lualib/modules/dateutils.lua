local DateUtils={}

function DateUtils:getLongDateTimeFormat()
   return "%Y-%m-%d %X";
end;

function DateUtils:getDateFormat()
   return "%Y-%m-%d";
end;

--获取日期时间字符串
function DateUtils:getDatetimeString(format)
  return os.date(format);
end;

return DateUtils