-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71910

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                              Support our efforts by donating   | 
--|                                                                 Paypal: https://goo.gl/9Rj74e  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

--Your donations will allow the service to continue onward.
--+------------------------------------------------------------------------------------------------+
--|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
--|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
--|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
--|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
--|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
--|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
--+------------------------------------------------------------------------------------------------+

function Init()
    indicator:name("Pin Bar and Full Body Candlestick");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);	
    indicator:setTag("replaceSource", "t");		
    
	indicator.parameters:addGroup("Source");	 
    indicator.parameters:addBoolean("type", "Is It Bid", "", true);
    indicator.parameters:setFlag("type", core.FLAG_BIDASK);
	

	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addDouble("BodyMax", "Body Maximal Value as Percentage of High Low Range", "", 5);	
    indicator.parameters:addDouble("BodyMin", "Body Minimal Value as Percentage of High Low Range", "", 95);	
 

	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("up_color", "Up color", "", core.colors().Green);
    indicator.parameters:addColor("down_color", "Down color", "", core.colors().Red); 
    indicator.parameters:addColor("background_color", "Background color", "", core.COLOR_BACKGROUND ); 	
	indicator.parameters:addColor("Doji_color", " Doji color", "", core.colors().White);
	indicator.parameters:addColor("Full_Body_color", " Full Body color", "", core.colors().White);	
 
end
local BodyMax,BodyMin; 
local source;
function Prepare(nameOnly)
    source = instance.source; 
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end 
    BodyMax = instance.parameters.BodyMax;
	BodyMin = instance.parameters.BodyMin;
 
    instance:ownerDrawn(true);
	
	open = instance:addStream("openup", core.Line, name, "", core.rgb(0, 0, 0), source:first());
	open:setStyle(core.LINE_NONE);	
    high = instance:addStream("highup", core.Line, name, "", core.rgb(0, 0, 0),  source:first());
	high:setStyle(core.LINE_NONE);		
    low = instance:addStream("lowup", core.Line, name, "", core.rgb(0, 0, 0),  source:first());
	low:setStyle(core.LINE_NONE);		
    close = instance:addStream("closeup", core.Line, name, "", core.rgb(0, 0, 0),  source:first());
	close:setStyle(core.LINE_NONE);		
     instance:createCandleGroup("OVERLAY", "OVERLAY", open, high, low, close);	
end

function Update(period, mode)

open[period]=source.open[period];
high[period]=source.high[period];
low[period]=source.low[period];
close[period]=source.close[period];
end

local init = false; 

function Draw(stage, context)
    if stage ~= 2 
	then
        return;
    end
    if not init then
        init = true;
        context:createPen(1, context.SOLID, 1, instance.parameters.up_color);
        context:createSolidBrush (2, instance.parameters.up_color)		
		
        context:createPen(3, context.SOLID, 1, instance.parameters.down_color); 
        context:createSolidBrush (4, instance.parameters.down_color)	

        context:createPen(5, context.SOLID, 1, instance.parameters.background_color); 
        context:createSolidBrush (6, instance.parameters.background_color)		

        context:createPen(7, context.SOLID, 1, instance.parameters.Doji_color); 
        context:createSolidBrush (8, instance.parameters.Doji_color)	

        context:createPen(9, context.SOLID, 1, instance.parameters.Full_Body_color); 
        context:createSolidBrush (10, instance.parameters.Full_Body_color)			
    end

        local first_candle = math.max(source:first(), context:firstBar ());
        local last_candle = math.min (context:lastBar (), source:size()-1);
	
	local i;	
 
	
 
 
	
			for i = first_candle, last_candle, 1 do  
 
				local X0, X1, X2 = context:positionOfBar(i);
                local Delta=(X2-X1)/4.5;

				local _, y_high = context:pointOfPrice(source.high[i]);
				local _, y_low = context:pointOfPrice(source.low[i]);
				local _, y_close = context:pointOfPrice(source.close[i]);
				local _, y_open = context:pointOfPrice(source.open[i]);
				
 			    max= math.max(source.open[i],source.close[i])
				min= math.min(source.open[i],source.close[i])

				HighLow=(source.high[i]-source.low[i])/100;
				Body= math.abs(source.open[i]-source.close[i])/HighLow;
								
				Top=(source.high[i]-max)/HighLow;
	            Bottom =(min-source.low[i])/HighLow;		
				
                if (Body < BodyMax ) then
					context:drawRectangle(7, 8, X1+Delta, y_close, X2-Delta, y_open);
					context:drawLine(7, X0, math.min(y_close,y_open), X0, y_high);
					context:drawLine(7, X0, math.max(y_close,y_open), X0, y_low);		
			 
                elseif (Body >  BodyMin ) then				
					context:drawRectangle(9, 6, X1+Delta, y_close, X2-Delta, y_open);
					context:drawLine(9, X0, math.min(y_close,y_open), X0, y_high);
					context:drawLine(9, X0, math.max(y_close,y_open), X0, y_low);		
              					
              				
				elseif source.close[i] > source.open[i] then
					context:drawRectangle(1, 2, X1+Delta, y_close, X2-Delta, y_open);
					context:drawLine(1, X0, math.min(y_close,y_open), X0, y_high);
					context:drawLine(1, X0, math.max(y_close,y_open), X0, y_low);
				else
					context:drawRectangle(3, 4, X1+Delta, y_close, X2-Delta, y_open);
					context:drawLine(3, X0, math.min(y_close,y_open), X0, y_high);
					context:drawLine(3, X0, math.max(y_close,y_open), X0, y_low);
				end 
				
				
	
				
				
			end
		
 
 
end

 