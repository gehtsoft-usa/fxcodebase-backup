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
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Dual Volume Divergence Index Overlay");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period", "Period", "", 255, 2, 2000);
	
	local color = core.colors();  
 
	indicator.parameters:addGroup("Style"); 	 
	
	
	 indicator.parameters:addColor("Color1", "1. Color", "", color.Green);
	 indicator.parameters:addColor("Color2", "2. Color", "", color.Lime);
     indicator.parameters:addColor("Color3", "3. Color", "", color.Maroon);
     indicator.parameters:addColor("Color4", "4. Color", "", color.Red);
	 indicator.parameters:addColor("Color5", "5. Color", "", core.rgb(128, 128, 128));
	
   
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

 
local first;
local source = nil;
 
local  open=nil;
local  close=nil;
local  high=nil;
local  low=nil;


local Period; 
local first;
local source = nil;
local Transparency;
local Oscillator;  
local EMA1,EMA2;
local pvi,nvi,zero;
local Color1,Color2, Color3, Color4, Color5;
local Top,Bottom;


 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end


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
	 
			
    source = instance.source;
    
   
 
	pvi= instance:addInternalStream(0, 0);	 
	nvi = instance:addInternalStream(0, 0);
 

   
    EMA1 = core.indicators:create("EMA", pvi, Period);
    EMA2 = core.indicators:create("EMA", nvi, Period);
    
    first=math.max(EMA1.DATA:first(), EMA2.DATA:first());
	
    	
	open = instance:addStream("openup", core.Line, name, "", core.rgb(0, 0, 0), first);
    high = instance:addStream("highup", core.Line, name, "", core.rgb(0, 0, 0), first);
    low = instance:addStream("lowup", core.Line, name, "", core.rgb(0, 0, 0), first);
    close = instance:addStream("closeup", core.Line, name, "", core.rgb(0, 0, 0), first);
    instance:createCandleGroup("OVERLAY", "OVERLAY", open, high, low, close);
		
end

-- Indicator calculation routine
function Update(period, mode)
	
    open[period] = source.open[period];
	close[period] = source.close[period];
	high[period] = source.high[period];
	low[period] = source.low[period];
	
   
   
   
    if period < source:first()+1 then
	return;
	end
	
	
	
	local ROC = (source[period] / source[period - 1] - 1) * 100;
	 
	
	 
	 --Positive Volume Divergence Index
		if  source.volume[period] > source.volume[period-1]  then
		pvi[period] =(pvi[period-1]) + ROC; 
		else
		pvi[period] =pvi[period-1];
		end
		
	     
		
		
		
		 --Negative Volume Divergence Index
		if  source.volume[period] <  source.volume[period-1] then
		nvi[period] =  nvi[period-1] - ROC 
		else
		nvi[period] =  nvi[period-1];
        end
		
		 
		
		EMA1:update(mode);
        EMA2:update(mode);
		
		if period <first then
		return;
		end
		
		
		local psig =EMA1.DATA[period]
		local pdiv = pvi[period] - psig;
		
	 
		
		
		local nsig = EMA2.DATA[period]
		local ndiv = nvi[period] - nsig
		
		 
		
		
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

 
		
		
		 
		 
		open:setColor(period,dcolor);			
		 
		
				

		
 end


