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
    indicator:name("Higher Time Frame Candlestick Sequence");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
    
	indicator.parameters:addGroup("Source");	
 
    indicator.parameters:addBoolean("type", "Is It Bid", "", true);
    indicator.parameters:setFlag("type", core.FLAG_BIDASK);
    local TF={"m1", "m5", "m15", "m30", "H1", "H2", "H3", "H4", "H6", "H8", "D1", "W1", "M1"};	
	for i= 1, 13 , 1 do
	indicator.parameters:addBoolean("Show".. i , "Show " .. TF[i]..". Time Frame", "", true);
	end
	
	indicator.parameters:addBoolean("Lower", "Show Lower Time Frame", "", true);
 
	indicator.parameters:addGroup("Style");
	
    indicator.parameters:addColor("up_color", "Up color", "", core.colors().Green);
    indicator.parameters:addColor("down_color", "Down color", "", core.colors().Red);
	
	indicator.parameters:addInteger("H_Shift", "Horizontal Shift", "", 500);
    	indicator.parameters:addInteger("Spacing", "Spacing", "", 100);
end
 
local source;
local bar_source={}; 
local H_Shift,Spacing;
local TimeFrame;
local TF={"m1", "m5", "m15", "m30", "H1", "H2", "H3", "H4", "H6", "H8", "D1", "W1", "M1"};
local Start;
local offset, weekoffset;
local Lower;
local loading={}; 
function Prepare(nameOnly)
    source = instance.source; 
	TimeFrame=source:barSize();	
	H_Shift=instance.parameters.H_Shift;
	Spacing=instance.parameters.Spacing;
	Lower=instance.parameters.Lower;
    local name = string.format("%s(%s)", profile:id(), source:name());
    instance:name(name);
    if nameOnly then
        return ;
    end
 
    Start=0;
	
	offset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");
 
       -- check whether chosen time frame is higher than
       local s1, e1, s2, e2;
       s1, e1 = core.getcandle(source:barSize(), offset, weekoffset);
   
      
	   
	for i= 1, 13 , 1 do
	    s2, e2 = core.getcandle(TF[i], offset, weekoffset);
		if  ((e2 - s2) >= (e1 - s1) or Lower ) and instance.parameters:getBoolean("Show" .. i)  then 
		Start=Start+1;
		bar_source[Start] = core.host:execute("getHistory1", Start, source:instrument(), TF[Start], 300, 0, instance.parameters.type);
		loading[Start]=true;
		end
	end
    instance:ownerDrawn(true);
end

function Update(period, mode)
end

local init = false;
local ASC_PEN = 1;
local DESC_PEN = 3;

function Draw(stage, context)
    if stage ~= 2 then
        return;
    end
    if not init then
        init = true;
        context:createPen(ASC_PEN, context.SOLID, 1, instance.parameters.up_color);
        context:createPen(DESC_PEN, context.SOLID, 1, instance.parameters.down_color);
    end

	
 
	
	for i= 1, Start , 1 do
     
 
		
		LastBar=bar_source[i]:size()-1;
		if 	bar_source[i].high:hasData(LastBar) then	 
		 
					x=context:right ()-H_Shift +(H_Shift/Start)*i -Spacing ;	
					x1=x-2*(H_Shift/Start)/6;
					x2=x+2*(H_Shift/Start)/6;				
			  

					local _, y_high = context:pointOfPrice(bar_source[i].high[LastBar]);
					local _, y_low = context:pointOfPrice(bar_source[i].low[LastBar]);
					local _, y_close = context:pointOfPrice(bar_source[i].close[LastBar]);
					local _, y_open = context:pointOfPrice(bar_source[i].open[LastBar]);
					if bar_source[i].close[LastBar] > bar_source[i].open[LastBar] then
						context:drawRectangle(ASC_PEN, -1, x1, y_close, x2, y_open);
						context:drawLine(ASC_PEN, x, y_close, x, y_high);
						context:drawLine(ASC_PEN, x, y_open, x, y_low);
					else
						context:drawRectangle(DESC_PEN, -1, x1, y_close, x2, y_open);
						context:drawLine(DESC_PEN, x, y_open, x, y_high);
						context:drawLine(DESC_PEN, x, y_close, x, y_low);
					end
		 end		
	end
end

function AsyncOperationFinished(cookie )

   local Count=0;
   local Flag=false;
   
   for i= 1, Start , 1 do
 
 
		
			  if cookie ==  i  then 
			  loading[i] = false; 	 
              end
			  
		if loading[i] then
		Count=Count+1;
		Flag=true;
		end	 
   end
   
   
		  
		if Flag then
		core.host:execute ("setStatus", " Loading ".. (Start-Count) .."/" .. Start);
		else
		core.host:execute ("setStatus", " Loaded ".. (Start-Count) .."/" .. Start);
		instance:updateFrom(0);	
		end
			  
	    
   
        
		return core.ASYNC_REDRAW ;


end