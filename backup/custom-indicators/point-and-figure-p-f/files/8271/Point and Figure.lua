-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3470
-- Id: 3190

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Point and Figure");
    indicator:description("Point and Figure");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation");	
	indicator.parameters:addString("Type", "Box Size Calculation Method", "" , "ATR");
	indicator.parameters:addStringAlternative("Type", "ATR", "" , "ATR");
    indicator.parameters:addStringAlternative("Type", "Percentage", "" , "Percentage");
    indicator.parameters:addStringAlternative("Type", "Pips", "" , "Pips");
	

     indicator.parameters:addInteger("BS", "Box Size (in pips)", "", 50, 1, 100000);
	 indicator.parameters:addDouble("Percentage", "Box Size (Percentage)", "", 0.2, 0.001 , 20);
    indicator.parameters:addInteger("RS", "Reversal Count (in boxes)", "", 3, 1, 100);
    indicator.parameters:addInteger("ATRFrame", "ATR Period", "", 14, 2, 1000);	
	 indicator.parameters:addDouble("Multiplier", "ATR Multiplier", "", 1, 0.1 , 100);
	 
	 indicator.parameters:addBoolean("Ignore", "Ignore High/Low", "" ,  false);
	
	indicator.parameters:addGroup("Style");	
	 indicator.parameters:addInteger("size", "Label Size", "", 5, 1, 10);
	indicator.parameters:addColor("Up", "X Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "O Color","", core.rgb(255, 0, 0));
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local BS, RS;
local Up,Down;
local size;
local Multiplier;
local Ignore;

local Type;
local first;
local source = nil;
local font;
local Percentage;
local  ATRFrame;
local ATR;
local TEST=true;

-- Streams block
local count=1;
local row=1;
local column=1;

local sign;
local swing;
local last;
local flag;
local symbol;
local low,high;
local PRICE;
local LAST;
-- Routine
function Prepare(nameOnly)
    Ignore= instance.parameters.Ignore;
    Multiplier= instance.parameters.Multiplier;
    size= instance.parameters.size;
    Up= instance.parameters.Up;
	Down= instance.parameters.Down;
    Type = instance.parameters.Type;
	ATRFrame = instance.parameters.ATRFrame;
    Percentage = instance.parameters.Percentage;
    BS = instance.parameters.BS;
	RS = instance.parameters.RS;
    source = instance.source;
    first = source:first();

    local name;
    if Type == "Pips" then
		name= profile:id() .. "(" .. source:name() .. ", " .. BS ..", " ..RS..", "..Type..")";
	elseif Type == "Percentage" then
		name= profile:id() .. "(" .. source:name() .. ", " .. Percentage ..", " ..RS..", "..Type.. ")";
	else
		name= profile:id() .. "(" .. source:name() .. ", " .. ATRFrame ..", " ..RS..", "..Type..  ", " .. Multiplier..")";
	end
	instance:name(name);
	
	if nameOnly then
		return;
	end
	if Type == "Pips" then
	elseif Type == "Percentage" then
	else
		ATR = core.indicators:create("ATR", source, ATRFrame);
		first=ATR.DATA:first();
	end
	TEST=true;
	
	 font = core.host:execute("createFont", "Courier", size, false, true);
	 
	 core.host:execute("removeAll");

        count =1;
	    column=1;
		
	if Ignore then
	low=source.close;
	high=source.close;
	else
	low=source.low;
	high=source.high;
	end	
    
end

function ReleaseInstance()
       core.host:execute("deleteFont", font);      
   end



-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)

if period < source:size()-1 then
return;
end


	if LAST ~= source:serial(source:size()-1) then
      LAST = source:serial(source:size()-1)
		for i = first, source:size()-1, 1 do
		Calculate (i, mode)
		end
	end

end 			

function Calculate (period, mode)



if period ==first then
        core.host:execute("removeAll");

        count =1;
	    column=1;
        
return;
end

if TEST and Type ~= "ATR" then
TEST = false;
       if Type=="Percentage" then
		BS=((source.close[period]/source:pipSize())/100)*Percentage;
		end
end

if Type == "ATR" and TEST  then
ATR:update(mode);
		if not ATR.DATA:hasData(period) then
		return;
		end
	TEST = false;
	BS= (ATR.DATA[period]*Multiplier)/source:pipSize();
end


if period == source:size()-1 then

local min,max;
  min,max	= mathex.minmax(source, first, period); 	

    	core.host:execute ("drawLine", 1,  source:date(first), min, source:date(period), min, core.rgb(0, 255, 0), core.LINE_NONE);	
        core.host:execute ("drawLine", 2, source:date(first), max, source:date(period), max, core.rgb(0, 255, 0), core.LINE_NONE);	
	 
return;
end

if period == first+1 then
		

last= source.close[period-1];
	if source.close[period]>  source.close[period-1] then
	swing = "Up"
	flag = "Up"
	symbol="X";
	else
	swing = "Down"
	flag = "Down"
	symbol="O";
	end
	
end

   flag=nil;

    

    if high[period] > last+BS*source:pipSize() then
	flag = "Up"
	elseif low[period] < last-BS*source:pipSize() then
	flag = "Down"
	end

	if swing == "Up" and  flag == "Down" and low[period] < last-BS*source:pipSize()*RS then
	swing = "Down";
	column=column+1;
	symbol="O";
	elseif swing == "Down" and  flag == "Up" and high[period] > last+BS*source:pipSize()*RS then
	swing = "Up";
	column=column+1;
	symbol="X";
	end
	
	if flag==nil then
	return;
	end

local  i;
row=1;
		        if swing == "Up" and  flag == "Up" then
		
		
				   for i = last, high[period], BS*source:pipSize()  do
							if  i == last + BS*source:pipSize() then
							last = last + BS*source:pipSize();
							row=row+1;
							DRAW (Up)
							end
				   end
				elseif swing == "Down" and  flag == "Down" then
				   for i = last, low[period], - BS*source:pipSize()  do
							if  i == last - BS*source:pipSize() then
							last = last - BS*source:pipSize();
							row=row+1;
							DRAW (Down)
							end
				     end
		end
		
		
		
end


function DRAW (color)
 core.host:execute("drawLabel1", count, column*10, core.CR_LEFT, last, core.CR_CHART, core.H_Right, core.V_Center,
                          font, color,  symbol);
						  
						  count=count+1;
end