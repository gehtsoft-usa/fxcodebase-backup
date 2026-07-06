
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=68740

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
--

-- initializes the indicator
function Init()
    -- indicator:fail()
    indicator:name("Donchian Channel Trailing Stop ")
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
  
  
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "Number of periods", "", 20, 2, 10000);
    indicator.parameters:addString("AC", "Analyze the current period", "", "yes");
    indicator.parameters:addStringAlternative("AC", "no", "", "no");
    indicator.parameters:addStringAlternative("AC", "yes", "", "yes");
 
	
 
	
	
	indicator.parameters:addGroup("Line Style");
    indicator.parameters:addColor("color", "Line Coloe", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
    
 
	
	

end

local first = 0;
local n = 0;
local ac = true;
 
local source = nil;
local dn = nil;
local du = nil;


local Trend;
-- initializes the instance of the indicator
function Prepare(nameOnly) 
    source = instance.source;
    n = instance.parameters.N;
	
	
	 local name = profile:id() .. "(" .. source:name() .. "," .. n .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
    ac = (instance.parameters.AC == "yes");
   
 
	 
	
	Show=instance.parameters.Show;
	ShowLabel=instance.parameters.ShowLabel;

    first = n + source:first() - 1;
    if (not ac) then
        first = first + 1;
    end
   
    Line = instance:addStream("Line", core.Line, name .. ".Line", "Line", instance.parameters.color,  first)
	Line:setWidth(instance.parameters.width  );
    Line:setStyle(instance.parameters.style );
    dn= instance:addInternalStream(0, 0);
    du= instance:addInternalStream(0, 0);
    
    Trend= instance:addInternalStream(0, 0);
 
end


 

-- calculate the value
function Update(period)
    if (period< first) then
	return;
	end
    
 
 	
        if (ac) then
            dn[period], du[period] = mathex.minmax(source, period-n+1, period);
        else
            dn[period], du[period] = mathex.minmax(source, period-n+1-1, period-1);
        end		
   
	
	   
      if (ac) then
	  period=period-1;
	  else
	  period=period-2;
	  end
	  
	  if (period+1) <first then
	  return;
	  end
	  
	  if dn[period]> dn[period-1] 
	  then
	  Trend[period]=1;
	  elseif du[period]< du[period-1] 
	  then
	  Trend[period]=-1; 
	  else
	  Trend[period]=Trend[period-1]
	  end
	  
	  
	  if Trend[period] == 1 then
	  Line[period]=math.max(dn[period],Line[period-1]);
	  elseif Trend[period] == -1 then
	  Line[period]=math.min(du[period],Line[period-1]);
	  end
end

