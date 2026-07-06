-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=28&t=66854



function Init()


indicator:name("Data Recording");
indicator:description("");
indicator:requiredSource(core.Bar);
indicator:type(core.Indicator);
 
indicator.parameters:addGroup("Data Recording");
indicator.parameters:addBoolean("SetRecording", "Activate Data Recording", "", false);
indicator.parameters:addString("File", "File's name", "", ".\\Data Recording\\Rec_AZZR_XAU_m30.csv");
 
end

-- Variables declaration
local mm;
local FileRec;
local Record;
local Title;
local Time;
local Str;
local Counter = 0;
local source;
function Prepare(nameOnly)


    local Parameters=  "," ..  instance.parameters.File;
    local name = profile:id() .. "(" ..  instance.source:name()  ..  Parameters .. ")";
    instance:name(name); 
	
   if   (nameOnly) then
        return;
    end

    
			
    source = instance.source;
 
-- Data Recording
Record = instance.parameters.SetRecording;
if Record then	-- Add a tick or prices counter like counter = counter +1
FileRec = io.open(instance.parameters.File, "a+");
assert(FileRec ~= nil, "FileRec == Nil");
Time = core.host:execute("convertTime", core.TZ_LOCAL, core.TZ_TS, core.now());
Time = core.dateToTable(core.now());
mm = Time.min;
Title = "Recording Started on " .. Time.day .. "/" .. Time.month .. "/" .. Time.year .. " " .. Time.hour .. ":" .. Time.min .. ":" .. Time.sec .. '\n';
Title = Title .. "Chrono" .. ";" .. "Date Hour" .. ";" .. "Open" .. ";" .. "High" .. ";" .. "Low" .. ";" .. "Close" .. '\n';
FileRec:write(Title);
end

 
end

function Update(period, mode)
 
-- Record Datas
if Record then
-- For data's dating
Counter = Counter + 1;
Time = core.host:execute("convertTime", core.TZ_EST, core.TZ_LOCAL, source:date(period));
Time = core.dateToTable(Time);
Str = Counter .. ";" .. Time.day .. "/" .. Time.month .. "/" .. Time.year .. " " .. Time.hour .. ":" .. Time.min .. ":" .. Time.sec;
if mm ~= Time.min then
Str = Str  .. ";" .. source.open[period] .. ";" .. source.high[period] .. ";" .. source.low[period] .. ";" .. source.close[period] ..'\n';
FileRec:write(Str);
mm = Time.min;
end
end
 
 
end