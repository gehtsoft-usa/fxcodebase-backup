
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2529

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
    indicator:name("NCandle indicator");
    indicator:description("NCandle indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("N", "N", "", 10);
    indicator.parameters:addBoolean("IncludeCurrentBar", "Include current bar", "", true);
	 indicator.parameters:addBoolean("Ignore", "Ignore the inside bar", "", false);
	
	

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("HIGH", "Color for High", "Color for High", core.rgb(0,0,255));
    indicator.parameters:addColor("LOW", "Color for Low", "Color for Low", core.rgb(255,0,255));
    indicator.parameters:addColor("UP", "Color for UP", "Color for UP", core.rgb(0,255,0));
    indicator.parameters:addColor("DOWN", "Color for DOWN", "Color for DOWN", core.rgb(255,0,0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 3, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
    indicator.parameters:addInteger("Transparency", "Transparency", "", 50,0,100);
end

local first;
local source = nil;
local N;
local High;
local Low;
local hUP=nil;
local hDN=nil;
local lUP=nil;
local lDN=nil;

local Ignore;
function Prepare(nameOnly) 
    source = instance.source;
    N=instance.parameters.N;
	Ignore=instance.parameters.Ignore;
    first = source:first();
    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.N .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
    High = instance:addStream("High", core.Line, name .. ".High", "High", instance.parameters.HIGH, 0);
    Low = instance:addStream("Low", core.Line, name .. ".Low", "Low", instance.parameters.LOW, 0);
    hUP=instance:addInternalStream(0, 0);
    hDN=instance:addInternalStream(0, 0);
    lUP=instance:addInternalStream(0, 0);
    lDN=instance:addInternalStream(0, 0);
    High:setWidth(instance.parameters.widthLinReg);
    High:setStyle(instance.parameters.styleLinReg);
    Low:setWidth(instance.parameters.widthLinReg);
    Low:setStyle(instance.parameters.styleLinReg);
    instance:createChannelGroup("UpGroup","Up" , hUP, hDN, instance.parameters.UP, 100-instance.parameters.Transparency);
    instance:createChannelGroup("DnGroup","Dn" , lUP, lDN, instance.parameters.DOWN, 100-instance.parameters.Transparency);
end

function Update(period)
   if  period <source:size()-1 then
   return;
   end
   
   
    local MaxBar;
    if instance.parameters.IncludeCurrentBar then
     MaxBar=source:size()-1;
    else
     MaxBar=source:size()-2;
    end
	
	--if not  then
	
	local Max=nil;
	local Min=nil;
	local LastP=nil;
	local Count=0;
	
	for p= MaxBar, first, -1 do
	
	
	       
			
			if Max== nil then
			Max=source.high[p];
			end
			if Min== nil then
			Min=source.low[p];
			end
		
     		if source.high[p]> Max then
			 Max=source.high[p];
			 end
			 
			 if source.low[p]< Min then
			 Min=source.low[p];
			 end
			 
			 
			  if Ignore and ( source.high[p] > source.high[p-1] or source.low[p] < source.low[p-1]) then
			  Count= Count+1;
			  elseif not Ignore then
			  Count= Count+1;
			  end
			  
			  
			  LastP=p;
			  
			  if Count >= N then
			  break;
			  end
			  
	
	end
	
	
	if LastP== nil or LastP <= first  then
	return;
	end
	
	
	core.drawLine(High,core.range(LastP,period),Max,LastP,Max,period);
    core.drawLine(Low,core.range(LastP,period),Min,LastP,Min,period);
	
	
     core.drawLine(High,core.range(first,LastP-1),0,first,0,LastP-1);
     core.drawLine(Low, core.range(first,LastP-1),0,first,0,LastP-1);
     High[LastP-1]= nil;
	 Low[LastP-1]= nil;
	
    local Open=source.open[LastP];
    local Close=source.close[source:size()-1];
	
    if Open>Close then
     core.drawLine(lUP,core.range(LastP,period),Open,LastP,Open,period);
     core.drawLine(lDN,core.range(LastP,period),Close,LastP,Close,period);
     core.drawLine(hUP,core.range(first,period),0,LastP,0,period);
     core.drawLine(hDN,core.range(first,period),0,LastP,0,period);
	 hDN[LastP-1]= nil;
	 hUP[LastP-1]= nil;
	 
	 core.drawLine(lUP,core.range(first,LastP-1),0,first,0,LastP-1);
     core.drawLine(lDN,core.range(first,LastP-1),0,first,0,LastP-1);
	 lUP[LastP-1]= nil;
	 lDN[LastP-1]= nil;
	 
    else
     core.drawLine(hUP,core.range(LastP,period),Close,LastP,Close,period);
     core.drawLine(hDN,core.range(LastP,period),Open,LastP,Open,period);
     core.drawLine(lUP,core.range(first,period),0,LastP,0,period);
     core.drawLine(lDN,core.range(first,period),0,LastP,0,period);
	 lUP[LastP-1]= nil;
	 lDN[LastP-1]= nil;
	 
	 core.drawLine(hUP,core.range(first,LastP-1),0,first,0,LastP-1);
     core.drawLine(hDN,core.range(first,LastP-1),0,first,0,LastP-1);
	 hUP[LastP-1]= nil;
	 hDN[LastP-1]= nil;
 
    end
 
    
end

