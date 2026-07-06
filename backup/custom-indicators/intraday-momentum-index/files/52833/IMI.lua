-- Id: 8345
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=30911

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
    indicator:name("Intraday Momentum Index");
    indicator:description("Intraday Momentum Index");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);


    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 14, 2, 1000);
	
	
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("clrIMI", "Indicator color","", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
    
    indicator.parameters:addGroup("OB/OS Levels");	
    indicator.parameters:addDouble("overbought", "Overbought Level","", 70);
    indicator.parameters:addDouble("oversold","Oversold Level","", 30);
	 indicator.parameters:addColor("level_overboughtsold_color", "Line Color","", core.rgb(128, 128, 128));
    indicator.parameters:addInteger("level_overboughtsold_width","Line width","", 1, 1, 5);
    indicator.parameters:addInteger("level_overboughtsold_style", "Line Style","", core.LINE_SOLID);
    indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
end

local Period=nil;
local first;
local source = nil;
local Up, Down;
local IMI = nil;

function Prepare(nameOnly)


    assert(instance.parameters.oversold < instance.parameters.overbought, "Overbought level must be higher than oversold");

    Period = instance.parameters.Period;
    source = instance.source;
    first = source:first() + Period;

    local name = profile:id() .. "(" .. source:name() .. ", " .. Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
	
	Up = instance:addInternalStream(0, 0);
	Down = instance:addInternalStream(0, 0);

    IMI = instance:addStream("IMI", core.Line, name, "IMI", instance.parameters.clrIMI, first);	
	IMI:setWidth(instance.parameters.width);
    IMI:setStyle(instance.parameters.style);
	
    IMI:setPrecision(4);    
    IMI:addLevel(0);
    IMI:addLevel(50);   
    IMI:addLevel(100);
	
	IMI:addLevel(instance.parameters.oversold, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);
	IMI:addLevel(instance.parameters.overbought, instance.parameters.level_overboughtsold_style, instance.parameters.level_overboughtsold_width, instance.parameters.level_overboughtsold_color);    
end

function Update(period, mode)

--[[ Add Gains and Losses for n chosen days ago:  IMI = 100 x (Gains / (Gains + Losses))
Another way of looking at this equation is to say that the Intraday Momentum Index is the sum of "up" days 
divided by the sum of "up" days plus the sum of "down" days. This quotient is then multiplied by 100 to arrive 
at the IMI number, a number between 0 and 100. ]]

   
            if source.close[period]> source.open[period] then 
                Up[period] = source.close[period] - source.open[period];
				Down[period]=0;
            elseif  source.open[period] > source.close[period] then
                Up[period]=0;
				Down[period]=source.open[period] - source.close[period];
            end       
     
	if period < first  then
	return;
	end
		
		 
		
		local UP= mathex.sum(Up, period-Period+1, period);
		local DOWN= mathex.sum(Down, period-Period+1, period);
		
		
        IMI[period] = 100 *( UP / (UP+DOWN));     -- we use minus sumn so it becomes positive
        
    
end








