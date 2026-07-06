
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2525

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



-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("i_Sadukey Overlay");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	

	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Up", "Up color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Dn", "Down color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("No", "Neutral color", "", core.rgb(0, 0, 255));
	
   
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;

local Price;

local  open=nil;
local  close=nil;
local  high=nil;
local  low=nil;

local SN, LN, IN= nil;
local EN, DN;
local MACD;
local DMI;
local EMA;

local One, Two, Three;
local buffer;

function Prepare(nameOnly)
   

	source = instance.source;
	   
    local name = profile:id();
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
	first = source:first() + 66;
    first1 = source:first();
    Price1 = instance:addInternalStream(first1, 0);
    Price2 = instance:addInternalStream(first1, 0);	
	Price2 = instance:addInternalStream(first1, 0);
	buffer = instance:addInternalStream(first1, 0);

    	
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
	
				

	
	if period >= first1 then
        Price1[period]=((source.open[period]+source.close[period]+source.high[period]+source.low[period])/4.+source.close[period])/2.;
        Price2[period]=((source.open[period]+source.close[period]+source.high[period]+source.low[period])/4.+source.open[period])/2.;
    end
    if period >= first then
        local B1= 0.11859648*Price1[period]
                  +0.11781324*Price1[period-1]
                  +0.11548308*Price1[period-2]
                  +0.11166411*Price1[period-3]
                  +0.10645106*Price1[period-4]
                  +0.09997253*Price1[period-5]
                  +0.09238688*Price1[period-6]
                  +0.08387751*Price1[period-7]
                  +0.07464713*Price1[period-8]
                  +0.06491178*Price1[period-9]
                  +0.05489443*Price1[period-10]
                  +0.04481833*Price1[period-11]
                  +0.03490071*Price1[period-12]
                  +0.02534672*Price1[period-13]
                  +0.01634375*Price1[period-14]
                  +0.00805678*Price1[period-15]
                  +0.00062421*Price1[period-16]
                  -0.00584512*Price1[period-17]
                  -0.01127391*Price1[period-18]
                  -0.01561738*Price1[period-19]
                  -0.01886307*Price1[period-20]
                  -0.02102974*Price1[period-21]
                  -0.02216516*Price1[period-22]
                  -0.02234315*Price1[period-23]
                  -0.02165992*Price1[period-24]
                  -0.02022973*Price1[period-25]
                  -0.01818026*Price1[period-26]
                  -0.01564777*Price1[period-27]
                  -0.01277219*Price1[period-28]
                  -0.00969230*Price1[period-29]
                  -0.00654127*Price1[period-30]
                  -0.00344276*Price1[period-31]
                  -0.00050728*Price1[period-32]
                  +0.00217042*Price1[period-33]
                  +0.00451354*Price1[period-34]
                  +0.00646441*Price1[period-35]
                  +0.00798513*Price1[period-36]
                  +0.00905725*Price1[period-37]
                  +0.00968091*Price1[period-38]
                  +0.00987326*Price1[period-39]
                  +0.00966639*Price1[period-40]
                  +0.00910488*Price1[period-41]
                  +0.00824306*Price1[period-42]
                  +0.00714199*Price1[period-43]
                  +0.00586655*Price1[period-44]
                  +0.00448255*Price1[period-45]
                  +0.00305396*Price1[period-46]
                  +0.00164061*Price1[period-47]
                  +0.00029596*Price1[period-48]
                  -0.00093445*Price1[period-49]
                  -0.00201426*Price1[period-50]
                  -0.00291701*Price1[period-51]
                  -0.00362661*Price1[period-52]
                  -0.00413703*Price1[period-53]
                  -0.00445206*Price1[period-54]
                  -0.00458437*Price1[period-55]
                  -0.00455457*Price1[period-56]
                  -0.00439006*Price1[period-57]
                  -0.00412379*Price1[period-58]
                  -0.00379323*Price1[period-59]
                  -0.00343966*Price1[period-60]
                  -0.00310850*Price1[period-61]
                  -0.00285188*Price1[period-62]
                  -0.00273508*Price1[period-63]
                  -0.00274361*Price1[period-64]
                  +0.01018757*Price1[period-65];

       local B2= 0.11859648*Price2[period]
                  +0.11781324*Price2[period-1]
                  +0.11548308*Price2[period-2]
                  +0.11166411*Price2[period-3]
                  +0.10645106*Price2[period-4]
                  +0.09997253*Price2[period-5]
                  +0.09238688*Price2[period-6]
                  +0.08387751*Price2[period-7]
                  +0.07464713*Price2[period-8]
                  +0.06491178*Price2[period-9]
                  +0.05489443*Price2[period-10]
                  +0.04481833*Price2[period-11]
                  +0.03490071*Price2[period-12]
                  +0.02534672*Price2[period-13]
                  +0.01634375*Price2[period-14]
                  +0.00805678*Price2[period-15]
                  +0.00062421*Price2[period-16]
                  -0.00584512*Price2[period-17]
                  -0.01127391*Price2[period-18]
                  -0.01561738*Price2[period-19]
                  -0.01886307*Price2[period-20]
                  -0.02102974*Price2[period-21]
                  -0.02216516*Price2[period-22]
                  -0.02234315*Price2[period-23]
                  -0.02165992*Price2[period-24]
                  -0.02022973*Price2[period-25]
                  -0.01818026*Price2[period-26]
                  -0.01564777*Price2[period-27]
                  -0.01277219*Price2[period-28]
                  -0.00969230*Price2[period-29]
                  -0.00654127*Price2[period-30]
                  -0.00344276*Price2[period-31]
                  -0.00050728*Price2[period-32]
                  +0.00217042*Price2[period-33]
                  +0.00451354*Price2[period-34]
                  +0.00646441*Price2[period-35]
                  +0.00798513*Price2[period-36]
                  +0.00905725*Price2[period-37]
                  +0.00968091*Price2[period-38]
                  +0.00987326*Price2[period-39]
                  +0.00966639*Price2[period-40]
                  +0.00910488*Price2[period-41]
                  +0.00824306*Price2[period-42]
                  +0.00714199*Price2[period-43]
                  +0.00586655*Price2[period-44]
                  +0.00448255*Price2[period-45]
                  +0.00305396*Price2[period-46]
                  +0.00164061*Price2[period-47]
                  +0.00029596*Price2[period-48]
                  -0.00093445*Price2[period-49]
                  -0.00201426*Price2[period-50]
                  -0.00291701*Price2[period-51]
                  -0.00362661*Price2[period-52]
                  -0.00413703*Price2[period-53]
                  -0.00445206*Price2[period-54]
                  -0.00458437*Price2[period-55]
                  -0.00455457*Price2[period-56]
                  -0.00439006*Price2[period-57]
                  -0.00412379*Price2[period-58]
                  -0.00379323*Price2[period-59]
                  -0.00343966*Price2[period-60]
                  -0.00310850*Price2[period-61]
                  -0.00285188*Price2[period-62]
                  -0.00273508*Price2[period-63]
                  -0.00274361*Price2[period-64]
                  +0.01018757*Price2[period-65];

        if B1 > B2 then
            buffer[period] = B1;         
        else
            buffer[period] = B2;
         end
		 
		 
		if B1 > B2    then		
		open:setColor(period, instance.parameters.Up);
        elseif  B1 < B2   then
		open:setColor(period, instance.parameters.Dn);
		else
		open:setColor(period, instance.parameters.No);			
		end
		
    end

		
 end


