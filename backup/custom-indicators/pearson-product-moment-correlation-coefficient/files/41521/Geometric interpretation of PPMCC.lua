-- Id: 7611
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
    indicator:name("Geometric interpretation of Pearson product-moment correlation coefficient");
    indicator:description("Geometric interpretation of Pearson product-moment correlation coefficient");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
    indicator.parameters:addGroup("Calculation"); 	 
    indicator.parameters:addInteger("Period", "Period", "Period", 50);
	--indicator.parameters:addString("BS", "Bar Size to display High/Low", "", "D1");
	--indicator.parameters:setFlag("BS", core.FLAG_PERIODS);
	
	
	indicator.parameters:addString("SymbolX", "The instrument X", "", "");
    indicator.parameters:setFlag("SymbolX", core.FLAG_INSTRUMENTS);
	 indicator.parameters:addString("Price1", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price1", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price1", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price1", "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price1","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price1", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price1", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price1", "WEIGHTED", "", "weighted");	
	
	
	indicator.parameters:addString("SymbolY", "The instrument Y", "", "");
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
    indicator.parameters:addColor("Color", "Label  Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("Size", "Label Size", "", 10);
	 
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
	local SourceData1,SourceData2;
	local loading ={};   
	 local Price1, Price2;
-- Streams block
    local font1, font2;
    local SymbolX, SymbolY;
    local Size, Color;
	local AB,C,D;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
	Size = instance.parameters.Size;
	Color = instance.parameters.Color;
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
		SourceData1 = core.host:execute("getSyncHistory", SymbolX, source:barSize(), source:isBid(), math.min(300,Period*2), 201, 101);
		loading[1]=true;
		SourceData2 = core.host:execute("getSyncHistory", SymbolY, source:barSize(), source:isBid(), math.min(300,Period*2), 202, 102);
		loading[2]=true;
		AB= instance:addInternalStream(first, 0);
		C= instance:addInternalStream(first, 0);
		D= instance:addInternalStream(first, 0);
		font1 = core.host:execute("createFont", "Wingdings", Size, false, false);
		font2 = core.host:execute("createFont", "Courier", Size*2, true, false);

    end
end


function   Initialization(period)

    local Candle;
   
    Candle = core.getcandle(source:barSize(), source:date(period), offset, weekoffset);
  
    if loading[1]or loading[2] or SourceData1:size() == 0 or  SourceData2:size() == 0 then
        return false,false ;
    end

    
    if period < source:first() then
        return false,false;
    end

    local p1 = core.findDate(SourceData1, Candle, false);
	local p2 = core.findDate(SourceData2, Candle, false);

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
     
	    if not p1 or not p2 or p1 < Period or p2< Period then
		return;
		end
		   
    
	    if SourceData1:hasData(p1)  and SourceData2:hasData(p2)  then
		
		 local  Xavg=mathex.avg (SourceData1[Price1], p1-Period+1, p1);
		 local  Yavg=mathex.avg (SourceData2[Price2], p2-Period+1, p2); 
		 local  Sx =mathex.stdev (SourceData1[Price1], p1-Period+1, p1); 
		 local  Sy=mathex.stdev (SourceData2[Price2], p2-Period+1, p2); 
		 
		 local Zx	= ( (SourceData1[Price1][p1]- Xavg)/ Sx)*20;
		 local Zy =   ((SourceData2[Price2][p2]- Yavg)/ Sy)*20; 
		 
		 
		 local  A = (SourceData1[Price1][p1]- Xavg); 
		 local  B  =  (SourceData2[Price2][p2]- Yavg);
		 AB[period] = A*B;
		 
		 C[period]	= A^2;
		 D[period] = B^2;	

		 if period > first+Period*2 then
         local Numerator = mathex.sum(AB, period-Period+1, period);		 
		 local  DenominatorC = mathex.sum(C, period-Period+1, period);
		 local  DenominatorD = mathex.sum(D, period-Period+1, period); 		 
		 local Denominator =  ((DenominatorC)^(1/2))* ((DenominatorD)^(1/2))		
		 local PPMCC= Numerator/Denominator;
		   core.host:execute("drawLabel1", 1, 0, core.CR_RIGHT, 0, core.CR_TOP, core.H_Left, core.V_Bottom, font2, Color,   tostring( "Correlation Coefficient is :" .." "..string.format("%." .. 2 .. "f", PPMCC)));
		  local Label;
		    if PPMCC > -0.3 and PPMCC < 0.3 then
			Label="Two Streams Do not Correlate";
		    elseif  PPMCC >= -0.3 and PPMCC < 0 then
		    Label= "Two Streams have Weak Negativ Correlation";
			elseif  PPMCC >= 0 and PPMCC < 0.3 then
		    Label= "Two Streams have Weak Positive Correlation";
			elseif  PPMCC >= -0.30 and PPMCC < -0.5 then
			Label= "Two Streams have Moderate Negativ Correlation";
			elseif  PPMCC >= 0.3 and PPMCC < 0.5 then
			Label= "Two Streams have Moderate Positive Correlation";
			elseif PPMCC <= -0.5 then 
			Label= "Two Streams have Strong Negativ Correlation";
			elseif PPMCC >= 0.5 then
			Label= "Two Streams have Strong Positive Correlation";
			end 

		  core.host:execute("drawLabel1", 2, 0, core.CR_RIGHT, 2*Size, core.CR_TOP, core.H_Left, core.V_Bottom, font2, Color,   tostring( Label));
		 end
		 
		
		 
		core.host:execute("drawLabel1", source:serial(period), Zx, core.CR_CENTER, -Zy, core.CR_CENTER, core.H_Center, core.V_Center,  font1, Color, "\158");		 
		end
		
		 
	
  
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

function ReleaseInstance()
  core.host:execute("deleteFont", font1);
  core.host:execute("deleteFont", font2);  
end



