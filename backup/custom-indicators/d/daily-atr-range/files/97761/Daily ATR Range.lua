-- Id: 13263
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61605

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("ATR Range");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Daily ATR Range");
	indicator.parameters:addString("TF", "ATR Time Frame", "", "D1");
    indicator.parameters:setFlag("TF", core.FLAG_PERIODS);
    indicator.parameters:addInteger("Period", "ATR Periods", "", 100);
	 
	
	AddParameters(1,25);
	AddParameters(2,50);
	AddParameters(3,100);
	

	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up", "High Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Down", "Low Line Color", "", core.rgb(0, 255, 0));
end

function AddParameters(id, Level)
indicator.parameters:addGroup(id ..". Level"); 
indicator.parameters:addBoolean("On" ..id, "Show Level", "", true);
indicator.parameters:addDouble("Level" ..id, "Level", "", Level);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;
local ATR;
local Period;
local Factor;
local TF; 
local SourceData;
local loading;
local On={};
local Level={};
local Up,Down;
local uid;
local Test;
-- Routine
function Prepare(nameOnly)
    source = instance.source;
    first = source:first();
	
	On[1]= instance.parameters.On1;
	On[2]= instance.parameters.On2;
	On[3]= instance.parameters.On3;
	
	Level[1]= instance.parameters.Level1;
	Level[2]= instance.parameters.Level2;
	Level[3]= instance.parameters.Level3;
	
	Up=instance.parameters.Up;
	Down=instance.parameters.Down;
	Period=instance.parameters.Period; 
	TF=instance.parameters.TF;
	
	 local s1, e1, s2, e2;
    s1, e1 = core.getcandle(source:barSize(),0, 0, 0);
    s2, e2 = core.getcandle(TF, 0, 0, 0);
    assert ((e1 - s1) <= (e2 - s2), "The chosen time frame must be equal to or bigger than the chart time frame!");
	
	
    local name = profile:id() .. "(" .. source:name() ..", " .. TF ..", " .. Period  .. ")";
    instance:name(name);
	if nameOnly then
		return;
	end
	SourceData = core.host:execute("getSyncHistory", source:instrument(), TF, source:isBid(), math.min(300,Period*2), 100, 101);
	loading=true;
	
	ATR = core.indicators:create("ATR", SourceData, Period); 
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode) 
		
		
		if period < source:size()-1	
		or loading
		then
		return;
		end
		
		ATR:update(mode); 
		
		s, e = core.getcandle(TF, core.now(), 0, 0);		
		Test="";
		uid=0;
		
		Add(1,s,e);
		Add(2,s,e);
		Add(3,s,e);
		
end


  

function Add( id, fromDate,toDate)

   if not  On[id]  then
   return;
   end
 
   local atr=(ATR.DATA[ATR.DATA:size()-1] );

    fromLevel= SourceData.high[ SourceData.high:size()-1]  - ((atr/100)*Level[id]) ;
	 
	uid=uid+1;
    core.host:execute ("drawLine", uid, fromDate, fromLevel, toDate, fromLevel, Up );	 
	uid=uid+1;
 	core.host:execute ("drawLabel", uid, toDate, fromLevel, string.format("%." .. source:getPrecision() .. "f", fromLevel));
	
	fromLevel= SourceData.low[ SourceData.low:size()-1] +  ((atr/100)*Level[id]);
	uid=uid+1;
    core.host:execute ("drawLine", uid, fromDate, fromLevel, toDate, fromLevel, Down );	 
 	uid=uid+1;
	core.host:execute ("drawLabel", uid, toDate, fromLevel, string.format("%." .. source:getPrecision() .. "f", fromLevel));
end	
	
-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    if cookie == 100 then
        loading = false;
        instance:updateFrom(0);
    elseif cookie == 101 then
        loading = true;
    end
end