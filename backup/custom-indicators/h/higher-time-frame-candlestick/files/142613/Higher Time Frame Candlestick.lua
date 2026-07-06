-- More information about this indicator can be found at:
--https://fxcodebase.com/code/posting.php?mode=post&f=17

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2021, Gehtsoft USA LLC  | 
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

--+------------------------------------------------------------------------------------------------+
--|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |
--|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C                                 |
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |                                                  |   
--+------------------------------------------------------------------------------------------------+

function Init()
    indicator:name("Candlestick");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    
	indicator.parameters:addGroup("Source");	
    indicator.parameters:addString("timeframe", "Timeframe", "", "D1");
    indicator.parameters:setFlag("timeframe", core.FLAG_BARPERIODS);
    indicator.parameters:addBoolean("type", "Is It Bid", "", true);
    indicator.parameters:setFlag("type", core.FLAG_BIDASK);
	
	
	indicator.parameters:addGroup("Selector");	
	indicator.parameters:addBoolean("Historical", "Show Historical", "", false);
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
local tradingWeekOffset, tradingDayOffset;
local Shift;
local H_Shift;
local loading;
local Use_Transparency;
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
    tradingWeekOffset = core.host:execute("getTradingWeekOffset");
    tradingDayOffset = core.host:execute("getTradingDayOffset");
    bar_source = core.host:execute("getHistory1", 1, source:instrument(), instance.parameters.timeframe, 300, 0, instance.parameters.type);
	loading=true;
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
    if stage ~= 2
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
	
	local i;	
	
	if to_bar== -1 then
	return;
	end
	
	if   Historical then
 
	
			for i = from_bar, to_bar, 1 do
				local s, e = core.getcandle(bar_source:barSize(), bar_source:date(i), tradingDayOffset, tradingWeekOffset);
				local start_tick = core.findDate(source, s, false);
				local end_tick = core.findDate(source, e, false);

				local x1 = context:positionOfBar(start_tick);
				local x2 = context:positionOfBar(end_tick);
				local x = (x2 + x1) / 2;

				local _, y_high = context:pointOfPrice(bar_source.high[i]);
				local _, y_low = context:pointOfPrice(bar_source.low[i]);
				local _, y_close = context:pointOfPrice(bar_source.close[i]);
				local _, y_open = context:pointOfPrice(bar_source.open[i]);
				if bar_source.close[i] > bar_source.open[i] then
				    if Use_Transparency then
					context:drawRectangle(ASC_PEN, ASC_Rectangle, x1, y_close, x2, y_open);
					else
					context:drawRectangle(ASC_PEN, -1, x1, y_close, x2, y_open);					
					end
					context:drawLine(ASC_PEN, x, y_close, x, y_high);
					context:drawLine(ASC_PEN, x, y_open, x, y_low);
				else
				    if Use_Transparency then
					context:drawRectangle(DESC_PEN, DESC_Rectangle, x1, y_close, x2, y_open);
					else
					context:drawRectangle(DESC_PEN, -1, x1, y_close, x2, y_open);
					end
					context:drawLine(DESC_PEN, x, y_open, x, y_high);
					context:drawLine(DESC_PEN, x, y_close, x, y_low);
				end
			end
		
	else
            i=to_bar;
	    	local s, e = core.getcandle(bar_source:barSize(), bar_source:date(i), tradingDayOffset, tradingWeekOffset);
				local start_tick = core.findDate(source, s, false);
				local end_tick = core.findDate(source, e, false);
				
				
				local X1 = context:positionOfBar(start_tick);
				local X2 = context:positionOfBar(end_tick);
				local X = (X2 + X1) / 2;				
                
				if Shift then
				x=context:right ()-H_Shift*2 ;	
				x1=x-H_Shift/2;
				x2=x+H_Shift/2;				
                else
				x1=X1;
				x2=X2;
				x=X;
				end

				local _, y_high = context:pointOfPrice(bar_source.high[i]);
				local _, y_low = context:pointOfPrice(bar_source.low[i]);
				local _, y_close = context:pointOfPrice(bar_source.close[i]);
				local _, y_open = context:pointOfPrice(bar_source.open[i]);
				if bar_source.close[i] > bar_source.open[i] then
				    if Use_Transparency then				
					context:drawRectangle(ASC_PEN, ASC_Rectangle, x1, y_close, x2, y_open);
					else
					context:drawRectangle(ASC_PEN, -1, x1, y_close, x2, y_open);					
					end
					
					context:drawLine(ASC_PEN, x, y_close, x, y_high);
					context:drawLine(ASC_PEN, x, y_open, x, y_low);
				else
				    if Use_Transparency then
					context:drawRectangle(DESC_PEN,DESC_Rectangle, x1, y_close, x2, y_open);
					else
					context:drawRectangle(DESC_PEN,-1, x1, y_close, x2, y_open);					
					end
					
					context:drawLine(DESC_PEN, x, y_open, x, y_high);
					context:drawLine(DESC_PEN, x, y_close, x, y_low);
				end
	end		
end

function AsyncOperationFinished(cookie ) 
		
			  if cookie ==  1  then 
			  loading  = false; 	 
              end
		 
   
        if not loading then
		instance:updateFrom(0);	
		end
			  
	    
   
        
		return core.ASYNC_REDRAW ;


end