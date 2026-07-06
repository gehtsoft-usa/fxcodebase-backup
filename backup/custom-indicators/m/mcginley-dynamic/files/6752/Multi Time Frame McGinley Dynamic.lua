-- Id: 20325
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2950

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
    indicator:name("McGinley Dynamic");
    indicator:description("McGinley Dynamic");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation"); 
	indicator.parameters:addString("TF1", "Time Frame ", "", "H1");
    indicator.parameters:setFlag("TF1", core.FLAG_PERIODS);
	indicator.parameters:addString("TF2", "Time Frame ", "", "H4");
    indicator.parameters:setFlag("TF2", core.FLAG_PERIODS);
	indicator.parameters:addString("TF3", "Time Frame ", "", "D1");
    indicator.parameters:setFlag("TF3", core.FLAG_PERIODS);
	
    indicator.parameters:addInteger("Frame", "Period", "", 9, 2, 2000);
	indicator.parameters:addInteger("Smoothing", "Smoothing", "", 125, 1, 2000);
	
	
	indicator.parameters:addGroup("1. Line Style"); 
	indicator.parameters:addInteger("width1", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Style", " ", core.LINE_SOLID);
    indicator.parameters:addColor("color1", "Line Color", "", core.rgb(255, 0, 0));
	
	indicator.parameters:addGroup("2. Line Style"); 
	indicator.parameters:addInteger("width2", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Style", " ", core.LINE_SOLID);
    indicator.parameters:addColor("color2", "Line Color", "", core.rgb(0, 255, 0));
	
	
	indicator.parameters:addGroup("3. Line Style"); 
	indicator.parameters:addInteger("width3", "Line Width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Style", " ", core.LINE_SOLID);
    indicator.parameters:addColor("color3", "Line Color", "", core.rgb(0, 0, 255));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Frame;
local Smoothing;

local first;
local source = nil;

-- Streams block
local Indicator={};
local Line={}; 
local TF={};
local SourceData={};
local loading = {};  

local dayoffset, weekoffset;
-- Routine
function Prepare(nameOnly)
    Frame = instance.parameters.Frame;
	Smoothing= instance.parameters.Smoothing;
    source = instance.source;
	first=source:first();
	
	dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");
	
	TF[1]= instance.parameters.TF1;
	TF[2]= instance.parameters.TF2;
	TF[3]= instance.parameters.TF3;
	
	 local s1, e1, s2, e2;
    s1, e1 = core.getcandle(source:barSize(),0, 0, 0);
    s2, e2 = core.getcandle(TF[1], 0, 0, 0);
    assert ((e1 - s1) <= (e2 - s2), "1. Line time frame must be equal to or bigger than the chart time frame!");
	
	s2, e2 = core.getcandle(TF[2], 0, 0, 0);
    assert ((e1 - s1) <= (e2 - s2), "2. Line time frame must be equal to or bigger than the chart time frame!");
	
	s2, e2 = core.getcandle(TF[3], 0, 0, 0);
    assert ((e1 - s1) <= (e2 - s2), "3. Line time frame must be equal to or bigger than the chart time frame!");
	
	assert(core.indicators:findIndicator("MCGD") ~= nil, "Please, download and install MCGD.LUA indicator");
    local name = profile:id() .. "(" .. source:name() .. ", " .. Frame .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	local Test = core.indicators:create("MCGD", source.close , Frame,Smoothing);   
	FIRS= Test.DATA:first() ; 		
	
	
	
	for i= 1, 3, 1 do
	SourceData[i] = core.host:execute("getSyncHistory", source:instrument(), TF[i], source:isBid(), FIRS, 200+i, 100+i);
	loading[i]=true;
	
    Indicator[i] = core.indicators:create("MCGD", SourceData[i].close, Frame,Smoothing);		
	end
    Line[1] = instance:addStream("MCGD1", core.Line, name, "1. MCGD", instance.parameters.color1, source:first());
	Line[1] :setWidth(instance.parameters.width1);
	Line[1] :setStyle(instance.parameters.style1);
	
	Line[2] = instance:addStream("MCGD2", core.Line, name, "2. MCGD", instance.parameters.color2, source:first());
	Line[2] :setWidth(instance.parameters.width2);
	Line[2] :setStyle(instance.parameters.style2);
	
	Line[3] = instance:addStream("MCGD3", core.Line, name, "3. MCGD", instance.parameters.color3, source:first());
	Line[3] :setWidth(instance.parameters.width3);
	Line[3] :setStyle(instance.parameters.style3);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)
    if period < first or not  source:hasData(period) then
	return;
	end
	
	local p;
	
	for i= 1, 3, 1 do
	Indicator[i]:update(mode); 
	
	p=Initialization(i,period);
	
		if p~= false and Indicator[i].DATA:hasData(p) then
		Line[i][period]=Indicator[i].DATA[p];
		end
	
	end
    
end



function   Initialization(id,period)

    local Candle;
    Candle = core.getcandle(TF[id], source:date(period), dayoffset, weekoffset);

  
    if loading[id] or SourceData[id]:size() == 0 then
        return false ;
    end

    
    if period < source:first() then
        return false;
    end

    local p = core.findDate(SourceData[id], Candle, false);

    -- candle is not found
    if p < 0 then
        return false;
	else return p;	
    end
	
end	


-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)


   for i= 1, 3, 1 do
	   if cookie == 100+i then
	   loading[i] = true;
	   end
	   if cookie == 200+i then
	   loading[i] = false;
	   end
   end
   
   if not loading[1] and  not loading[2]  and not loading[3] then
   instance:updateFrom(0);
   end


    return core.ASYNC_REDRAW ;
	
end