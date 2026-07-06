-- Id: 7607
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=24131

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
    indicator:name("Pearson product-moment correlation coefficient");
    indicator:description("Pearson product-moment correlation coefficient");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
    indicator.parameters:addGroup("Calculation"); 	 
    indicator.parameters:addInteger("Period", "Period", "Period", 50);
	--indicator.parameters:addString("BS", "Bar Size to display High/Low", "", "D1");
	--indicator.parameters:setFlag("BS", core.FLAG_PERIODS);
	
	
	 indicator.parameters:addString("SymbolX", "The instrument X", "", "EUR/USD");
    indicator.parameters:setFlag("SymbolX", core.FLAG_INSTRUMENTS);
	 indicator.parameters:addString("Price1", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price1", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price1", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price1", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price1","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price1", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price1", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price1", "WEIGHTED", "", "weighted");	
	
	
	indicator.parameters:addString("SymbolY", "The instrument Y", "", "USD/JPY");
    indicator.parameters:setFlag("SymbolY", core.FLAG_INSTRUMENTS);
	indicator.parameters:addString("Price2", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price2", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price2", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price2", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price2","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price2", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price2", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price2", "WEIGHTED", "", "weighted");	
	
	
	
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("PPMCC_color", "PPMCC Line Color", "", core.rgb(255, 0, 0));
	 indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
	local Period;
	local first;
	local source = nil;
	--local BS;
	local host;
	local offset;
	local weekoffset;
	 
	 local Price1, Price2;
-- Streams block
    local PMCC = nil;
    local SymbolX, SymbolY;
    local AB, C,D;
	local SourceData={};
    local loading={};
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
    source = instance.source;
    first = source:first();
    SymbolX = instance.parameters.SymbolX;
	SymbolY = instance.parameters.SymbolY;
	Price1 = instance.parameters.Price1;
	Price2 = instance.parameters.Price2;
	 host = core.host;
    offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");
		
	
    local name = profile:id() .. "(" .. source:name() --[[.. ", " .. tostring(BS)]].. ", " .. tostring(SymbolX).. ", " .. tostring(Price1).. ", " .. tostring(SymbolY).. ", " .. tostring(Price2).. ", " .. tostring(Period) .. ")";
    instance:name(name);

    if (not (nameOnly)) then
		SourceData[1] = core.host:execute("getSyncHistory", SymbolX, source:barSize(), source:isBid(), math.min(300,Period*2), 201, 101);
		loading[1]=true;
		SourceData[2] = core.host:execute("getSyncHistory", SymbolY, source:barSize(), source:isBid(), math.min(300,Period*2), 202, 102);
		loading[2]=true;
		
		AB= instance:addInternalStream(first, 0);
		C= instance:addInternalStream(first, 0);
		D= instance:addInternalStream(first, 0);

        PPMCC = instance:addStream("PPMCC", core.Line, name, "PPMCC", instance.parameters.PPMCC_color, first+Period*2);
    PPMCC:setPrecision(math.max(2, instance.source:getPrecision()));
		PPMCC:setWidth(instance.parameters.width);
        PPMCC:setStyle(instance.parameters.style);
    end
end


function   Initialization(period)

    local Candle;
   
    Candle = core.getcandle(source:barSize(), source:date(period), offset, weekoffset);
  
    if loading[1]or loading[2] or SourceData[1]:size() == 0 or  SourceData[2]:size() == 0 then
        return false,false ;
    end

    
    if period < source:first() then
        return false,false;
    end

    local p1 = core.findDate(SourceData[1], Candle, false);
	local p2 = core.findDate(SourceData[2], Candle, false);

    -- candle is not found
    if p1 < 0 or p2 < 0  then
        return false ,false ;
	else return p1, p2;	
    end
	
end	

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)

        local p1, p2 =  Initialization(period) 
     
	    if not p1 or not p2 
		or p1 < Period or p2< Period 
		or loading[1] or loading[2]
		then
		return;
		end
		   
    
	    if not SourceData[1]:hasData(p1)  or not  SourceData[2]:hasData(p2) 
		or  not SourceData[1]:hasData(p1-Period+1)  or not  SourceData[2]:hasData(p2-Period+1) 
		then
		return;
		end
		
		 AVG1=mathex.avg (SourceData[1][Price1], p1-Period+1, p1);
		 AVG2=mathex.avg (SourceData[2][Price2], p2-Period+1, p2);   
       	 
		local  A = (SourceData[1][Price1][p1]- AVG1); 
		local  B  =  (SourceData[2][Price2][p2]- AVG2);
		AB[period] = A*B;
		 
		 C[period]	= A^2;
		 D[period] = B^2;		 
		 
		
		 if period < Period*2 then
		 return;
		 end
		 local Numerator = mathex.sum(AB, period-Period+1, period);
		 
		 local  DenominatorC = mathex.sum(C, period-Period+1, period);
		 local  DenominatorD = mathex.sum(D, period-Period+1, period); 
		 local Denominator =  ((DenominatorC)^(1/2))* ((DenominatorD)^(1/2))
		
		PPMCC[period]= Numerator/Denominator;
  
end

-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    if cookie == 201  then
        loading[1] = false;
         
	elseif cookie == 202  then
        loading[2] = false;
       
    elseif cookie == 101 then
        loading[1] = true;
	elseif cookie == 102 then
        loading[2] = true;	
    end
	
	if not loading[2] and loading[1] then
	 instance:updateFrom(0);	
	 end
	 
	  return core.ASYNC_REDRAW;
end


