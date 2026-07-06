-- More information about this indicator can be found at:
-- http://fxcodebase.com

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2021, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                              Support our efforts by donating   | 
--|                                                                 Paypal: https://goo.gl/9Rj74e  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

--Your donations will allow the service to continue onward.
--+------------------------------------------------------------------------------------------------+
--|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
--|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
--|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
--|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
--|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
--|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
--+------------------------------------------------------------------------------------------------+

function Init()
    indicator:name("Perfect Trend Line");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator); 

    indicator.parameters:addGroup("Calculation");
	indicator.parameters:addInteger("SlowLength", "Slow Length", "Slow Length", 7);
	indicator.parameters:addDouble("SlowPipDisplace", "Slow Pip Displace", "Slow PipD isplace", 0);
	indicator.parameters:addInteger("FastLength", "Fast Length", "Fast Length", 3);
	indicator.parameters:addDouble("FastPipDisplace", "Fast Pip Displace", "Fast PipD isplace", 0);
	
	indicator.parameters:addBoolean("Signal", "Signal Mode", "", false)

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("color1", "1. Line Color", "1. Line Color", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	
    indicator.parameters:addColor("color2", "2. Line Color", "2. Line Color", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	
	 indicator.parameters:addInteger("Size", "Alert Size", "Alert Size", 20);
	 
	 indicator.parameters:addColor("Up", "Up Alert Color", "Alert Color", core.rgb(0, 255, 0));
     indicator.parameters:addColor("Down", "Down Alert Color", "Alert Color", core.rgb(255, 0, 0));
end

local first;
local source = nil;
local trena;
local Signal; 
local SlowLength, SlowPipDisplace,FastLength, FastPipDisplace;
local AlertUp, AlertDown;
 

function Prepare(nameOnly)
    source = instance.source;
    
	
	SlowLength=instance.parameters.SlowLength;
	SlowPipDisplace=instance.parameters.SlowPipDisplace;
	FastLength=instance.parameters.FastLength;
	FastPipDisplace=instance.parameters.FastPipDisplace;
 
 
	
    first = source:first();
    local name = profile:id() .. "(" .. source:name()   .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
  
    trena= instance:addInternalStream(0, 0); 
	
   
	if instance.parameters.Signal then
	Signal = instance:addStream("Signal", core.Bar,  "Signal", "Signal", instance.parameters.color1, first);
		
	line1 = instance:addInternalStream(0, 0);
	line2 = instance:addInternalStream(0, 0);
	else	
	Signal = instance:addInternalStream(0, 0);
    line1 = instance:addStream("line1", core.Line,  "line1", "line1", instance.parameters.color1, first);
	line1:setWidth(instance.parameters.width1);
    line1:setStyle(instance.parameters.style1);
    line2 = instance:addStream("line2", core.Line, "line2", "line2", instance.parameters.color2, first);
	line2:setWidth(instance.parameters.width2);
    line2:setStyle(instance.parameters.style2);
	
	AlertUp = instance:createTextOutput ("AlertUp", "Alert Up", "Wingdings", instance.parameters.Size, core.H_Center,  core.V_Bottom, instance.parameters.Up, 0);
	AlertDown = instance:createTextOutput ("AlertDown", "Alert Down", "Wingdings", instance.parameters.Size, core.H_Center,  core.V_Top, instance.parameters.Down, 0);
	
    end
	

    
end

function Update(period, mode)
   
 
 if period < source:first() + math.max(SlowLength, FastLength) then
 return;
 end
 
 
 if  not instance.parameters.Signal  then
 AlertUp:setNoData(period);
 AlertDown:setNoData(period);
end 
 
 
 
min1, max1=mathex.minmax(source,period-SlowLength+1, period);
min2, max2=mathex.minmax(source,period-FastLength+1, period); 

local high1 = max1 + SlowPipDisplace*source:pipSize();
local low1  = min1- SlowPipDisplace*source:pipSize();
local high2 = max2+ FastPipDisplace*source:pipSize();
local low2  = min2- FastPipDisplace*source:pipSize();


 if source.close[period]>line1[period-1] then
  line1[period] = low1;
 else
  line1[period] = high1;
 end
 
 if source.close[period]>line2[period-1] then
  line2[period] = low2;
 else
  line2[period] = high2;
 end
 
 
local trend=0;

if (source.close[period]<line1[period] and source.close[period]<line2[period]) then
trend =  1;
end


if (source.close[period]>line1[period] and source.close[period]>line2[period]) then
trend = -1;
end

if (line1[period]>line2[period] or trend==1) then
trena[period]=1;
end

if (line1[period]<line2[period] or trend==-1) then
trena[period]=-1;
end

if not  instance.parameters.Signal then
	if trena[period]~=trena[period-1] then
	  if trena[period]==1 then
	  AlertDown:set(period, math.max(line1[period], line2[period]), "\108");
	  elseif trena[period]==-1 then  
	  AlertUp:set(period, math.min(line1[period], line2[period]), "\108");
	  end		 
	end 
else
    if trena[period]~=trena[period-1] then
	  if trena[period]==1 then
	  Signal[period]=-1;
	  elseif trena[period]==-1 then  
	  Signal[period]=1;
	  end		 
	end 
	


end

	

end

 