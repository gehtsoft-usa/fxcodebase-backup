-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64201

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


function Init()
    indicator:name("Candle Direction Predictor");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
   
   
    indicator.parameters:addGroup("Calculation");	
	indicator.parameters:addInteger("Period", "Look Back Period" ,"",3);

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrUP", "Up Color","", core.COLOR_UPCANDLE);
    indicator.parameters:addColor("clrDN","Down Color","", core.COLOR_DOWNCANDLE);
    indicator.parameters:addBoolean("Probability", "Show probability","", true);
	--indicator.parameters:addBoolean("Historical", "Show Historical","", true);
    indicator.parameters:addColor("clrPrice", "Label Color","", core.rgb(128, 128, 128));
	
	  indicator.parameters:addInteger("Size", "Label Size","",10);
end

local source;
local up, down;
local Probability;
local Size;
local Period;
local SignatureUp={};
local SignatureDown={};
local first;
--local Historical;
function Prepare(nameOnly)
    source = instance.source;
	
    local name = profile:id() .. "(" .. source:name() .. ")";
	Probability=instance.parameters.Probability;
	--Historical=instance.parameters.Historical;
	Period=instance.parameters.Period;
	Size=instance.parameters.Size;
	
	
	first=source:first()+Period;
	
	
	instance:name(name);
	if nameOnly then
		return;
	end
    up = instance:createTextOutput ("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.clrUP, 0,1);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.clrDN, 0,1);
	 

end

 


local Last;
function Update(period)

period=period-1;


if Last==source:serial(period) then
return;
end

Last=source:serial(period);



 
local Flag="";

for i= 1, Period, 1 do
		if source.close[period-i]>source.open[period-i] then
		 Flag=Flag.. "x";
		elseif source.close[period-i]<source.open[period-i] then
		 Flag=Flag.. "o";
		end
end

if Flag~= "" then
		if source.close[period]>source.open[period] then
			if SignatureUp[Flag]== nil then
			SignatureUp[Flag]=1;
			else
			SignatureUp[Flag]= SignatureUp[Flag]+1;
			end

		elseif source.close[period]<source.open[period] then
			if SignatureDown[Flag]== nil  then
			SignatureDown[Flag]=1;
			else
			SignatureDown[Flag]= SignatureDown[Flag]+1;
			end
		end
end

if period < source:size()-2 then
return;
end

for period= first, source:size()-1, 1 do
ReCalculate(period)
end

 
end

function ReCalculate (period)


up:setNoData(period);
down:setNoData(period);

local Flag="";

for i= 1, Period, 1 do
		if source.close[period-i]>source.open[period-i] then
		 Flag=Flag.. "x";
		elseif source.close[period-i]<source.open[period-i] then
		 Flag=Flag.. "o";
		end
end


           if Flag~= "" then

					if SignatureUp[Flag]== nil   then
					SignatureUp[Flag]=0;
					end

					if SignatureDown[Flag]== nil   then
					SignatureDown[Flag]=0;
					end

			
					if SignatureUp[Flag] > SignatureDown[Flag] then   
					up:set(period , source.high[period], "\217", source.high[period]);			 
					end
					if SignatureUp[Flag] < SignatureDown[Flag] then   
					down:set(period , source.low[period ], "\218", source.low[period ]); 
					end
			
			end
 
end