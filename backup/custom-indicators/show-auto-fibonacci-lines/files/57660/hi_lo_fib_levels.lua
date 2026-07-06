
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2338&start=10

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |  
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+
 

-- --------------------------------------------------------------------
-- Indicator profile
-- --------------------------------------------------------------------
function Init()
    indicator:name("Show High/Low Fibonacci Levels");
    indicator:description("Indicator shows fibonacci levels between high and low prices of chosen period");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Lines");
    AddLevel(1, -0.618, false);
    AddLevel(2, -0.382, false);
    AddLevel(3, -0.272, false);
    AddLevel(4,  0.000, false);
    AddLevel(5,  0.236, false);
    AddLevel(6,  0.382, true);
    AddLevel(7,  0.500, true);
    AddLevel(8,  0.618, true);
    AddLevel(9,  0.764, false);
    AddLevel(10,  1.000, false);
    AddLevel(11,  1.272, false);
    AddLevel(12,  1.618, false);
    AddLevel(13,  2.618, false);
    AddLevel(14,  4.236, false);
   --indicator.parameters:addGroup("Calculation");
   -- indicator.parameters:addBoolean("Auto", "Use Last Period As Line End","", false)
  
    indicator.parameters:addGroup("Alert Style");
    indicator.parameters:addColor("lcolor", "Period Line Color", "", core.rgb(255, 128, 0));
    indicator.parameters:addGroup("Display and Store Data");
    indicator.parameters:addString("label", "The label", "", "A");
    indicator.parameters:addBoolean("privateSettings", "Save settings per instrument", "If 'yes' is chosen, the date from/to will be saved per instrument per label, if 'no' is chosen the date from/to will be save per label only ", true);

   
end


-- --------------------------------------------------------------------
-- Indicator profile
-- --------------------------------------------------------------------

local Auto; 
local levels = {};
local firstCall = true;
local source = nil;
local format;
local point;
local dummy;
local barSize;
local label;
local ecolor = {};
local  estyle = {};
local   ewidth = {};
local  lcolor = {};
local  lstyle = {};
local  lwidth = {};
local db = nil;
local dateFromDBName;
local dateToDBName;

-- Overridable: prepare an instance
function Prepare(nameOnly)
    local i;
    Auto = instance.parameters.Auto;
    source = instance.source;
    label = instance.parameters.label;

    instance:name(profile:id() .. "(" .. source:name() .. "," .. label .. ")");

    if   (nameOnly) then
        return;
    end

    local s, e;
    s, e = core.getcandle(source:barSize(), core.now(), 0);
    s = e - s;  -- length of candle in days
    barSize = s;

    for i = 1, 14, 1 do
        local level = {};
        level.price = instance.parameters:getDouble("level" .. i);
        level.show = instance.parameters:getBoolean("show" .. i);
        levels[i] = level;
		 ecolor[i] = instance.parameters:getInteger("ecolor" .. i);
		 estyle[i] = instance.parameters:getInteger("estyle" .. i);
		 ewidth[i] = instance.parameters:getInteger("ewidth" .. i);
		 lcolor[i] = instance.parameters:getInteger("lcolor" .. i);
		 lstyle[i] = instance.parameters:getInteger("lstyle" .. i);
		 lwidth[i] = instance.parameters:getInteger("lwidth" .. i);
    end

    format = label .. "(%.3f:=%." .. source:getPrecision() .. "f)";
    point = instance:createTextOutput("Alert", "Alert", "Wingdings", 10, core.H_Center, core.V_Center, instance.parameters.lcolor, 0);
    core.host:execute("addCommand", 1001, "Search High/Low From...", "");
    core.host:execute("addCommand", 1002, "Search High/Low To...", "");
    core.host:execute("addCommand", 1003, "Reset dates", "");

    -- initialize a database
    require('storagedb')
    db = storagedb.get_db('hi_lo_fib_levels');
    if instance.parameters.privateSettings then
        dateFromDBName = source:instrument() .. "_" .. label .. "_" .. "dateFrom";
        dateToDBName = source:instrument() .. "_" .. label .. "_" .. "dateTo";
    else
        dateFromDBName = "ALL" .. "_" .. label .. "_" .. "dateFrom";
        dateToDBName = "ALL" .. "_" .. label .. "_" .. "dateTo";
    end
	
	 --core.host:execute("setTimer", 1, 1);
