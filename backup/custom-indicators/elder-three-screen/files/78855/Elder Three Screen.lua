-- Id: 9521
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=51669

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


-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Elder Three Screen");
    indicator:description("Elder Three Screen");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addString("Type", "Price Source", "", "Three");
    indicator.parameters:addStringAlternative("Type", "Use One Time Frame", "", "One");
    indicator.parameters:addStringAlternative("Type", "Use Two Time Frames", "", "Two");
    indicator.parameters:addStringAlternative("Type", "Use Three Time Frames", "", "Three");
	
	indicator.parameters:addBoolean("RESET", "Show sub consensus changes ", "", false);

	
	indicator.parameters:addGroup("1. Time Frame");
    indicator.parameters:addString("TF1", "Time frame", "", "H1");
    indicator.parameters:setFlag("TF1", core.FLAG_PERIODS);
    indicator.parameters:addInteger("Period1", " Period", "Period", 14);
	indicator.parameters:addString("Method1", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method1", "EMA", "EMA" , "EMA");
 indicator.parameters:addStringAlternative("Method1", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method1", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method1", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method1", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method1", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method1", "WMA", "WMA" , "WMA");


	indicator.parameters:addGroup("2. Time Frame");
    indicator.parameters:addString("TF2", "Time frame", "", "H8");
    indicator.parameters:setFlag("TF2", core.FLAG_PERIODS);
    indicator.parameters:addInteger("Period2", "Period", "Period", 14);
	indicator.parameters:addString("Method2", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method2", "EMA", "EMA" , "EMA");
 indicator.parameters:addStringAlternative("Method2", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method2", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method2", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method2", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method2", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method2", "WMA", "WMA" , "WMA");


	
	indicator.parameters:addGroup("3. Time Frame");
    indicator.parameters:addString("TF3", "Time frame", "", "D1");
    indicator.parameters:setFlag("TF3", core.FLAG_PERIODS);
    indicator.parameters:addInteger("Period3", "Period", "Period", 14);
	
	indicator.parameters:addString("Method3", "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method3", "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method3", "EMA", "EMA" , "EMA");
 indicator.parameters:addStringAlternative("Method3", "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method3", "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method3", "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method3", "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method3", "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method3", "WMA", "WMA" , "WMA");


	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Buy", "Buy Color", "Color of Buy", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Sell", "Sell Color", "Color of Sell", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral Color", "Color of Neutral", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("Size", "Font Size", "Font Size", 13);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries


-- Parameters block
local font;
local Type;
local offset,weekoffset;
local Period1;
local Period2;
local Period3;
local Method3, Method2,Method1;
local first;
local source = nil;
local Buy, Sell;
-- Streams bloTF
local TF1, TF2,TF3;
local  loading={};
local  SourceData={};
local p={};
local Indicator={};
local Size;
local RESET;
local SIGNAL;
local Neutral;
-- Routine
function Prepare(nameOnly)
    Buy = instance.parameters.Buy;
	Sell = instance.parameters.Sell;
    Neutral = instance.parameters.Neutral;	
	RESET = instance.parameters.RESET;
	Size = instance.parameters.Size;
    Period1 = instance.parameters.Period1;
    Period2 = instance.parameters.Period2;
    Period3 = instance.parameters.Period3;
	Method3 = instance.parameters.Method3;
	Method2 = instance.parameters.Method2;
	Method1 = instance.parameters.Method1;
	Type = instance.parameters.Type;
	TF1 = instance.parameters.TF1;
	TF2 = instance.parameters.TF2;
	TF3 = instance.parameters.TF3;
    source = instance.source;
    first = source:first();
	
	
	local name = profile:id() .. "(" .. source:name()  .. ", " .. tostring(Type)
	.. ", " ..tostring(TF1).. ", " .. tostring(Period1).. ", " .. tostring(Method1)
	.. ", " ..tostring(TF2).. ", " .. tostring(Period2) .. ", " .. tostring(Method2)
	.. ", " ..tostring(TF3).. ", " .. tostring(Period3).. ", " .. tostring(Method3)
	.. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	font = core.host:execute("createFont", "Wingdings", Size, false, false);

	
	 local s, e, s1, e1;
    s, e = core.getcandle(source:barSize(), core.now(), 0, 0);
	
    s1, e1 = core.getcandle(instance.parameters:getString("TF1"), core.now(), 0, 0);
    assert ((e - s) <= (e1 - s1), "1. Time Frame must be equal to or bigger than the Chart Time Frame!");
	
	s1, e1 = core.getcandle(instance.parameters:getString("TF2"), core.now(), 0, 0);
    assert ((e - s) <= (e1 - s1), "2. Time Frame must be equal to or bigger than the Chart Time Frame!");
	
	s1, e1 = core.getcandle(instance.parameters:getString("TF3"), core.now(), 0, 0);
    assert ((e - s) <= (e1 - s1), "3. Time Frame must be equal to or bigger than the Chart Time Frame!");
	
	offset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");

    
	
	SourceData[1] = core.host:execute("getSyncHistory",source:instrument(), TF1, source:isBid(), Period1, 200+1, 100+1);
	loading[1]=true;
	
	SourceData[2] = core.host:execute("getSyncHistory",source:instrument(), TF2, source:isBid(), Period2, 200+2, 100+2);
	loading[2]=true;
	
	SourceData[3] = core.host:execute("getSyncHistory",source:instrument(), TF3, source:isBid(), Period3, 200+3, 100+3);
	loading[3]=true;
	
    assert(core.indicators:findIndicator(Method1) ~= nil, Method1 .. " indicator must be installed");
	Indicator[1] = core.indicators:create(Method1, SourceData[1].close ,Period1);   
    assert(core.indicators:findIndicator(Method2) ~= nil, Method2 .. " indicator must be installed");
	Indicator[2] = core.indicators:create(Method2, SourceData[2].close ,Period2); 
    assert(core.indicators:findIndicator(Method3) ~= nil, Method3 .. " indicator must be installed");
	Indicator[3] = core.indicators:create(Method3, SourceData[3].close ,Period3); 
	
    SIGNAL = instance:addInternalStream(0, 0);
end



function   Initialization(period,id)

    local Candle;
    Candle = core.getcandle(source:barSize(), source:date(period), offset, weekoffset);
  
    if loading[id] or SourceData[id]:size() == 0  then
        return false;
    end

    
    if period < source:first() then
        return false;
    end

    local P = core.findDate(SourceData[id], Candle, false);
	 

    -- candle is not found
    if P < 0    then
        return false;
	else return P;	
    end
			
end	

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period < first  then
	return;
	end
	
	local Flag= false;
	
	for i= 1, 3, 1 do
	p[i]= Initialization(period,i)	
		if loading[i] or not p[i] then		
		Flag=true;
		end
	end
	


	Indicator[1]:update(mode);
	Indicator[2]:update(mode);
	Indicator[3]:update(mode);

	
	
	
	
	if Flag then
	return;
	end
	
	if p[1]<=1
	or p[2]<=1
	or p[3]<=1		
	then
	return;
	end
	
	if 	not Indicator[1].DATA:hasData(p[1]-1)
	or not Indicator[2].DATA:hasData(p[2]-1)
	or not Indicator[3].DATA:hasData(p[3]-1)
	or not Indicator[1].DATA:hasData(p[1])
	or not Indicator[2].DATA:hasData(p[2])
	or not Indicator[3].DATA:hasData(p[3])
	then
	return;
	end	
	
	
	
	 local BUY=false;
	 local SELL=false;
	
	--ONE
	if Indicator[1].DATA[p[1]] > Indicator[1].DATA[p[1]-1] then
	BUY=true;
	elseif Indicator[1].DATA[p[1]] < Indicator[1].DATA[p[1]-1] then
	SELL=true;
	end
	
	--TWO
	if Type== "Two"
	or Type== "Three"
	then
	     
		if Indicator[2].DATA[p[2]] < Indicator[2].DATA[p[2]-1] then
		BUY=false;
		elseif Indicator[2].DATA[p[2]] > Indicator[2].DATA[p[2]-1] then
		SELL= false;
		end	
	end
		
	--THREE
	if Type == "Three"
	then
			if Indicator[3].DATA[p[3]] < Indicator[3].DATA[p[3]-1] then
			BUY=false;
			elseif Indicator[3].DATA[p[3]] > Indicator[3].DATA[p[3]-1] then
			SELL= false;
			end	
	
	end
	
	if not RESET then
	SIGNAL[period]=SIGNAL[period-1];
	else
	SIGNAL[period]=0;
	end
	
	if BUY	
	then
	SIGNAL[period]=1;
		if SIGNAL[period-1]~= 1 then
		core.host:execute("drawLabel1",source:serial(period), source:date(period),core.CR_CHART, source.low[period], core.CR_CHART, core.H_Center, core.V_Bottom,
								 font, Buy, "\225");
		end						 
	elseif SELL
	then
	SIGNAL[period]=-1;
		if SIGNAL[period-1]~= -1 then
		core.host:execute("drawLabel1",source:serial(period), source:date(period),core.CR_CHART, source.high[period], core.CR_CHART, core.H_Center, core.V_Top,
								 font, Sell, "\226");
		end	
    elseif SIGNAL[period]==  0 then	
	
	    if SIGNAL[period-1]== 1 then
		core.host:execute("drawLabel1",source:serial(period), source:date(period),core.CR_CHART, source.high[period], core.CR_CHART, core.H_Center, core.V_Top,
								 font, Neutral, "\226");
		end	
		
		if SIGNAL[period-1]== -1 then
		core.host:execute("drawLabel1",source:serial(period), source:date(period),core.CR_CHART, source.low[period], core.CR_CHART, core.H_Center, core.V_Bottom,
								 font, Neutral, "\225");
		end	
 	
	end
	    
end




-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
     local j;	 
	local Flag = false;	
	local Count=0;	
	
	
	
    for j = 1, 3, 1 do
		
			  if cookie == (100 +j) then
			  loading[j] = true;
		      elseif  cookie == (200+j) then
			  loading[j] = false; 			 
              end
			  
		if loading[j] then
		Count=Count+1;
		Flag=true;
		end	 

		  
		if Flag then
		core.host:execute ("setStatus", " Loading ".. (3-Count) .."/" .. 3);
		else
		core.host:execute ("setStatus", " Loaded ".. (3-Count) .."/" .. 3);
		instance:updateFrom(0);
		end
			  
	end    
   
        
		return core.ASYNC_REDRAW ;
end

function ReleaseInstance()
 
 core.host:execute("deleteFont", font);

 
end




