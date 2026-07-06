-- Id: 20554
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65728

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+

-- Indicator profile initialization routine

function Init()
    indicator:name("Dual Volume Divergence Index");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period", "Period", "", 255, 2, 2000);
	
	local color = core.colors();  
 
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("pvi1", "PVI Line Up Color", "", core.rgb(0, 255, 0));
	 indicator.parameters:addColor("pvi2", "PVI Line Down Color", "", core.rgb(0, 200, 0));
	  indicator.parameters:addColor("zero", "Zero Line Color", "", color.Yellow);
	indicator.parameters:addColor("nvi1", "NVI Line Up Color", "", core.rgb(200, 0, 0));
	indicator.parameters:addColor("nvi2", "NVI Line Down Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
	
	
	 indicator.parameters:addColor("Color1", "1. Color", "", color.Green);
	 indicator.parameters:addColor("Color2", "2. Color", "", color.Lime);
     indicator.parameters:addColor("Color3", "3. Color", "", color.Maroon);
     indicator.parameters:addColor("Color4", "4. Color", "", color.Red);
	  indicator.parameters:addColor("Color5", "5. Color", "", core.rgb(128, 128, 128));
	 
	  indicator.parameters:addInteger("Transparency", "Transparency", "", 40,0,100);
		 
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Period; 
local first;
local source = nil;
local Transparency;
local Oscillator;  
local EMA1,EMA2;
local pvi,nvi,zero;
local Color1,Color2, Color3, Color4, Color5;
local Top,Bottom;
-- Routine
 function Prepare(nameOnly) 
   
     Period = instance.parameters.Period;   
 
    local name = profile:id() .. "(" ..  instance.source:name() .. ", " ..  Period .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
   
   
   	
	Color1 = instance.parameters.Color1;
	Color2 = instance.parameters.Color2;
	Color3 = instance.parameters.Color3;
	Color4 = instance.parameters.Color4;
    Color5 = instance.parameters.Color5;
	Transparency= instance.parameters.Transparency;
	 Transparency= 100-Transparency;
			
    source = instance.source;
    
   	Top = instance:addStream("Top" , core.Line, " Top"," Top",instance.parameters.pvi1, source:first());
	Bottom = instance:addStream("Bottom" , core.Line, " Bottom"," Bottom",instance.parameters.pvi1, source:first());
 
	pvi = instance:addStream("PVI" , core.Line, " PVI"," PVI",instance.parameters.pvi1, source:first());
	pvi:setWidth(instance.parameters.width);
    pvi:setStyle(instance.parameters.style);
    
	nvi = instance:addStream("NVI" , core.Line, " NVI"," NVI",instance.parameters.nvi2,source:first());
	nvi:setWidth(instance.parameters.width);
    nvi:setStyle(instance.parameters.style);
	
	zero= instance:addStream("ZERO" , core.Line, " ZERO"," ZERO",instance.parameters.zero,source:first());
	zero:setWidth(instance.parameters.width);
    zero:setStyle(instance.parameters.style);
	
	pvi:setPrecision(math.max(2, instance.source:getPrecision()));
	nvi:setPrecision(math.max(2, instance.source:getPrecision()));
	zero:setPrecision(math.max(2, instance.source:getPrecision()));
	
	Top:setPrecision(math.max(2, instance.source:getPrecision()));
	Bottom:setPrecision(math.max(2, instance.source:getPrecision()));
	
	
	instance:createChannelGroup("Group","Group" , Top, Bottom, Color5, Transparency);
   
    EMA1 = core.indicators:create("EMA", pvi, Period);
    EMA2 = core.indicators:create("EMA", nvi, Period);
    
    first=math.max(EMA1.DATA:first(), EMA2.DATA:first());
	

	
end

-- Indicator calculation routine
function Update(period, mode)

 
 

	
	
    if period < source:first()+1 then
	return;
	end
	
	zero[period]=0;
	
	local ROC = (source[period] / source[period - 1] - 1) * 100;
	 
	
	 
	 --Positive Volume Divergence Index
		if  source.volume[period] > source.volume[period-1]  then
		pvi[period] =(pvi[period-1]) + ROC; 
		else
		pvi[period] =pvi[period-1];
		end
		
	    Top[period]=pvi[period];
		
		
		
		 --Negative Volume Divergence Index
		if  source.volume[period] <  source.volume[period-1] then
		nvi[period] =  nvi[period-1] - ROC 
		else
		nvi[period] =  nvi[period-1];
        end
		
		Bottom[period]=nvi[period];
		
		EMA1:update(mode);
        EMA2:update(mode);
		
		if period <first then
		return;
		end
		
		
		local psig =EMA1.DATA[period]
		local pdiv = pvi[period] - psig;
		
		
		if pvi[period] > psig then
		pcolor = instance.parameters.pvi1;
		else 
		pcolor = instance.parameters.pvi2;
		end
		
		
		
		local nsig = EMA2.DATA[period]
		local ndiv = nvi[period] - nsig
		
		if nvi[period] < nsig then
		ncolor = instance.parameters.nvi2;
		else 
		ncolor = instance.parameters.nvi1;
		end
		
		pvi:setColor(period, pcolor);
		nvi:setColor(period, ncolor);
		
		
	local dcolor;
		
	  if  (pdiv > ndiv) and (pdiv < 0) then
	  dcolor = Color1;
	   elseif (pdiv > ndiv) and (pdiv > 0) then
		dcolor =Color2;
		elseif (ndiv > pdiv) and (ndiv < 0) then
		dcolor =Color3;
  	   elseif (ndiv > pdiv) and (ndiv > 0) then
		dcolor =Color4;
		else
		dcolor =Color5;
		end

		Top:setColor(period, dcolor);		  
end
 