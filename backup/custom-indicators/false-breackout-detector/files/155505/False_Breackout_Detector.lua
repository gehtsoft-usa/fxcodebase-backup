-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=74917

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                               https://appliedmachinelearning.systems/contact/  | 
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal:  https://goo.gl/9Rj74e   |
--|                                                             Patreon :  http://tiny.cc/1ybwxz   |  
--|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   | 
--+------------------------------------------------------------------------------------------------+
 


-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("False_Breackout_Detector");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
 
	indicator.parameters:addGroup("Line Style");	
	indicator.parameters:addInteger("Size", "Arrow Size", "", 20); 
   indicator.parameters:addColor("clrUP", "Up Arrow", "" ,  core.COLOR_UPCANDLE);
    indicator.parameters:addColor("clrDN",  "Down Arrow", "" , core.COLOR_DOWNCANDLE);	
	indicator.parameters:addColor("color", "Bar Color", "", core.rgb(0, 0, 255)); 

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
local first;
local source = nil; 
local Indicator;
local Bar;	
local up, down;
-- Routine
 function Prepare(nameOnly)   
  
	source = instance.source
        
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	 
	first=source:first()+5;  
	
	Valley= instance:addInternalStream(0, 0); 
	Peack= instance:addInternalStream(0, 0); 
	 
	
	valley = instance:createTextOutput ("Valley", "Valley", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Bottom, instance.parameters.clrUP, 0);
    peack = instance:createTextOutput ("Peack", "Peack", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Top , instance.parameters.clrDN, 0);
	

	buy = instance:createTextOutput ("buy", "buy", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Bottom, instance.parameters.clrUP, 0);
    sell = instance:createTextOutput ("sell", "sell", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Top , instance.parameters.clrDN, 0);	
 
end


function Update(period, mode)

    peack:setNoData(period);
    valley:setNoData(period);

    buy:setNoData(period);
    sell:setNoData(period);	
 
	
	if period <= first
	or not  source:hasData(period)
	then
	return;
	end
	  
 

	
	if isValley(period)
	then 
		valley:set(period-3, source.low[period-3], "\110");	
		Valley[period-3]=1;
		 
	elseif isPeack(period)
    then	
	             
        peack:set(period-3, source.high[period-3], "\110");	 
		Peack[period-3]=1;
	end
	

	if ((source.close[period-1] > lastPeack(period, "value") and source.close[period] < lastPeack(period, "value") )or
		(source.high[period] > lastPeack(period, "value") and source.close[period] < lastPeack(period, "value") and source.close[period]<=source.open[period])) then
    
        sell:set(period, source.high[period], "\242");
        drawPeakLine(period,instance.parameters.clrDN)		

    end
    if ((source.close[period-1] < lastValley(period, "value") and source.close[period]>lastValley(period, "value")) or
		(source.low[period] < lastValley(period, "value") and source.close[period] > lastValley(period, "value") and source.close[period]>=source.open[period])) then
  

	 buy:set(period, source.low[period], "\241");	
	 drawValleyLine(period, instance.parameters.clrUP)	
    end
	
  
	
	
end


function drawPeakLine(period, Color)
 
	 
	 local lastValue= lastPeack(period, "value")
	 local lastPosition= lastPeack(period, "pos")	 
	 core.host:execute("drawLine", source:serial(period), source:date(lastPosition), lastValue, source:date(period), lastValue,Color);

end

function drawValleyLine(period, Color)
 
	 local lastValue= lastValley(period, "value")
	 local lastPosition= lastValley(period, "pos")	 
	 core.host:execute("drawLine", source:serial(period), source:date(lastPosition), lastValue, source:date(period), lastValue,Color);

end




function isValley( i)
 
 
  local  cl5 = source.low[ i - 5];
  local cl4 = source.low[ i - 4];
  local cl2 = source.low[ i - 2];
  local cl1 = source.low[ i - 1];
  local lo  = source.low[ i - 3];
  return lo < cl2 and cl2 < cl1 and lo < cl4 and cl4 < cl5;
end

function isPeack( i)
 
  local cl5 = source.high[ i - 5];
  local cl4 = source.high[ i - 4];
  local cl2 = source.high[ i - 2];
  local cl1 = source.high[ i - 1];
  local hi  = source.high[ i - 3];
  return hi > cl2 and cl2 > cl1 and hi > cl4 and cl4 > cl5;
end


function lastValley(i, mode)

local Return=0;


  for period= i-1, first, -1 do
  
  
      if Valley[period]==1 then
	  
		  if  mode == "pos" then
		  Return=period;
		  else
		  Return= source.low[period]
		  end
		  
	  break;
	  end
	  
  
  end
  
  
 
  return Return;
end

function lastPeack(i,mode)
local Return=0;


  for period= i-1, first, -1 do
  
  
      if Peack[period]==1 then
	  
		  if  mode == "pos" then
		  Return=period;
		  else
		  Return= source.high[period]
		  end
		  
	  break;
	  end
	  
  
  end
  
  
 
  return Return;
end

--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal:  https://goo.gl/9Rj74e   |
--|                                                             Patreon :  http://tiny.cc/1ybwxz   |  
--|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   | 
--+------------------------------------------------------------------------------------------------+
--|  Cryptocurrency  |  Network                    |  Address                                      |
--+------------------------------------------------+-----------------------------------------------+
--|  USDT            |  ERC20 (ETH Ethereum)       |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
--|  USDT            |  TRC20 (Tron)               |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
--|  USDT            |  BEP20 (BSC BNB Smart Chain)|  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--|  USDT            |  Matic Polygon              |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--|  USDT            |  SOL Solana                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
--|  USDT            |  ARBITRUM Arbitrum One      |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
--+------------------------------------------------+-----------------------------------------------+