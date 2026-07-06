# AccountTradeLog

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=64933  
> Forum: 31 · Topic 64933 · 3 post(s)


---

## AccountTradeLog

**Apprentice** · Thu Jul 20, 2017 4:50 am

[AccountTradeLog.lua](files/113655/AccountTradeLog.lua)

Based on the request.
[viewtopic.php?f=27&t=64923](https://fxcodebase.com/code/viewtopic.php?f=27&t=64923)
MT4/MQ4 version.
[viewtopic.php?f=38&t=66948](https://fxcodebase.com/code/viewtopic.php?f=38&t=66948)


---

## Re: AccountTradeLog

**conjure** · Thu Aug 23, 2018 5:00 pm

Is it possible to also export the DISTANCE, of STOP and LIMIT, from current market rate , in pips?


---

## Re: AccountTradeLog

**conjure** · Fri Aug 24, 2018 11:33 am

i found a way... i think its right

Code: [Select all](https://fxcodebase.com/code/)
`function logTable(fileHandle, tableName, tableColumns)

    local enum, row,value;
    enum = core.host:findTable(tableName):enumerator();
    row = enum:next();
    while row ~= nil do
        for column = 1, #tableColumns do
            value = row:cell(tableColumns[column])
            fileHandle:write(tostring(value) .. Separator);
        end
symbol=row.Instrument              
         local enum2, row2;
   enum2 = core.host:findTable("offers"):enumerator();
   row2 = enum2:next();
   while row2 ~= nil do
if row2.Instrument==symbol then   
pips=row2.PointSize;
end
       row2 = enum2:next();
   end
   

   limit= math.abs(row.Close - row.Limit) / pips;
   stop= math.abs(row.Close - row.Stop) / pips;
limit=math.floor(limit)
stop=math.floor(stop)

               fileHandle:write(limit);
               fileHandle:write(",");
               fileHandle:write(stop);

       fileHandle:write("\n")
       row = enum:next();
    end
    ---fileHandle:flush(MergeFileHandle);
         fileHandle:close()

end`
