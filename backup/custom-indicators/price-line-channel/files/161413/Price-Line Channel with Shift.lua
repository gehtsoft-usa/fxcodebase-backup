-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=72621
--
-- ── Author ─────────────────────────────────────────────────────────────────────
-- Developed by: Mario Jemic
-- Email:        mario.jemic@gmail.com
-- Website:      https://mario-jemic.com
--
-- ── Support & Donations ────────────────────────────────────────────────────────
-- PayPal:        https://paypal.me/mariojemic
-- Patreon:       https://tiny.cc/1ybwxz
-- BuyMeACoffee:  https://tiny.cc/bj7vxz
--
-- Crypto:
--  BTC : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
--  SOL : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
--  ETH/BNB/USDT/XRP (ERC20 & BEP20): 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7
--
-- ── Copyright ──────────────────────────────────────────────────────────────────
-- © 2025 Gehtsoft USA LLC — https://fxcodebase.com

-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- <https://www.gnu.org/licenses/>.


-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Price-Line Channel");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

  
 	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("length", "Period", "", 50, 1, 2000); 
    indicator.parameters:addBoolean("r", "Readjustement", "", true);	
    indicator.parameters:addInteger("Lookback", "Lookback period", "", 0);	
    indicator.parameters:addInteger("Shift", "Shift period", "", 0);		
	 indicator.parameters:addGroup("Line Style");	
    indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("color1", "Upper Line Color", "", core.rgb(0, 255, 0)); 
	 indicator.parameters:addColor("color2", "Lower Line Color", "", core.rgb(255, 0, 0)); 
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
	
local first;
local source = nil;
local length,r; 
 
	
-- Routine
 function Prepare(nameOnly)   
 
    
	length=instance.parameters.length;
	r=instance.parameters.r;
	Lookback=instance.parameters.Lookback;
	Shift=instance.parameters.Shift;
	source = instance.source
 
    local name = profile:id() .. "(" ..  instance.source:name().. "," ..  length  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	ATR= core.indicators:create("ATR", source, length);
	first=ATR.DATA:first() ; 
	
	
	sizeA = instance:addInternalStream(0, 0);
	sizeB = instance:addInternalStream(0, 0); 
	sizeC = instance:addInternalStream(0, 0);	

 	
	
    a = instance:addStream("Upper", core.Line, name, "Upper", instance.parameters.color1, first, Shift);
    a:setPrecision(math.max(2, instance.source:getPrecision()));
    a:setWidth(instance.parameters.width);
    a:setStyle(instance.parameters.style);
    a:addLevel(0);	
 
    b = instance:addStream("Lower", core.Line, name, "Lower", instance.parameters.color2, first, Shift);
    b:setPrecision(math.max(2, instance.source:getPrecision()));
    b:setWidth(instance.parameters.width);
    b:setStyle(instance.parameters.style);
    b:addLevel(0);	 
end


function Update(period, mode)

	ATR:update(mode); 
	



	 if period <= first 
	 or (Lookback>0 and period < source:size()-1 - Lookback)
	 or period-2+Shift < 0
	 then      	 
	 return;
	 end
	 
 	a[period+Shift]=0; 	 
	b[period+Shift]=math.huge; 	
   
  if  (a[period-1+Shift]-a[period-2+Shift]) > 0 then
  sizeA[period]= ATR.DATA[period];
  else
  sizeA[period]=  sizeA[period-1];  
  end
  
  if   (b[period-1+Shift]-b[period-2+Shift]) < 0 then
  sizeB[period]= ATR.DATA[period];
  else
  sizeB[period]=  sizeB[period-1]; 
  end
  
  if  (a[period-1+Shift]-a[period-2+Shift]) > 0 or  (b[period-1+Shift]-b[period-2+Shift]) < 0 then
  sizeC[period]= ATR.DATA[period]; 
  else
  sizeC[period]= sizeC[period-1]; 
  end
  
   if(r) then
   A=sizeC[period]/length;
   else
   A=sizeA[period]/length;
   end
   
   if(r) then
   B=sizeC[period]/length;
   else
   B=sizeB[period]/length;
   end  
   
	a[period+Shift]=math.max( a[period-1+Shift],source.close[period]) - A;
	b[period+Shift]=math.min( b[period-1+Shift],source.close[period]) + B; 	
end


-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=72621
--
-- ── Author ─────────────────────────────────────────────────────────────────────
-- Developed by: Mario Jemic
-- Email:        mario.jemic@gmail.com
-- Website:      https://mario-jemic.com
--
-- ── Support & Donations ────────────────────────────────────────────────────────
-- PayPal:        https://paypal.me/mariojemic
-- Patreon:       https://tiny.cc/1ybwxz
-- BuyMeACoffee:  https://tiny.cc/bj7vxz
--
-- Crypto:
--  BTC : 16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ
--  SOL : 3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2
--  ETH/BNB/USDT/XRP (ERC20 & BEP20): 0xe53aab6bc468a963a02d1319660ee60cf80fc8e7
--
-- ── Copyright ──────────────────────────────────────────────────────────────────
-- © 2025 Gehtsoft USA LLC — https://fxcodebase.com

-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- <https://www.gnu.org/licenses/>.