-- Id: 14594

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62412

--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
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
    indicator:name("VLM with Real volume/Transactions");
    indicator:description("VLM with Real volume/Transactions");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
  
	  
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Ind", "Type of indicator", "", "Volume");
    indicator.parameters:addStringAlternative("Ind", "Volume", "", "Volume");
    indicator.parameters:addStringAlternative("Ind", "Transactions", "", "Transactions");
    indicator.parameters:addInteger("m1", "m1 Period", "", 300);
	indicator.parameters:addInteger("m5", "m5 Period", "", 120);
	indicator.parameters:addInteger("m15", "m15 Period", "", 120);
	indicator.parameters:addInteger("m30", "m30 Period", "", 60);
	indicator.parameters:addInteger("H1", "H1 Period", "", 30);
	indicator.parameters:addInteger("H2", "H2 Period", "", 30);
	indicator.parameters:addInteger("H3", "H6 Period", "", 30);
	indicator.parameters:addInteger("H4", "H4 Period", "", 30);
	indicator.parameters:addInteger("H6", "H6 Period", "", 30);
	indicator.parameters:addInteger("H8", "H8 Period", "", 30);
	indicator.parameters:addInteger("D1", "D1 Period", "", 30);
	indicator.parameters:addInteger("W1", "W1 Period", "", 25);
	indicator.parameters:addInteger("M1", "M1 Period", "", 12);
	
	   indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Color1", "Color of Hours between 8-14 & 18-21", "", core.rgb(255, 0, 0));
	 indicator.parameters:addColor("Color2", "Color of Hours between 14-18", "", core.rgb(0, 255, 0));
	  indicator.parameters:addColor("Color3", "Color of Hours after 22", "", core.rgb( 0, 128, 128));
	   indicator.parameters:addColor("Color4", "Color of Hours prior to 8", "", core.rgb(0, 0, 255));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;

local first;
local source = nil;

-- Streams block
local Volume = nil;
local Ind;

local FirstStart;
local LastTime;

-- Routine
function Prepare(nameOnly)

    source = instance.source;
    first = source:first();
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
	
		 if  source:barSize () == "m1" then
		         Period = instance.parameters.m1;
		 elseif source:barSize () == "m5" then
		 		 Period = instance.parameters.m5;
		 elseif source:barSize () == "m15" then
		      	 Period = instance.parameters.m15;
		 elseif source:barSize () == "m30" then
		          Period = instance.parameters.m30;
		 elseif source:barSize () == "H1" then
		 		 Period = instance.parameters.H1;		         
		 elseif source:barSize () == "H2" then 
		 		 Period = instance.parameters.H2;
		 elseif source:barSize () == "H3" then
		 		 Period = instance.parameters.H3;
		 elseif source:barSize () == "H4" then
		 		 Period = instance.parameters.H4;		         
		 elseif source:barSize () == "H6" then
		 		 Period = instance.parameters.H6;
		 elseif source:barSize () == "H8" then
		 		 Period = instance.parameters.H8;
		 elseif source:barSize () == "D1" then 
		 		 Period = instance.parameters.D1;		        
		 elseif source:barSize () == "W1" then
		 		 Period = instance.parameters.W1;		   
		 elseif source:barSize () == "M1" then 
		 		 Period = instance.parameters.M1;
		 end

  
	
     if instance.parameters.Ind=="Volume" then
      Ind=core.indicators:create("REAL VOLUME", source);
     else
      Ind=core.indicators:create("TRANSACTIONS", source);
     end
     FirstStart=true;
     LastTime=0;

    if (not (nameOnly)) then
        Volume = instance:addStream("Volume", core.Bar, name, "Volume", instance.parameters.Color1, first);
    Volume:setPrecision(math.max(2, instance.source:getPrecision()));
    end
end

function AsyncOperationFinished(cookie, success, message)

end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
    if period <first +Period or not  source:hasData(period) then
	return;
	end
	
        Ind:update(mode);
        if not(Ind.DATA:hasData(period)) then
            if period==first+Period then
                FirstStart=true;
            end    
            return;
        elseif FirstStart then
            FirstStart=false;
            instance:updateFrom(first);    
        elseif LastTime~=source:date(period) and period==source:size()-1 then
            LastTime=source:date(period);
            instance:updateFrom(period-10);
        end
	 
     Volume[period]  =Ind.DATA[period] /  mathex.avg (Ind.DATA, period- Period+1, period);

	 
	 local date = core.dateToTable(source:date(period));
     if date.hour >= 8 and  date.hour < 14 then
	 Volume:setColor(period, instance.parameters.Color1);
	 elseif date.hour >= 18 and  date.hour <= 21 then
	  Volume:setColor(period, instance.parameters.Color1);
	 elseif date.hour >= 14 and  date.hour < 18 then
	  Volume:setColor(period, instance.parameters.Color2);
	 elseif date.hour >=  22 then
	  Volume:setColor(period, instance.parameters.Color3);
	 elseif date.hour <  8 then
	  Volume:setColor(period, instance.parameters.Color4);
	 end

    
end

