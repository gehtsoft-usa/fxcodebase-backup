-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=67056
-- Id:  

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
    indicator:name("Corrected RSX");
    indicator:description("Corrected RSX");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("RSIperiod", "RSI Period", "", 15); 

    indicator.parameters:addGroup("RSX Line Style");
    indicator.parameters:addColor("Up1", "Up Line Color", "Line Color", core.rgb(0, 191, 255));
	indicator.parameters:addColor("Down1", "Down Line Color", "Line Color", core.rgb(255, 164, 96));
	indicator.parameters:addColor("Neutral1", "Neutral Line Color", "Line Color", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("width1", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "Line style", core.LINE_DASHDOT  );
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addGroup("RSX Line Style");
    indicator.parameters:addColor("Up2", "Up Line Color", "Line Color", core.rgb(0, 191, 255));
	indicator.parameters:addColor("Down2", "Down Line Color", "Line Color", core.rgb(255, 164, 96));
	indicator.parameters:addColor("Neutral2", "Neutral Line Color", "Line Color", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("width2", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "Line style",core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
 
end

local first;
local source = nil;
local RSIperiod; 
local Up1, Down1, Neutral1;
local Up2, Down2, Neutral2;
local RSX,CA;
local SA;
local smallRsiValue;
local f88;
 


 
 local f8;
 local f18;
 local f20; 
 local f90;
 
 
 local f10;
 local f0; 
 local v8;
 local f28;
 local f30;
 local vC;
 local f38;
 local f40;
 local v10;
 local f48;
 local f50;
 local v14;
 local f58;
 local f60;
 local v18;
 local  f68;
 
 local f70;
 local v1C;
 local f78;
 local f80;
 local v20;
 
 
 
function Prepare(nameOnly)
    
	
	source = instance.source;
	
    RSIperiod=instance.parameters.RSIperiod;
	--Len=instance.parameters.RSIperiod;
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.RSIperiod .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	
	first = source:first();
   
   -- SA = instance:addInternalStream(0, 0);
	  
	 f0 = instance:addInternalStream(0, 0);
	 f8 = instance:addInternalStream(0, 0);
 
     f20 = instance:addInternalStream(0, 0); 
     f90 = instance:addInternalStream(0, 0);
 
 
     f10 = instance:addInternalStream(0, 0);
  
	 v8 = instance:addInternalStream(0, 0);
	 f28 = instance:addInternalStream(0, 0);
	 f30 = instance:addInternalStream(0, 0);
	 vC = instance:addInternalStream(0, 0);
	 f38 = instance:addInternalStream(0, 0);
	 f40 = instance:addInternalStream(0, 0);
	 v10 = instance:addInternalStream(0, 0);
	 f48 = instance:addInternalStream(0, 0);
	 f50 = instance:addInternalStream(0, 0);
	 v14 = instance:addInternalStream(0, 0);
	 f58 = instance:addInternalStream(0, 0);
	 f60 = instance:addInternalStream(0, 0);
	 v18 = instance:addInternalStream(0, 0);
	 f68 = instance:addInternalStream(0, 0);
	 
	 f70 = instance:addInternalStream(0, 0);
	 v1C = instance:addInternalStream(0, 0);
	 f78 = instance:addInternalStream(0, 0);
	 f80 = instance:addInternalStream(0, 0);
	 v20 = instance:addInternalStream(0, 0);
	
	Up1=instance.parameters.Up1;
	Down1=instance.parameters.Down1;
	Neutral1=instance.parameters.Neutral1;
    Up2=instance.parameters.Up2;
	Down2=instance.parameters.Down2;
	Neutral2=instance.parameters.Neutral2;
  
	
    RSX = instance:addStream("RSX", core.Line, name .. ".RSX", "RSX",Up1, first);
    RSX:setWidth(instance.parameters.width1);
    RSX:setStyle(instance.parameters.style1);
    RSX:addLevel(30);
    RSX:addLevel(70);
	RSX:setPrecision(math.max(4, source:getPrecision()));
	
	
	CA = instance:addStream("CA", core.Line, name .. ".CA", "CA", Up2, first);
    CA:setWidth(instance.parameters.width2);
    CA:setStyle(instance.parameters.style2); 
	CA:setPrecision(math.max(4, source:getPrecision()));
	
	smallRsiValue = 0.0000000000000001
	
	if (RSIperiod-1 >= 5) then
	  f88 = RSIperiod-1.0
	 else
	  f88 = 5.0
 end 
 
    f18 = 3.0 / (RSIperiod + 2.0)
	f20 = 1.0 - f18;
end

function Update(period, mode)
 
	
   if (period<first) then
   return;
   end
    

 f0[period]=f0[period-1];

 
 
if (f90[period-1] == 0.0) then
 f90[period] = 1.0
 f0[period] = 0.0
 
 f8[period] = 100.0*(source[period])
 

else
 if (f88 <= f90[period-1]) then
  f90[period] = f88 + 1
 else
  f90[period] = f90[period-1] + 1
 end 
 
 f10[period] = f8[period-1]
 f8[period] = 100*source[period];
 v8[period] = f8[period] - f10[period]
 f28[period] = f20  * f28[period-1] + f18  * v8[period]
 f30[period] = f18  * f28[period] + f20  * f30[period-1]
 vC[period] = f28[period] * 1.5 - f30[period] * 0.5
 f38[period] = f20  * f38[period-1] + f18  * vC[period]
 f40[period] = f18  * f38[period] + f20  * f40[period-1]
 v10[period] = f38[period] * 1.5 - f40[period] * 0.5
 f48[period] = f20  * f48[period-1] + f18  * v10[period]
 f50[period] = f18  * f48[period] + f20  * f50[period-1]
 v14[period] = f48[period] * 1.5 - f50[period] * 0.5
 f58[period] = f20  * f58[period-1] + f18  * math.abs(v8[period])
 f60[period] = f18  * f58[period] + f20  * f60[period-1]
 v18[period] = f58[period] * 1.5 - f60[period] * 0.5
 f68[period] = f20  * f68[period-1] + f18  * v18[period]
 
 f70[period] = f18  * f68[period] + f20  * f70[period-1]
 v1C[period] = f68[period] * 1.5 - f70[period] * 0.5
 f78[period] = f20  * f78[period-1] + f18  * v1C[period]
 f80[period] = f18  * f78[period] + f20  * f80[period-1]
 v20[period] = f78[period] * 1.5 - f80[period] * 0.5
 
 if ((f88 >= f90[period]) and (f8[period] ~= f10[period])) then
  f0[period] = 1.0
 end
 if ((f88 == f90[period]) and (f0[period] == 0.0)) then
  f90[period] = 0.0
 end
end
 
 
if ((f88 < f90[period]) and (v20[period] > smallRsiValue)) then
 
 RSX[period] = (v14[period] / v20[period] + 1.0) * 50.0
	 if (RSX[period] > 100.0) then
	  RSX[period] = 100.0
	 end 
	 if (RSX[period] < 0.0) then
	  RSX[period] = 0.0
	 end 
else
 RSX[period] = 50.0
end
 
 
if period < RSIperiod then
return;
end
 
--Corrected function 
 local STD= mathex.stdev(RSX, period-RSIperiod+1, period) 
 local v1 =(STD)^2;
 local v2 = (CA[period-1]-RSX[period])^2;
 
 
 
 if(v2<v1) then
  k =0    
 else
  k =1-v1/v2 
 end
 
 
  
   CA[period]=CA[period-1]+k*(RSX[period]-CA[period-1])
  
  
--final cut
if CA[period]>CA[period-1] then
RSX:setColor(period, Up1);
CA:setColor(period, Up2); 
elseif CA[period]<CA[period-1] then
RSX:setColor(period, Down1);
CA:setColor(period, Down2);
else
RSX:setColor(period, Neutral1);
CA:setColor(period, Neutral2);
end
    
end

