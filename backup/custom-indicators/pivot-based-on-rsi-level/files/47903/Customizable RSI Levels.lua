
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=27380

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
    indicator:name("Customizable Waddah Attar RSI Levels");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
    indicator.parameters:addGroup("Calculation"); 	 
    indicator.parameters:addInteger("Period", "EMA Period", "EMA Period", 14);
	indicator.parameters:addDouble("Multiplier", "Multiplier", "Multiplier", 10);
	indicator.parameters:addString("BS", "Bar Size to display High/Low", "", "D1");
	indicator.parameters:setFlag("BS", core.FLAG_PERIODS);
	
	indicator.parameters:addBoolean("Historical", "Show historical lines" , "", false);  
	
	indicator.parameters:addGroup("Style"); 
	indicator.parameters:addInteger("FontSize", "Font size", "", 10);
	
	Add (1, core.rgb(0, 255, 0)); 
	Add (2, core.rgb(0, 255, 0));
	Add (3, core.rgb(0, 255, 0));
	Add (4, core.rgb(0, 255, 0));	
	Add (5, core.rgb(0, 255, 0));
	
	Add (6, core.rgb(0, 0, 255));
	
	Add (7, core.rgb(255, 0, 0));	
	Add (8, core.rgb(255, 0, 0));
	Add (9, core.rgb(255, 0, 0));
	Add (10, core.rgb(255, 0, 0));	
	Add (11, core.rgb(255, 0, 0));
	
end


function Add (id, color) 
  indicator.parameters:addGroup(id .. "Line"); 
   indicator.parameters:addBoolean("Show"..id, "Show " .. id.. ". Level" , "", true);  
    indicator.parameters:addInteger("Level"..id, id.. ". Level" , "", id);  
    indicator.parameters:addColor("color".. id , "Line Color", "", color);
	 indicator.parameters:addInteger("style" ..id , "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style"..id, core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width"..id, "Line Width", "", 1, 1, 5);
	
	end
-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
	local Period;
	local first;
	local source = nil;
	local BS;
	local host;
	local offset;
	local weekoffset;
	local SourceData;
	local loading = false;   
	local Indicator;
-- Streams block
    local RSI ={};
	local Multiplier;
	local Label;
	local Size;
	local L={};
	local color={};
	local style={};
	local width={};
	local Show={};
	local Level={};
	local Historical;
	
-- Routine
function Prepare(nameOnly) 
    Period = instance.parameters.Period;
	Multiplier= instance.parameters.Multiplier;
	Historical= instance.parameters.Historical;
    source = instance.source;
    first = source:first();
	
	local s, e ;
    s, e = core.getcandle(source:barSize(), core.now(), 0, 0);
	
	Size=e-s;
	
	
	host = core.host;
    offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");
    BS = instance.parameters.BS;
	
	
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period).. ", " .. tostring(BS) .. ")";
    instance:name(name);

    if   (nameOnly) then
        return;
    end
	
	SourceData = core.host:execute("getSyncHistory", source:instrument(), BS, source:isBid(), Period, 100, 101);
	loading= true;
	
	    Indicator = core.indicators:create("RSI", SourceData.close, Period);
       
	   local i;
	   for i = 1, 11, 1 do
	   
	       Show[i]=instance.parameters:getBoolean("Show" .. i);
	       Level[i]=instance.parameters:getInteger("Level" .. i);
	       if Show [i]   then
	        color[i]=instance.parameters:getInteger("color" .. i);
	        width[i]=instance.parameters:getInteger("width" .. i);
			style[i]=instance.parameters:getInteger("style" .. i);	   
			RSI[i] = instance:addStream("RSI".. i, core.Line, name, "RSI".. i, color[i], first);
			RSI[i]:setWidth( width[i]);
			RSI[i]:setStyle( style[i]);
			else
			RSI[i]= instance:addInternalStream(first, 0);
			end
		end
    
end


function   Initialization(period)

    local Candle;
    Candle = core.getcandle(BS, source:date(period), offset, weekoffset);

  
    if loading or SourceData:size() == 0 then
        return false ;
    end

    
    if period < source:first() then
        return false;
    end

    local p = core.findDate(SourceData, Candle, false);

    -- candle is not found
    if p < 0 then
        return false;
	else return p;	
    end
	
end	

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

        local p0 =  Initialization(period) ;		
		
	    if not p0 then
		return;
		end
		
		if not Historical and p0 ~= SourceData:size()-1 then
		return;
		end
		
		local p1= p0-1;
		local p2= p1-1;	
	
	   Indicator:update(mode); 	
	   
	 
    
	    if not  Indicator.DATA:hasData(p0) 	
		or not  Indicator.DATA:hasData(p1) 	
		or not  Indicator.DATA:hasData(p2)
		then		
		return;
		end
		
		local rsi1 = Indicator.DATA[p1];
		local rsi2 = Indicator.DATA[p2];
		
		local c1=SourceData.close[p1];
		local c2=SourceData.close[p2];
		
		local  drsi = rsi1 - rsi2;
		local   dc = c1 - c2;
		
		
		local i;
		
		
			for i = 1, 11, 1 do
			RSI[i][period] = ((((Level[i]*Multiplier) - rsi1)*dc) / drsi) + c1;
			end
		 
		 
		 
		 if period < source:size()-1 then
		 return;
		 end
		 
		 for i = 1, 11, 1 do
		 host:execute("drawLabel", i, source:date(period) + Size*5, RSI[i][period],  tostring( ((i-1)*Multiplier) .."   ("..string.format("%." .. source:getPrecision () .. "f", RSI[i][period])) .. ")" ); 
		 end
  
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    if cookie == 100 then
        loading = false;
        instance:updateFrom(0);
    elseif cookie == 101 then
        loading = true;
    end
end


