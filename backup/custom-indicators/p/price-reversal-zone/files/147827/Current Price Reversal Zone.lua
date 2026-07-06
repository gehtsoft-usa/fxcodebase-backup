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
    indicator:name("Current Price Reversal Zone");
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
local TF;
function Prepare(nameOnly)
    source = instance.source;
	Shift=instance.parameters.Shift;
	Historical=instance.parameters.Historical;
	Use_Transparency=instance.parameters.Use_Transparency;
	H_Shift=instance.parameters.H_Shift;
	TF=instance.parameters.timeframe
	
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
	
    BuyHigh = instance:addInternalStream(0, 0);		
    BuyLow = instance:addInternalStream(0, 0);		
    SellHigh = instance:addInternalStream(0, 0);
    SellLow = instance:addInternalStream(0, 0);	
	
    bar_source =core.host:execute("getSyncHistory", source:instrument(), instance.parameters.timeframe, source:isBid(),300, 100, 101);
	loading=true;


    day_offset = core.host:execute("getTradingDayOffset");
    week_offset = core.host:execute("getTradingWeekOffset");
	S, E = core.getcandle(TF, 0, 0, 0);
    Period=E-S;	
	
    instance:ownerDrawn(true);
		
end

function   Initialization(period)

    local Candle;
    Candle = core.getcandle(TF, source:date(period), day_offset, week_offset);

  
    if loading or bar_source:size() == 0 then
        return false ;
    end

    
    if period < source:first() then
        return false;
    end

    local p = core.findDate(bar_source, Candle, false);

    -- candle is not found
    if p < 0 then
        return false;
	else return p;	
    end
	
end	

function Update(period, mode)

    local p =  Initialization(period) 
     
	   
	if 	loading
	or period < source:first()
	or not p
	then
	return;
	end
	
	
--[[
Conditions for Sell zones to sellers candle to close below the open of the last buyers candle printed
Conditions for Buy zones to buyers candle to close above the open of the last sellers candle printed

]]	

    local B= LastBuyer(p);
    local S= LastSellers(p);
	
	
    BuyHigh[period]=BuyHigh[period-1]
    BuyLow[period]=BuyLow[period-1]
    SellHigh[period]=SellHigh[period-1]
    SellLow[period]=SellLow[period-1]
	
	
-- Buy zones
    if B~=0 then
    BuyHigh[period]=bar_source.high[B]
    BuyLow[period]=bar_source.open[B]
	else
    BuyHigh[period]=nil
    BuyLow[period]=nil
	end
	
--Sell zones
    if  S ~=0 then
    SellHigh[period]=bar_source.open[S]
    SellLow[period]=bar_source.low[S]
	else
    SellHigh[period]=nil
    SellLow[period]=nil
	end
	
end

function LastBuyer(P)
local Open=0;
local p=P-1;

for i= p, 1, -1 do
Open= i;
if bar_source.close[P]<bar_source.open[i] 
and bar_source.close[i]< bar_source.open[i] 
and  bar_source.close[P]> bar_source.open[P] 
then 
break
end

end

return Open;

end
 
function LastSellers(P) 
local Open=0;
local p=P-1;

for i= p, 1, -1 do
Open= i;
if  bar_source.close[P] > bar_source.open[i]
and bar_source.close[i]> bar_source.open[i] 
and  bar_source.close[P]< bar_source.open[P] 
then
break
end

end

return Open;
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

 
    local from_date =  math.max(source:first(), context:firstBar()) ;
    local to_date =  math.min(context:lastBar(), source:size() - 1) ;
 
	
	 
	
	if   Historical then 
 
			for i = from_date, to_date, 1 do 
			
                 x, x1, x2 = context:positionOfDate (source:date(i)) 
          	
			    --core.host:execute("setStatus",   source:date(source:size()-1).." - " .. s .." - " .. e); 
 

				local _, Y1 = context:pointOfPrice(BuyHigh[i]);
				local _, Y2 = context:pointOfPrice(BuyLow[i]);
				local _, Y3 = context:pointOfPrice(SellHigh[i]);
				local _, Y4 = context:pointOfPrice(SellLow[i]);
				
	 
				    if Use_Transparency then
					context:drawRectangle(ASC_PEN, ASC_Rectangle, x1, Y1, x2,Y2  );
					else
					context:drawRectangle(ASC_PEN, -1, x1, Y1, x2, Y2);					
					end
			   
			 
				    if Use_Transparency then
					context:drawRectangle(DESC_PEN, DESC_Rectangle, x1, Y3, x2, Y4);
					else
					context:drawRectangle(DESC_PEN, -1, x1, Y3, x2, Y4);
					end 
			 
			end
		
	else
                Last=source:size() - 1; 
                 x, x1, x2 = context:positionOfDate (source:date(Last)) 
             
                
				if Shift then
				x=context:right ()-H_Shift*2  ;	
				x2=x;
				x1=x2-H_Shift;				
                else
				x1=x1;
				x2=x2; 
				end

				local _, Y1 = context:pointOfPrice(BuyHigh[Last]);
				local _, Y2 = context:pointOfPrice(BuyLow[Last]);
				local _, Y3 = context:pointOfPrice(SellHigh[Last]);
				local _, Y4 = context:pointOfPrice(SellLow[Last]);
				
				    if Use_Transparency then
					context:drawRectangle(ASC_PEN, ASC_Rectangle, x1, Y1, x2,Y2  );
					else
					context:drawRectangle(ASC_PEN, -1, x1, Y1, x2, Y2);					
					end
			   
			 
				    if Use_Transparency then
					context:drawRectangle(DESC_PEN, DESC_Rectangle, x1, Y3, x2, Y4);
					else
					context:drawRectangle(DESC_PEN, -1, x1, Y3, x2, Y4);
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