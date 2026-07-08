# Data Recording

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=66854  
> Forum: 17 · Topic 66854 · 2 post(s)

---

## Data Recording

**LeTigre30** · Tue Oct 23, 2018 11:23 pm

[Data Recording.lua](files/121727/Data%20Recording.lua)

Hello to all,

for all those who are followers of excel sheets and who want to record the data of the indicators during the trading, to be able to make a subsequent analysis, I add in my indi's these code :

```lua
Function init()
...
        indicator.parameters:addGroup("Data Recording");
   indicator.parameters:addBoolean("SetRecording", "Activate Data Recording", "", false);
   indicator.parameters:addString("File", "File's name", "", ".\\Data Recording\\Rec_AZZR_XAU_m30.csv");
...
end

-- Variables declaration
local mm;
local FileRec;
local Record;
local Title;
local Time;
local Str;
local Counter = 0;

Function Prepare()
...
-- Data Recording
   Record = instance.parameters.SetRecording;
   if Record then      -- Add a tick or prices counter like counter = counter +1
      FileRec = io.open(instance.parameters.File, "a+");
      assert(FileRec ~= nil, "FileRec == Nil");
      Time = core.host:execute("convertTime", core.TZ_LOCAL, core.TZ_TS, core.now());
      Time = core.dateToTable(core.now());
      mm = Time.min;
      Title = "Recording Started on " .. Time.day .. "/" .. Time.month .. "/" .. Time.year .. " " .. Time.hour .. ":" .. Time.min .. ":" .. Time.sec .. '\n';
      Title = Title .. "Chrono" .. ";" .. "Date Hour" .. ";" .. "period" .. ";" .. "MaxPrice" .. ";" .. "MinPrice" .. ";" .. "Open" .. ";" .. "High" .. ";" .. "Low" .. ";" .. "Close" .. ";" .. "B/S" .. '\n';
      FileRec:write(Title);
   end

...
end

function Update(period, mode)
...
...
-- Record Datas
if Record then
        -- For data's dating
        Counter = Counter + 1;
   Time = core.host:execute("convertTime", core.TZ_EST, core.TZ_LOCAL, source:date(period));
   Time = core.dateToTable(Time);
   Str = Counter .. ";" .. Time.day .. "/" .. Time.month .. "/" .. Time.year .. " " .. Time.hour .. ":" .. Time.min .. ":" .. Time.sec;
      if mm ~= Time.min then
      Str = Str .. ";" .. period .. ";" .. MaxPrice .. ";" .. MinPrice .. ";" .. source.open[period] .. ";" .. source.high[period] .. ";" .. source.low[period] .. ";" .. source.close[period] .. ";" .. sens ..'\n';
      FileRec:write(Str);
      mm = Time.min;
      end
   end
...
...
end
```

NB : Here, MaxPrice, MinPrice, Sens are variables for the calculation of the Indicator.

Hope it will help those who want to know the real things

Rgds,

LeTigre30

---

## Re: Data Recording

**LeTigre30** · Thu Oct 25, 2018 1:04 am

Hello to all,

Regarding my original post, **the code that i produced CANNOT be used as it alone**,
the traders who want use it, must integrate the different parts of the code in their own parts.

Pay attention : the lua file is not my code and it seems that Mario Jemic want take profit of my work;

If you want donate, you can do it via Paypal at [[email protected]](https://fxcodebase.com/cdn-cgi/l/email-protection#aec4c3d8cbc0cbdaeec3cfc9c7cd80c8dc)

Rgds,
LeTigre30
