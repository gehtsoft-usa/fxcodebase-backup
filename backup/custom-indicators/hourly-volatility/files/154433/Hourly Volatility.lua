-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=74630

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  | 
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal:  https://goo.gl/9Rj74e   |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |
--|                                                      Buy Me a Coffee:  http://tiny.cc/pjh9vz   |  
--+------------------------------------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Hourly Volatility");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
 
 
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("color", "Color", "Color", core.rgb(0, 0, 255)); 
	indicator.parameters:addInteger("Transparency", "Transparency", "Transparency",50);
end

 

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 
 

local first;
local source = nil; 
local Data,Number;
local TF="H1";
local Hour;
local Max;
-- Routine
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    Data={}; 
    Number={};
	
	BC = instance.parameters.BC;
	SC = instance.parameters.SC;
	NC = instance.parameters.NC; 
    source = instance.source; 
	
	first = source:first() ;

   
    dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");
 
	
	
	
    s1, e1 = core.getcandle(source:barSize(),0, 0, 0);
    s2, e2 = core.getcandle(TF, 0, 0, 0);
    assert ((e1 - s1) <= (e2 - s2), "The chosen chart time frame must be equal to or smaller than H1!");
	
    s, e = core.getcandle(TF, 0, 0, 0);
    Hour=e-s;	
	
	Source = core.host:execute("getSyncHistory", source:instrument(), TF, source:isBid(), 200, 100, 101);
	loading=true;
	
	instance:ownerDrawn(true);
	
   Top=instance:addStream("Top", core.Line, name, "Top", core.rgb( 128, 128, 128), first);
   Bottom=instance:addStream("Bottom", core.Line, name, "Bottom", core.rgb( 128, 128, 128), first);  

   Top:setVisible (false)
   Bottom:setVisible (false)   
end

local Last;
-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period <= first or period < source:size() -1 then
	return;
	end 
 
	Top[period]=1;
	Bottom[period]=0;	
	
	Data={}; 
    Number={};

	
	if Last== Source:serial(Source:size()-1) then
	return;
	end
	
	for i=1, Source:size()-2, 1 do
    tableDate = core.dateToTable(Source:date(i));	
	
		if Data[tableDate.hour]==nil then
		Data[tableDate.hour]=0;
		Number[tableDate.hour]=0;
		end
	
	Data[tableDate.hour]=Data[tableDate.hour]+ (Source.high[i]-Source.low[i]);
	Number[tableDate.hour]=Number[tableDate.hour]+1;
	

	end


	Max=0;
	for i=0, 24, 1 do 	
	
		if Number[i]~= nil then
		Data[i]=Data[i]/ Number[i];
		
			if Max < Data[i] then
			 Max = Data[i]
			end	
		end	
	end
    
end


-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    if cookie == 100 then
        loading = false;
        instance:updateFrom(0);
    elseif cookie == 101 then
        loading = true;
    end
	
		return core.ASYNC_REDRAW ;	
end

local init = false;

function Draw (stage, context)

    if stage  ~= 2 
	or loading
	then
	return;
	end
	 
	 

	 
  
     context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());
   
    if not init then
	init =true;
	Transparency=context:convertTransparency (instance.parameters.Transparency);	
	context:createSolidBrush(1, instance.parameters.color);
	    
	end

		

										  
			   for i= Source:size()-1, 1,  -1 do	  

								local begin = core.getcandle("H1", Source:date(i), dayoffset, weekoffset); 
								--The function returns two values: the date time when the candle starts and the date time when the candle ends. 
			 
				 
								
								x, x1, x2 = context:positionOfDate (Source:date(i));
								x, x1, x2 = context:positionOfDate (Source:date(i));
				
								
								tableDate = core.dateToTable(Source:date(i));												
								y1= context:bottom()-  Data[tableDate.hour]*((context:bottom()-context:top())/Max);
								y2= context:bottom();							
													
								context:drawRectangle (-1, 1, x1, y1, x2, y2, Transparency);
					
					
						if Source:date(i) < source:date(context:firstBar ()) then
						   break;
						end 	
		         end
 
	
	
	
 end
 
--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
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