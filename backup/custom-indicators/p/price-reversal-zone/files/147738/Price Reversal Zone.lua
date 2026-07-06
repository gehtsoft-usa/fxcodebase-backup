-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72801

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|                                           Our work would not be possible without your support. |
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+
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
    indicator:name("Price Reversal Zone");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    
	indicator.parameters:addGroup("Source");	
    indicator.parameters:addString("timeframe", "Timeframe", "", "D1");
    indicator.parameters:setFlag("timeframe", core.FLAG_BARPERIODS);
    indicator.parameters:addBoolean("type", "Is It Bid", "", true);
    indicator.parameters:setFlag("type", core.FLAG_BIDASK);
	
	
	indicator.parameters:addGroup("Selector");	
	indicator.parameters:addBoolean("Historical", "Show Historical", "", true);
    indicator.parameters:addBoolean("Shift", "Shift To The Right", "", true);

	indicator.parameters:addGroup("Style");
	
    indicator.parameters:addColor("up_color", "Up color", "", core.colors().Green);
    indicator.parameters:addColor("down_color", "Down color", "", core.colors().Red);
	
	indicator.parameters:addInteger("H_Shift", "Horizontal Shift", "", 50);
    indicator.parameters:addBoolean("Use_Transparency", "Use Transparency", "", true);	
	indicator.parameters:addInteger("transparency", "Fill Transparency", "0 - opaque, 100 - transparent", 75, 0, 100);


 
end
local Historical;
local source, bar_source;
local week_offset, day_offset;
local Shift;
local H_Shift;
local loading;
local Use_Transparency;
local S,E, Period;
function Prepare(nameOnly)
    source = instance.source;
	Shift=instance.parameters.Shift;
	Historical=instance.parameters.Historical;
	Use_Transparency=instance.parameters.Use_Transparency;
	H_Shift=instance.parameters.H_Shift;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
		

    bar_source =core.host:execute("getSyncHistory", source:instrument(), instance.parameters.timeframe, source:isBid(),300, 100, 101);
	loading=true;


    day_offset = core.host:execute("getTradingDayOffset");
    week_offset = core.host:execute("getTradingWeekOffset");
	S, E = core.getcandle(instance.parameters.timeframe, 0, 0, 0);
    Period=E-S;	
	
    instance:ownerDrawn(true);
		
end

function Update(period, mode)
end

local init = false;
local ASC_PEN = 1;
local ASC_Rectangle = 2;
local DESC_PEN = 3;
local DESC_Rectangle = 4;
local transparency;
function Draw(stage, context)
    if stage ~= 0
	or loading
	then
        return;
    end
    if not init then
        init = true;
        context:createPen(ASC_PEN, context.SOLID, 1, instance.parameters.up_color);
        context:createPen(DESC_PEN, context.SOLID, 1, instance.parameters.down_color);
		transparency= context:convertTransparency (instance.parameters.transparency)
		
		context:createSolidBrush (ASC_Rectangle, instance.parameters.up_color)
		context:createSolidBrush (DESC_Rectangle, instance.parameters.down_color)
    end

 
    local from_date = source:date(math.max(source:first(), context:firstBar()));
    local to_date = source:date(math.min(context:lastBar(), source:size() - 1));

    local from_bar = math.max(0, core.findDate(bar_source, from_date, false));
    local to_bar = math.min(math.max(0, core.findDate(bar_source, to_date, false)), bar_source:size() - 1);
    --local to_bar= bar_source:size() - 1;
	
 
	
	if to_bar== -1 then
	return;
	end
	
	
	--[[
	From last sellers candle open to wick high 
	zone only draw when buyers candle has closed 
	above the open price of the last sellers candle,
	zone drawn from last sellers candle open to wick high

    From last buyers candle open to wick low
	zone only draw when sellers candle has closed below the open price of the last buyer candle,
	zone drawn from last buyers candle open to wick low
	]]
	
	if   Historical then 
 
			for i = from_bar, to_bar, 1 do 
			
				 s, e = core.getcandle( instance.parameters.timeframe, bar_source:date(i), day_offset, week_offset); 
                 x1, x, x = context:positionOfDate (s) 
                 x2, x, x = context:positionOfDate (e)
          	
			    --core.host:execute("setStatus",   source:date(source:size()-1).." - " .. s .." - " .. e); 
   

				local _, y_high = context:pointOfPrice(bar_source.high[i]);
				local _, y_low = context:pointOfPrice(bar_source.low[i]);
				local _, y_close = context:pointOfPrice(bar_source.close[i]);
				local _, y_open = context:pointOfPrice(bar_source.open[i]);
				
				if bar_source.close[i] > bar_source.open[i] then
				    if Use_Transparency then
					context:drawRectangle(ASC_PEN, ASC_Rectangle, x1, y_open, x2,y_low  );
					else
					context:drawRectangle(ASC_PEN, -1, x1, y_open, x2, y_low);					
					end
			 
				elseif bar_source.close[i] <= bar_source.open[i] then
				    if Use_Transparency then
					context:drawRectangle(DESC_PEN, DESC_Rectangle, x1, y_high, x2, y_open);
					else
					context:drawRectangle(DESC_PEN, -1, x1, y_high, x2, y_open);
					end 
				end
			end
		
	else
                Last=bar_source:size() - 1;
	    	    local s, e = core.getcandle( instance.parameters.timeframe, bar_source:date(Last), day_offset, week_offset); 
                 x1, x, x = context:positionOfDate (s) 
                 x2, x, x = context:positionOfDate (e) 
                
				if Shift then
				x=context:right ()-H_Shift*2  ;	
				x2=x;
				x1=x2-H_Shift;				
                else
				x1=x1;
				x2=x2; 
				end

				local _, y_high = context:pointOfPrice(bar_source.high[Last]);
				local _, y_low = context:pointOfPrice(bar_source.low[Last]);
				local _, y_close = context:pointOfPrice(bar_source.close[Last]);
				local _, y_open = context:pointOfPrice(bar_source.open[Last]);
				if bar_source.close[Last] > bar_source.open[Last] then
				    if Use_Transparency then				
					context:drawRectangle(ASC_PEN, ASC_Rectangle, x1, y_open, x2,y_low );
					else
					context:drawRectangle(ASC_PEN, -1, x1, y_open, x2, y_low );					
					end
					
 
				elseif bar_source.close[Last] <= bar_source.open[Last] then
				    if Use_Transparency then
					context:drawRectangle(DESC_PEN,DESC_Rectangle, x1, y_high, x2, y_open);
					else
					context:drawRectangle(DESC_PEN,-1, x1, y_high, x2, y_open);					
					end
			 
				end
	end		
end

function AsyncOperationFinished(cookie ) 
		
    if cookie == 100 then
        loading = false;
        instance:updateFrom(0);
    elseif cookie == 101 then
        loading = true;
    end
		 
   
        if not loading then
		instance:updateFrom(0);	
		end
			  
	    
   
        
		return core.ASYNC_REDRAW ;


end

--+------------------------------------------------------------------------------------------------+
--|                                                                    We appreciate your support. | 
--+------------------------------------------------------------------------------------------------+
--|                                                               Paypal: https://goo.gl/9Rj74e    |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                                       https://mario-jemic.com/ |
--+------------------------------------------------------------------------------------------------+