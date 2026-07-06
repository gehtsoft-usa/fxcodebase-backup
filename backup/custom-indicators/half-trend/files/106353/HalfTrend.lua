-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=63501&p=106353#p106353

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
    indicator:name("HalfTrend");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Amplitude", "Period", "", 2, 2, 5000);
 
    
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up", "Up Trend color", "Line Color", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Trend color", "Line Color", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width1", "Line Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line Line style", "Line style", core.LINE_SOLID);
 
  
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local first;
local source;
local Amplitude;
local HalfTrend;
local High, Low;
--local up, dowm;
local Up, Down;
local nexttrend=0;
local minhighprice, maxlowprice;
local trend;
-- Routine
function Prepare()
    Amplitude= instance.parameters.Amplitude;
	Up= instance.parameters.Up;
	Down= instance.parameters.Down;
    source = instance.source;
	
	 local name = profile:id() .. "(" .. source:name() .. ", " .. Amplitude  .. ")";
	instance:name(name);
	if (nameOnly) then
        return;
    end
    High = core.indicators:create("MVA", source.high, Amplitude); 
	Low = core.indicators:create("MVA", source.low, Amplitude);
    first=Low.DATA:first();	 
	--up = instance:addInternalStream(0, 0);
	--down = instance:addInternalStream(0, 0);
	trend= instance:addInternalStream(0, 0);
	 
    HalfTrend = instance:addStream("HalfTrend", core.Line, name .. ".HalfTrend", "HalfTrend", Up, first);
	HalfTrend:setWidth(instance.parameters.width1);
    HalfTrend:setStyle(instance.parameters.style1); 
 
	nexttrend=0;
   
end

-- Indicator calculation routine
function Update(period, mode)
 
	
    Low:update(mode);
	High:update(mode);
	
	if period == first then
	minhighprice=source.low[period];
	maxlowprice=source.high[period];
    end
	
    if period < first then
	return;
	end
	
	local min,max=mathex.minmax(source, period-Amplitude+1, period);
	trend[period]=trend[period-1];
	
	    if(nexttrend==1) then
       
         maxlowprice=math.max(min,maxlowprice);

         if(High.DATA[period]<maxlowprice and source.close[period]<source.low[period-1]) then
          
            trend[period]=1.0;
            nexttrend=0;
            minhighprice=max;
          end
       end
      if(nexttrend==0) then
        
         minhighprice=math.min(max,minhighprice);

         if(Low.DATA[period]>minhighprice and source.close[period]>source.high[period-1]) then
          
            trend[period]=0.0;
            nexttrend=1;
            maxlowprice=min;
           end
       end
      if(trend[period]==0.0) then
		 
				 if(trend[period-1]~=0.0) then
				  
					--up[period]=down[period-1];
					--up[period-1]=up[period];
					HalfTrend[period]=HalfTrend[period-1];
				
				 else
					
					--up[period]=math.max(maxlowprice,up[period-1]);
					HalfTrend[period]=math.max(maxlowprice,HalfTrend[period-1]);
				 end
			   
				-- down[period]=0.0;
        
      else
       
				 if(trend[period-1]~=1.0) then
				   
				--	down[period]=up[period-1];
				--	down[period-1]=down[period];
					HalfTrend[period]=HalfTrend[period-1]; 
				 
				 else
			  
					--down[period]=math.min(minhighprice,down[period-1]);
					HalfTrend[period]=math.min(minhighprice,HalfTrend[period-1]);
				  end
			   
                --  up[period]=0.0;
       end
     
	 
	 if trend[period]==0 then
	 HalfTrend:setColor(period, Up);
	 else
	 HalfTrend:setColor(period, Down);
	 end
end






