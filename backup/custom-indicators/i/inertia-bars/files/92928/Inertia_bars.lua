
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60367

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

function Init()
    indicator:name("Inertia bars indicator");
    indicator:description("Inertia_bars indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("Level", "Level (In pips or As Percentages)", "", 10);
	
	indicator.parameters:addString("Method", "Method", "Method" , "In_Pips");
    indicator.parameters:addStringAlternative("Method", "In Pips", "in Pips" , "In_Pips");
    indicator.parameters:addStringAlternative("Method", "As Percentages", "As Percentages" , "As_Percentages");
	
	
	indicator.parameters:addString("Type", "Presentation Method", "Presentation Method" , "Overlay");
    indicator.parameters:addStringAlternative("Type", "Overlay", "Overlay" , "Overlay");
    indicator.parameters:addStringAlternative("Type", "Sign", "Sign" , "Sign");
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrDefaultUp", "Default UP bar color", "Default UP bar color", core.COLOR_UPCANDLE);
    indicator.parameters:addColor("clrDefaultDn", "Default DN bar color", "Default DN bar color", core.COLOR_DOWNCANDLE);
    indicator.parameters:addColor("UPclr", "Up bar color (if Body>=Level)", "Up bar color (if Body>=Level)", core.rgb(0, 255, 0));    
    indicator.parameters:addColor("DNclr", "Dn bar color (if Body>=Level)", "Dn bar color (if Body>=Level)", core.rgb(255, 255, 0));    
	 indicator.parameters:addInteger("Size", "Font Size", "Font Size", 10);
end
local font;
local first;
local source = nil;
local Level;
local Method;
local Type;
local Size;
function Prepare(nameOnly)
    source = instance.source;
	Method=instance.parameters.Method;
	Size=instance.parameters.Size;
	Type=instance.parameters.Type;
	Level=instance.parameters.Level;
    

    first = source:first()+2;
    local name = profile:id() .. "(" .. source:name() .. ", " .. Level .. ", " ..  Method  .. ")";
    instance:name(name);
	
	
	if   (nameOnly) then
        return;
    end
	
	font = core.host:execute("createFont", "Wingdings", Size, false, false);
	
	if Type == "Overlay" then
    open = instance:addStream("open", core.Line, name, "open", core.rgb(0, 0, 0), first)
    high = instance:addStream("high", core.Line, name, "high", core.rgb(0, 0, 0), first)
    low = instance:addStream("low", core.Line, name, "low", core.rgb(0, 0, 0), first)
    close = instance:addStream("close", core.Line, name, "close", core.rgb(0, 0, 0), first)
    instance:createCandleGroup("ColorCandle", "", open, high, low, close); 
	end
	
end

function Update(period, mode)
    if (period<first) then
	return;
	end
	
	if Type == "Overlay" then
     open[period]=source.open[period];
     close[period]=source.close[period];
     high[period]=source.high[period];
     low[period]=source.low[period];
	end 
     
	 local Body;
	 local Value;
	 local Candle;
	 
	 if Method== "In_Pips" then	 
     Value=math.abs(source.close[period]-source.open[period])/source:pipSize();
	 else	
	 Body=math.abs(source.close[period]-source.open[period]);
	 Candle= math.abs(source.high[period]-source.low[period]);
	 Value=	 math.abs(Body/(Candle/100));
	 end
	 
	 
	 
	 if Type == "Overlay" then
	  
                  if source.close[period]>=source.open[period] then
			  if Value>=Level then
			   open:setColor(period, instance.parameters.UPclr);
			  else
			   open:setColor(period, instance.parameters.clrDefaultUp);
			  end
			 else
			  if Value>=Level then
			   open:setColor(period, instance.parameters.DNclr);
			  else
			   open:setColor(period, instance.parameters.clrDefaultDn);
			  end
			 end
	 else
	            core.host:execute ("removeLabel", source:serial(period))
				
	            if source.close[period]>=source.open[period] then
			  if Value>=Level then
			  core.host:execute("drawLabel1", source:serial(period), source:date(period), core.CR_CHART, source.low[period], core.CR_CHART, core.H_Center, core.V_Bottom, font, instance.parameters.UPclr, "\119");
			  end
			 else
			  if Value>=Level then
			  core.host:execute("drawLabel1", source:serial(period), source:date(period), core.CR_CHART, source.high[period], core.CR_CHART, core.H_Center, core.V_Top, font, instance.parameters.DNclr, "\119");
			  end
			 end
	 end
    
end
 function ReleaseInstance()
       core.host:execute("deleteFont", font);
end
