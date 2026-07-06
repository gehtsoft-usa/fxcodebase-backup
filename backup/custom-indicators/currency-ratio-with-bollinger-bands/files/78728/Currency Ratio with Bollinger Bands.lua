-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=51549
-- Id: 9519

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Currency Ratio with Bollinger Bands");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
    indicator.parameters:addGroup("Selection"); 	 
    indicator.parameters:addString("p1", "1. Instrumet", "", "");
    indicator.parameters:setFlag("p1", core.FLAG_INSTRUMENTS );
	
	indicator.parameters:addString("p2", "2. Instrumet", "", "");
    indicator.parameters:setFlag("p2", core.FLAG_INSTRUMENTS );
	
	
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addInteger("One", "Period", "", 14);
	indicator.parameters:addDouble("Two", "Standard Deviation", "", 2);
	
	indicator.parameters:addGroup("Style"); 

    indicator.parameters:addColor("Ratio_color", "Ratio Line Color", "", core.rgb(0, 255, 0));
	 indicator.parameters:addInteger("style0", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style0", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width0", "Line Width", "", 1, 1, 5);

	
    indicator.parameters:addColor("EMA_color", "MA Line Color", "", core.rgb(255, 0, 0));
	 indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 1, 1, 5);
	
	indicator.parameters:addGroup("Belt Style"); 
	 indicator.parameters:addBoolean("Show", "Show Belts", "", true);	
	 
	 indicator.parameters:addColor("Top", "TopLine Color", "", core.rgb(0, 0, 255));
	 indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 1, 1, 5);
	
	
	 indicator.parameters:addColor("Bottom", "Bottom Line Color", "", core.rgb(0, 0, 255));
	 indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 1, 1, 5);
 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
	
	local first;
	local source = nil;
	local BS;
	local host;
	local offset;
	local weekoffset;
	local SourceData={};
	local loading={};   
	local Indicator;
-- Streams block
    local EMA = nil;
    local Show;
	
local p1, p2;
local One, Two;
 local Top, Bottom;
 local Raw,Indicator;
-- Routine
function Prepare(nameOnly)
    
    source = instance.source;
    first = source:first();
	One = instance.parameters.One;
	Two = instance.parameters.Two;
	Show = instance.parameters.Show;
	p1 = instance.parameters.p1;
	p2  = instance.parameters.p2;	
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(p1).. ", " .. tostring(p2) .. ", " .. tostring(One).. ", " .. tostring(Two).. ")";
    instance:name(name);
	if nameOnly then
		return;
	end
	host = core.host;
    offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");
    BS = source:barSize();
	SourceData[1]=core.host:execute("getSyncHistory", p1, BS, source:isBid(), math.min(math.max(One, Two),300), 100, 101);
	SourceData[2]=core.host:execute("getSyncHistory", p2, BS, source:isBid(),  math.min(math.max(One, Two),300), 200, 201);
	loading[1]=true;	
	loading[2]=true;

  
		Raw = instance:addStream("RATIO", core.Line, name, "Ratio", instance.parameters.Ratio_color,  first);
		Raw:setWidth(instance.parameters.width0);
        Raw:setStyle(instance.parameters.style0);
		
		Indicator = core.indicators:create("EMA", Raw, One);
	
        EMA = instance:addStream("MA", core.Line, name, "MA", instance.parameters.EMA_color,  Indicator.DATA:first());
		EMA:setWidth(instance.parameters.width);
        EMA:setStyle(instance.parameters.style);
		
		
		
		if Show then
		Top = instance:addStream("TOP", core.Line, name, "Top", instance.parameters.Top,  Indicator.DATA:first() + One);
		Top:setWidth(instance.parameters.width1);
        Top:setStyle(instance.parameters.style1);
		
		Bottom = instance:addStream("BOTTOM", core.Line, name, "Bottom", instance.parameters.Bottom,  Indicator.DATA:first() + One);
		Bottom:setWidth(instance.parameters.width2);
        Bottom:setStyle(instance.parameters.style2);
		else
		
		 Top=instance:addInternalStream(0, 0);
		 Bottom=instance:addInternalStream(0, 0);
		end
		 
        Raw:setPrecision(math.max(2, instance.source:getPrecision()));
		EMA:setPrecision(math.max(2, instance.source:getPrecision()));
		Top:setPrecision(math.max(2, instance.source:getPrecision()));
		Bottom:setPrecision(math.max(2, instance.source:getPrecision()));
end


function   Initialization(period)

    local Candle;
    Candle = core.getcandle(BS, source:date(period), offset, weekoffset);

  
    if loading[1] or loading[2] or SourceData[1]:size() == 0  or SourceData[2]:size() == 0 then
        return false, false ;
    end

    
	
    if period < source:first() then
        return false, false;
    end

    local r1 = core.findDate(SourceData[1], Candle, false);
	local r2 = core.findDate(SourceData[2], Candle, false);

    -- candle is not found
    if r1 < 0 or r2 < 0 then
        return false, false;
	else return r1, r2;	
    end
	
end	

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)


        if loading[1] or loading[2] then
		return;
		end
		

        local r1,r2;
		r1,r2=  Initialization(period) 
		
	
     
	    if not r1 or not r2  then
		return;
		end		
		
		 
    
	    if  not SourceData[1].close:hasData(r1)  or not  SourceData[2].close:hasData(r2)
		
		then
		return;
		end
		
		
        Raw[period]= (SourceData[1].close[r1]/SourceData[2].close[r2]);
		
		Indicator:update(mode);
		
    	if period < Indicator.DATA:first()  then
		return;
		end
	
		
		
		EMA[period]= Indicator.DATA[period];
		
		if period < Indicator.DATA:first() + One then
		return;
		end
		
		
		local STD= mathex.stdev(EMA, period-One+1, period );
		
		Top[period]= EMA[period]+STD *Two;
		Bottom[period]=EMA[period]-STD*Two;
		
	 
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    if cookie == 100 then
        loading[1] = false;
        
    elseif cookie == 101 then
        loading[1] = true;
    end
	
	  if cookie == 200 then
        loading[2] = false;
        
    elseif cookie == 201 then
        loading[2] = true;
    end
	
	if not loading[1] and not loading[2] then
	instance:updateFrom(0);
	end
end


