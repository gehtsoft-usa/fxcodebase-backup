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
local Signature={};
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

 
 
function ItIs (period)
local Return = true;
  
  
for i= 1, Period, 1 do
		if source.close[period-i]<source.open[period-i] and Signature[i]== 1 then
		Return = false;
		elseif source.close[period-i]>source.open[period-i]and Signature[i]== -1  then
		Return = false;
		end
end 


return Return;
  
end


function Update(period)


up:setNoData(period);
down:setNoData(period);
 

if period< source:size()-1 then
return;
end

for i= 1, Period, 1 do
		if source.close[period-i]>source.open[period-i] then
		Signature[i]= 1;
		elseif source.close[period-i]<source.open[period-i] then
		Signature[i]= -1;
		end
end

local Up=0;
local Down=0;

for i = source:size()-2, first, -1 do

   if ItIs(i) then
	   if source.close[i]> source.open[i]then
	   Up=Up+1;
	   elseif source.close[i]< source.open[i]then
	   Down=Down+1;   
	   end
   end

end

local Delta=(source:date(period)- source:date(period-1))*2;


    
            if Up > Down then   
            up:set(period , source.high[period], "\217", source.high[period]);
			
				if Probability then
				
                       probability = ((Up / (source:size()-1)))*100;
				     core.host:execute ("drawLabel", 1, source:date(period)+Delta, source.high[period],  win32.formatNumber(probability, false, 0) .. "%"  )
					  
				end

			end
            if Up < Down then   
            down:set(period , source.low[period ], "\218", source.low[period ]);
					if Probability then 
						   probability = ((Down / (source:size()-1)))*100;
						 core.host:execute ("drawLabel", 1, source:date(period)+Delta, source.low[period], win32.formatNumber(probability, false, 0) .. "%" )
						 
					 end
			end
			
			
up:setNoData(period-1);
down:setNoData(period-1);


 
end
