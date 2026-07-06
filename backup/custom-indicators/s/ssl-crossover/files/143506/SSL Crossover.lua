-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71487

--+------------------------------------------------------------------+
--|                               Copyright © 2019, Gehtsoft USA LLC | 
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

function Init()
    indicator:name("SSL Crossover");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

 
	indicator.parameters:addBoolean("showEntry", "Show Entry", "", true);
	indicator.parameters:addBoolean("showTrend", "Show Trend", "", true); 
	
    indicator.parameters:addInteger("sslLen", "Number of periods", "The number of periods.", 10, 2, 1000);
	
	indicator.parameters:addString("maType", "Method", "", "MVA");
    indicator.parameters:addStringAlternative("maType", "MVA", "", "MVA");
    indicator.parameters:addStringAlternative("maType", "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("maType", "Wilder", "", "Wilder");
    indicator.parameters:addStringAlternative("maType", "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("maType", "SineWMA", "", "SineWMA");
    indicator.parameters:addStringAlternative("maType", "TriMA", "", "TriMA");
    indicator.parameters:addStringAlternative("maType", "LSMA", "", "LSMA");
    indicator.parameters:addStringAlternative("maType", "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("maType", "HMA", "", "HMA");
    indicator.parameters:addStringAlternative("maType", "ZeroLagEMA", "", "ZeroLagEMA");
    indicator.parameters:addStringAlternative("maType", "DEMA", "", "DEMA");
    indicator.parameters:addStringAlternative("maType", "T3", "", "T3");
    indicator.parameters:addStringAlternative("maType", "ITrend", "", "ITrend");
    indicator.parameters:addStringAlternative("maType", "Median", "", "Median");
    indicator.parameters:addStringAlternative("maType", "GeoMean", "", "GeoMean");
    indicator.parameters:addStringAlternative("maType", "REMA", "", "REMA");
    indicator.parameters:addStringAlternative("maType", "ILRS", "", "ILRS");
    indicator.parameters:addStringAlternative("maType", "IE/2", "", "IE/2");
    indicator.parameters:addStringAlternative("maType", "TriMAgen", "", "TriMAgen");
    indicator.parameters:addStringAlternative("maType", "JSmooth", "", "JSmooth");
    indicator.parameters:addStringAlternative("maType", "KAMA", "", "KAMA");
    indicator.parameters:addStringAlternative("maType", "ARSI", "", "ARSI");
    indicator.parameters:addStringAlternative("maType", "VIDYA", "", "VIDYA");
    indicator.parameters:addStringAlternative("maType", "HPF", "", "HPF");
    indicator.parameters:addStringAlternative("maType", "VAMA", "", "VAMA");
 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("Up", "Top Line Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Down", "Bottom Line Color", "", core.rgb(255, 0, 0));	
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
    indicator.parameters:addInteger("Transparency", "Transparency", "", 40,0,100);	
	
	indicator.parameters:addInteger("Size", "Arrow Size","", 15); 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local sslLen,maType; 
local first;
local source = nil;
local Bottom, Top; 
local maHigh, maLow; 
local Hlv;
local Transparency;
local   showEntry ,showTrend;
local up, down;
local Size;
local Shift;
-- Routine
 function Prepare(nameOnly)   
 
    Transparency= instance.parameters.Transparency;
    Transparency= 100-Transparency; 
    sslLen= instance.parameters.sslLen;
    maType= instance.parameters.maType; 
	showEntry= instance.parameters.showEntry;
	showTrend= instance.parameters.showTrend; 
	Size= instance.parameters.Size;
	
	local Parameters= sslLen..", "..maType;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    assert(core.indicators:findIndicator("AVERAGES") ~= nil, "Please, download and install AVERAGES.LUA indicator");  
			
    source = instance.source;  
	
	maHigh = core.indicators:create("AVERAGES", source.high, maType, sslLen  );
    maLow = core.indicators:create("AVERAGES", source.low,  maType, sslLen);  
	
    first=maLow.DATA:first() ;
	  
	Trend= instance:addInternalStream(0, 0);
   
 
	Top = instance:addStream("Top" , core.Line, " Top"," Top",instance.parameters.Up, first );
	Top:setWidth(instance.parameters.width);
    Top:setStyle(instance.parameters.style);
    Top:setPrecision(math.max(2, source:getPrecision()));

	Bottom = instance:addStream("Bottom" , core.Line, " Bottom"," Bottom",instance.parameters.Down, first );
	Bottom:setWidth(instance.parameters.width);
    Bottom:setStyle(instance.parameters.style);
    Bottom:setPrecision(math.max(2, source:getPrecision()));	
	
	if showTrend then
	instance:createChannelGroup("Group","Group" , Top, Bottom, instance.parameters.Up, Transparency);
	end
	
	if showEntry then
	up = instance:createTextOutput ("Up", "Up", "Wingdings", Size, core.H_Center,core.V_Bottom , instance.parameters.Up, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.Down, 0);
	end
end

-- Indicator calculation routine
function Update(period, mode)

    maHigh:update(mode);
    maLow:update(mode);
	
 
	if period < first
	then
	return;
	end
 
	  if source.close[period] > maHigh.DATA[period] then
	  Trend[period]=1;	  
      elseif source.close[period] < maLow.DATA[period] then
	  Trend[period]=-1;	
      else
	  Trend[period]= Trend[period-1];		  
	  end
 
 
    if Trend[period] > 0 then
	Top[period]=maHigh.DATA[period];
	Bottom[period]=maLow.DATA[period];
		if showTrend then
		Top:setColor(period, instance.parameters.Up);
		Bottom:setColor(period, instance.parameters.Up);	
		end
	else
	Top[period]=maLow.DATA[period];
	Bottom[period]=maHigh.DATA[period];
		if showTrend then	
		Top:setColor(period, instance.parameters.Down);
		Bottom:setColor(period, instance.parameters.Down);	
		end
	end
	
	up:setNoData(period);
	down:setNoData(period);
	
	Shift= math.abs(Top[period-1]-Bottom[period-1]);
	
	if Trend[period] > 0 and Trend[period-1]< 0 then
	up:set(period, source.low[period]-Shift, "\217" );
	elseif Trend[period]< 0 and Trend[period-1]> 0 then
	down:set(period, source.high[period]+Shift, "\218" );
	end
	
end
  