end

local dateFrom = 0;
local dateTo = 0;

-- Overridable: update an instance
function Update(period, mode)
    local i;

    if period == source:size() - 1 then
        if firstCall and period > 50 then
            local from, to;
            -- get initial date values from the database
            from = db:get(dateFromDBName, '0');
            to = db:get(dateToDBName, '0');

            if from == '0' or to == '0' then
                from = math.max(source:first(), period - 50);
                to = period;
                SetData(source:date(from), source:date(to));
            else
                SetData(tonumber(from), tonumber(to));
            end
            firstCall = false;
        end
    end
end

-- Overridable: release an instance
function ReleaseInstance()
    SaveDates();
end

-- Overridable: hook for commands
function AsyncOperationFinished(cookie, success, message)
    if cookie == 1001 then
        local from = dateFrom;
        local to;
		
		
		to = dateTo;
 		

        from = Parse(message);
        if from ~= nil then
            SetData(from, to);
        end
    elseif cookie == 1002 or cookie == 1 then
        local from = dateFrom;
        local to = dateTo;
				
		
		 to = Parse(message);
 		
		
        if from ~= nil then
            SetData(from, to);
        end
    elseif cookie == 1003 then
        from = math.max(source:first(), source:size() - 51);
        to = source:size() - 1;
        SetData(source:date(from), source:date(to));
    end
end

-- --------------------------------------------------------------------
-- Utility functions
-- --------------------------------------------------------------------

-- add level to profile's parameters
function AddLevel(id, level, show)

    indicator.parameters:addGroup(id.. ". Levels");
	indicator.parameters:addDouble("level" .. id, "Level " .. id, "", level);
    indicator.parameters:addBoolean("show" .. id, "Show Level " .. id, "", show);
    indicator.parameters:addColor("lcolor".. id, "Period Line Color", "", core.rgb(255, 128, 0));
    indicator.parameters:addInteger("lwidth".. id, "Period Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("lstyle".. id, "Period Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("lstyle".. id, core.FLAG_LINE_STYLE);
    indicator.parameters:addColor("ecolor".. id, "Extension Line Color", "", core.rgb(255, 128, 0));
    indicator.parameters:addInteger("ewidth".. id, "Extension Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("estyle".. id, "Extension Line Style", "", core.LINE_DOT);
    indicator.parameters:setFlag("estyle".. id, core.FLAG_LINE_STYLE);
	
end

-- set from and to dates
function SetData(from, to)
    dateFrom = from;
    dateTo = to;
    if dateFrom > dateTo then
        local t;
        t = dateTo;
        dateTo = dateFrom;
        dateFrom = t;
    end

    -- remove all data
    core.host:execute("removeAll");

    local pfrom, pto;
    pfrom = core.findDate(source, dateFrom, false);
    if pfrom < source:first() then
        pfrom = source:first();
    end
    pto = core.findDate(source, dateTo, false);
    if pto < 0 then
        pto = source:size() - 1;
    end

    if pfrom > pto then
        return ;
    end

    l, h = core.minmax(source, core.range(pfrom, pto));
    d = h - l;

    for i = 1, 14, 1 do
        if levels[i].show then
            p = l + levels[i].price * d;
            core.host:execute("drawLine", i, dateFrom, p, dateTo, p,lcolor[i],  lstyle[i],  lwidth[i],string.format(format, levels[i].price, p));
            core.host:execute("drawLine", i + 100, dateTo, p, source:date(source:size() - 1) + barSize * 100, p,ecolor[i], estyle[i], ewidth[i],string.format(format, levels[i].price, p));
        end
    end
end

-- save dates to database
function SaveDates()
    -- saves date value in the database
    db:put(dateFromDBName, tostring(dateFrom));
    db:put(dateToDBName, tostring(dateTo));
end


-- parse command message (date and price level)
local pattern = "([^;]*);([^;]*)";

function Parse(message)
    local level, date, period;
    level, date = string.match(message, pattern, 0);
    if level == nil then
        return nil;
    end
    return tonumber(date);
end
