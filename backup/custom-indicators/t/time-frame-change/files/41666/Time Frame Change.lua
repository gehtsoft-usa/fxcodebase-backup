-- Id: 7621
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=24220

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Time Frame Change");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("BS", "Time frame", "", "D1");
    indicator.parameters:setFlag("BS", core.FLAG_PERIODS);
	
	indicator.parameters:addGroup("Positioning");
	indicator.parameters:addString("Positioning", "Positioning", "", "top-right");	
	indicator.parameters:addStringAlternative("Positioning", "top-left" , "", "top-left");
	indicator.parameters:addStringAlternative("Positioning", "bottom-left" , "", "bottom-left");
	indicator.parameters:addStringAlternative("Positioning", "top-right" , "", "top-right");
	indicator.parameters:addStringAlternative("Positioning", "bottom-right" , "", "bottom-right");
	indicator.parameters:addStringAlternative("Positioning", "center" , "", "center");
--	indicator.parameters:addStringAlternative("Positioning", "price" , "", "price"); 

	
	indicator.parameters:addGroup("Style");
   indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0)); 
   indicator.parameters:addInteger("Size", "Font Size", "", 20);
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;
local Placement;
local font;
local Label;
local Size;
local id;


local ref;
local instr;
local BS;
local BSLen;
local host;
local offset;
local weekoffset;
local O;
-- Routine
function Prepare(nameOnly)
    BS=instance.parameters.BS;
    Placement=instance.parameters.Positioning;      
    Label=instance.parameters.Label;
	Size=instance.parameters.Size;   
    source = instance.source;
   first=source:first();
	
	
	InitDay();
	
	id =1;	
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. BS .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
   	
   
	 font = core.host:execute("createFont", "Ariel", Size, true, false);
	
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values

function Update(period)   


if period < source:size()-1 then 
return;
end


     if not(CalcDay(period)) then
        return ;
    end
	
    
        local Percent = (source.close[period] - O[period]) / O[period] * 100;
    
        local Net = (source.close[period] - O[period]) / source:pipSize();
    
	
	id =0;
	Draw (1, "Time Frame : " ..tostring( BS) , 10, Size, Placement);
	Draw (2, "Net Change : " ..tostring( string.format("%." .. 2 .. "f", Net)) .. " Pips" , 10, Size, Placement);
	Draw (3, "Percent Change : "  ..tostring( string.format("%." .. 2 .. "f", Percent))  .." %"  , 10, Size, Placement) ;
	
    --    ID ,  Text (Integer or String), Horizontal Shift, Line Width, Placement Parameter
end

function Positioning (Poz)

    if Poz == "top-right" then
	return  core.CR_RIGHT,  core.CR_TOP, -1,1, core.H_Left, core.V_Bottom;
	
    elseif Poz == "top-left" then
	return core.CR_LEFT, core.CR_TOP, 1,1 , core.H_Right , core.V_Bottom;
	
    elseif Poz ==  "bottom-left" then
	return  core.CR_LEFT, core.CR_BOTTOM, 1,-1 ,core.H_Right, core.V_Bottom;
	
    elseif Poz == "bottom-right" then
	return    core.CR_RIGHT,  core.CR_BOTTOM , -1, -1 , core.H_Left , core.V_Bottom;
	
	elseif Poz ==  "center" then
	return  core.CR_CENTER, core.CR_CENTER, 1, 1, core.H_Left, core.V_Bottom;
	
	elseif Poz ==  "price"  then
	return  core.CR_CHART,  core.CR_CHART, 1, 1,core.H_Left, core.V_Bottom;
	
	else
	return -1;
	end
	                                      
	
  

end


function Draw (line, value , x, y, Pos)
 
    local  POZ={};
    POZ["X"] , POZ["Y"], POZ["x"] , POZ["y"], POZ["H"], POZ["V"] = Positioning (Pos );
	
	if POZ["X"] == -1 then
	core.host:execute("drawLabel1",id, -x, core.CR_RIGHT, y*line, core.CR_TOP, core.H_Left, core.V_Bottom,  font, Label,   "Incorrect positioning parameter"  );
	return;	
	end


	id = id+1;
    local X, Y;
	
    if Poz ==  "price" then
	X=source:date(x);
	Y=source.close[y];
	else
	X=POZ["x"] * x;
	Y=POZ["y"] * y *line;
    end

	local Out;
	
	if type(value) == "number" then
	Out = string.format("%." .. 2 .. "f",  value ) ;
	else
	Out = value; 
	end
	
	core.host:execute("drawLabel1",id,  X, POZ["X"], Y, POZ["Y"], POZ["H"], POZ["V"],  font, Label,   Out  );
	
end



function ReleaseInstance()
       core.host:execute("deleteFont", font);      
 end
 
 
 
function InitDay()
    host = core.host;
    offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");

    source = instance.source;
    instr = source:instrument();
   -- BS = "D1";

    -- validate
    local l1, l2;
    local s, e;

    s, e = core.getcandle(source:barSize(), core.now(), 0);
    l1 = e - s;
    s, e = core.getcandle(BS, core.now(), 0);
    l2 = e - s;
    BSLen = l2; -- remember length of the period

    --assert(l1 <= l2, "The source frame must be shorter or equal to the day timeframe");

    -- open price
    O = instance:addInternalStream(0, 0);
end


function CalcDay(period)
    -- get the previous's candle and load the ref data in case ref data does not exist
    local candle;
    candle = core.getcandle(BS, source:date(period), offset, weekoffset);

    -- if data for the specific candle are still loading
    -- then do nothing
    if loading and candle >= loadingFrom and (loadingTo == 0 or candle <= loadingTo) then
        return false;
    end

    -- if data is not loaded yet at all
    -- load the data
    if ref == nil then
        -- there is no data at all, load initial data
        local to, t;
        local from;
        if (source:isAlive()) then
            -- if the source is subscribed for updates
            -- then subscribe the current collection as well
            to = 0;
        else
            -- else load up to the last currently available date
            t, to = core.getcandle(BS, source:date(period), offset, weekoffset);
        end
        from = core.getcandle(BS, source:date(source:first()), offset, weekoffset);
        loading = true;
        O:setBookmark(1, period);
        loadingFrom = from;
        loadingTo = to;
        ref = host:execute("getHistory", 1, source:instrument(), BS, from, to, source:isBid());
        return false;
    end

    -- check whether the requested candle is before
    -- the reference collection start
    if (candle < ref:date(0)) then
        local from;
        O:setBookmark(1, period);
        if loading then
            return false;
        end
        loading = true;
        loadingFrom = candle;
        loadingTo = ref:date(0);
        host:execute("extendHistory", 1, ref, loadingFrom, loadingTo);
        return false;
    end

    -- check whether the requested candle is after
    -- the reference collection end
    if (not(source:isAlive()) and candle > ref:date(ref:size() - 1)) then
        O:setBookmark(1, period);
        if loading then
            return false;
        end
        loading = true;
        loadingFrom = ref:date(ref:size() - 1);
        loadingTo = candle;
        host:execute("extendHistory", 1, ref, loadingFrom, loadingTo);
        return false;
    end

    -- find the lastest completed period which is not saturday's period (to avoid
    -- collecting the saturday's data
    local pday = nil;
    pday = core.findDate (ref, candle, false);
    if pday ~= -1 then
        O[period] = ref.open[pday];
        return true;
    else
        return false;
    end
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    local period;

    pday = nil;
    period = O:getBookmark(1);

    if (period < 0) then
        period = 0;
    end
    loading = false;
    instance:updateFrom(period);
end
 