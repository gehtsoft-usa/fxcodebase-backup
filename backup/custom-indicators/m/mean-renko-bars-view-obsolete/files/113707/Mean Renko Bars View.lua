-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60743&start=50


--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Mean Renko Bars View");
    indicator:description("A chart where a new brick is added only when the price moves up or down by more than a predefined amount");
    indicator:requiredSource(core.Tick);
    indicator:type(core.View);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("instrument", "Instrument","", "EUR/USD");
    indicator.parameters:setFlag("instrument", core.FLAG_INSTRUMENTS);
    indicator.parameters:addString("frame", "Time Frame", "", "m15");
    indicator.parameters:setFlag("frame", core.FLAG_PERIODS);
    indicator.parameters:addBoolean("type","Price Type", "", true);
    indicator.parameters:setFlag("type", core.FLAG_BIDASK);
    indicator.parameters:addInteger("Step", "Step (Pips)", "", 2);
	indicator.parameters:addDouble("OpeningPricePercentage", "Opening Price Percentage (%)", "", 50, 0, 100);
	indicator.parameters:addDouble("ReversalPercentage", "Reversal Percentage (%)", "", 200, 0, 1000);
 
    indicator.parameters:addBoolean("Smoothed","Smoothed", "", true);  
    indicator.parameters:addBoolean("AlertChangeBarDirection","Change Bar Direction Alert", "Direction change, from up to down candle.", false);

    indicator.parameters:addGroup("Range");
    indicator.parameters:addDate("from", "From","", -1000);
    indicator.parameters:addDate("to", "To", "", 0);
    indicator.parameters:setFlag("to", core.FLAG_DATE_OR_NULL);
	 
end
 
local loading;
local instrument;
local frame;
local StepPips;
local history;
local open, high, low, close;
local iopen, ihigh, ilow, iclose;
local offer;
local offset;
local OneSecond;
local LastTime;
local OpeningPricePercentage;
local Smoothed;
local ReversalPercentage;
local Flag;
local Last;
local AlertChangeBarDirection = nil;
 
--open:setColor(current, Forward);	
-- initializes the instance of the indicator
function Prepare(onlyName)
    instrument = instance.parameters.instrument;
	 
	OpeningPricePercentage = instance.parameters.OpeningPricePercentage;
	--TrueHistory = instance.parameters.TrueHistory;
	ReversalPercentage = instance.parameters.ReversalPercentage;
	Smoothed = instance.parameters.Smoothed;
    frame = instance.parameters.frame;
    AlertChangeBarDirection = instance.parameters.AlertChangeBarDirection;
		
	if frame== "t1"then
	Flag=true;
	else
	Flag=false;
	end
	
    local name = profile:id() .. "(" .. instrument .. "." .. frame .. ")";
    instance:name(name);

    if onlyName then
        return ;
    end

    -- check whether the instrument is available
    local offers = core.host:findTable("offers");
    local enum = offers:enumerator();
    local row;

    row = enum:next();
    while row ~= nil do
        if row.Instrument == instrument then
            break;
        end
        row = enum:next();
    end

    assert(row ~= nil, "Instrument not found");

    offer = row.OfferID;

    instance:initView(instrument, row.Digits, row.PointSize, false, instance.parameters.to == 0);

    loading = true;
    history = core.host:execute("getHistory", 1000, instrument, frame, instance.parameters.from, instance.parameters.to, instance.parameters.type);
    if instance.parameters.to == 0 then
        core.host:execute("subscribeTradeEvents", 2000, "offers");
    end
	if Flag then
    StepPips = instance.parameters.Step * history:pipSize();
	else
	 StepPips = instance.parameters.Step * history.close:pipSize();
	end
	

	
	
    core.host:execute("setStatus", "Loading");
    open = instance:addStream("open", core.Line, name .. "." .. "open", "open", 0, 0, 0);
    high = instance:addStream("high", core.Line, name .. "." .. "high", "high", 0, 0, 0);
    low = instance:addStream("low", core.Line, name .. "." .. "low", "low", 0, 0, 0);
    close = instance:addStream("close", core.Line, name .. "." .. "close", "close", 0, 0, 0);
	instance:createCandleGroup("Renko", "Renko", open, high, low, close, nil, frame);
	
 

	OneSecond=1/86400;
 
end

 
function Update(period)
    	
end

function AsyncOperationFinished(cookie, success, message, message1, message2)
    if cookie == 1000 then
        handleHistory();
        core.host:execute("setStatus", "");
    elseif cookie == 2000 then
        if message == offer then
           handleUpdate();		 
        end
    end
end

local lastDirection;

function calcFirstValueValue(current, i)
    local source;
    if Flag then
	source= history;
	else
	source= history.close;
	end
    local open_val = math.floor(source[0] / StepPips) * StepPips;
    while source[i] > open_val + StepPips do
        current = current + 1;
        if current==0 then
            instance:addViewBar(source:date(0));
        else
            instance:addViewBar(open:date(current-1)+OneSecond);
        end
        open[current] = open_val;
        close[current] = open[current]+StepPips;
        low[current] = open[current];
        high[current] = close[current];
        lastDirection = 1;
        open_val=open_val+StepPips;
		
	
    end
    open_val = math.floor(source[0] / StepPips) * StepPips;
    while source[i] < open_val - StepPips do
        current = current + 1;
        if current==0 then
            instance:addViewBar(source:date(0));
        else
            instance:addViewBar(open:date(current-1)+OneSecond);
        end
        open[current] = open_val;
        close[current] = open[current]-StepPips;
        high[current] = open[current];
        low[current] = close[current];
        lastDirection = -1;
        open_val=open_val-StepPips;
		
	 
    end
    
    return current;
end

 


function calcValue(current, i)
    if current == -1 then
        return calcFirstValueValue(current, i);
    end
	
	local min,max;
    local source;
    if Flag then
	source= history;
	else
	source= history.close;
	end
  -- local diff = history.close[i] - history.open[i];
  --  local diff = close[current] - open[current];
  --  if diff > 0 or (diff == 0 and lastDirection == 1) then
  if  lastDirection == 1 then
        --lastDirection = 1;
        while source[i] > close[current] + StepPips do
            current = current + 1;
            if open:date(current-1) < source:date(i) then
                instance:addViewBar(source:date(i));
            else
                instance:addViewBar(open:date(current-1)+OneSecond);
            end
          
		 	  if Smoothed then	 	
					 if close[current-1] > open[current-1] then
							open[current] = open[current - 1]  +(StepPips/100)*OpeningPricePercentage;
					   else
							open[current] = close[current - 1]  + (StepPips/100)* OpeningPricePercentage;
					  end
			  else
					if close[current-1] > open[current-1] then
						open[current] = open[current - 1]  +(StepPips/100)*OpeningPricePercentage;
				   else
						open[current] = open[current - 1] - (StepPips/100)* OpeningPricePercentage;
				  end
			  end
			  
			   close[current]=open[current]+StepPips;

						
			 
			low[current] = math.min(open[current],close[current] );			
           
            high[current] =  math.max(open[current],close[current] );
		
		
			 
		
		
		
        end
        if source[i] < close[current] - (ReversalPercentage/100) * StepPips then
		lastDirection = -1;

            while source[i]<close[current] - StepPips do
                current = current + 1;
                if open:date(current-1) < source:date(i) then
                 instance:addViewBar(source:date(i));
                 ShowAlertOnChangeDirection(instrument, close[current], source:date(i));
                else
                 instance:addViewBar(open:date(current-1)+OneSecond);
                end
				
				if Smoothed then	
					if close[current-1] > open[current-1] then
						open[current] = close[current - 1] - (StepPips/100)*OpeningPricePercentage;
					else
						open[current] = open[current - 1] -  (StepPips/100)* OpeningPricePercentage;
					end
				else
				    	if close[current-1] > open[current-1] then
						open[current] = open[current - 1] + (StepPips/100)*OpeningPricePercentage;
					else
						open[current] = open[current - 1] -  (StepPips/100)* OpeningPricePercentage;
					end
				end
				 close[current]=open[current]-StepPips;
				 
					   low[current] = math.min(open[current],close[current] );			
				   
					high[current] =  math.max(open[current],close[current] );
				
            end  
        end
    end
    
    --if diff < 0 or (diff == 0 and lastDirection == -1) then
	if lastDirection == -1 then
       -- lastDirection = -1;
        while source[i] < close[current] - StepPips do
            current = current + 1;
            if open:date(current-1) < source:date(i) then
                instance:addViewBar(source:date(i));
            else
                instance:addViewBar(open:date(current-1)+OneSecond);
            end
			
			if Smoothed then	
			  if close[current-1] < open[current-1] then
						open[current] = open[current - 1] -(StepPips/100)*OpeningPricePercentage ;
				  else
					   open[current] = close[current - 1] - (StepPips/100)*OpeningPricePercentage;
				  end
			  else
			      if close[current-1] < open[current-1] then
						open[current] = open[current - 1] -(StepPips/100)*OpeningPricePercentage ;
				  else
					   open[current] = open[current - 1] + (StepPips/100)*OpeningPricePercentage;
				  end
			  end
			  
			   close[current]=open[current]-StepPips;
			   
	 		      
		     low[current] = math.min(open[current],close[current] );			
           
            high[current] =  math.max(open[current],close[current] );
			
		
        end
		
			
           
        
        if source[i] > close[current] +  (ReversalPercentage/100) * StepPips  then
		  lastDirection = 1;
            while source[i] > close[current] + StepPips do
                current = current + 1;
                if open:date(current-1) < source:date(i) then
                 instance:addViewBar(source:date(i));
                else
                 instance:addViewBar(open:date(current-1)+OneSecond);
                end
				
				if Smoothed then	
				   if close[current-1] < open[current-1] then
						open[current] = close[current - 1]+(StepPips/100)*OpeningPricePercentage;
					else
						open[current] = open[current - 1]+  (StepPips/100)* OpeningPricePercentage;
					end
				else
				  if close[current-1] < open[current-1] then
						open[current] = open[current - 1]-(StepPips/100)*OpeningPricePercentage;
					else
						open[current] = open[current - 1]+  (StepPips/100)* OpeningPricePercentage;
					end
				end
				
				close[current]=open[current]+StepPips;
				

             low[current] = math.min(open[current],close[current] );			
           
            high[current] =  math.max(open[current],close[current] );	
			
		
            end  
        end
		
    end
	
			
				 if low[current] == 0  then
                 low[current] =math.min(open[current],close[current]);	
				 end
			   
			    low[current] = math.min(low[current],source[i]  );
					
                
                high[current] =math.max(high[current],source[i] );		
				
		
    return current;
end
 --[[
function handleHistory()

    local i;
   local current = open:size() - 1;
	
    for i = 1,  history:size() - 2, 1 do
        current = calcValue(current, i);
    end
    loading = false;
   LastTime=history:date(history:size()-2);
    Last=open:size() - 2;
end

function handleUpdate()
    if loading or  history:size() <= 0  then
	return;
	end
	

	
      if history:date(history:size()-2)~=LastTime  then
	    LastTime=history:date(history:size()-2);
	   
        calcValue(open:size() - 1, history:size() - 2);       
	    Last=open:size() - 2;
     end
	 
 
end]]

function ShowAlertOnChangeDirection(instrument, price, time)
    if AlertChangeBarDirection == true then
        terminal:alertMessage (instrument, price, "Candle changed directon, from up to down.", time);
    end
end


function handleHistory()
    local s = history:size() - 1;
    local i;
    local current = open:size() - 1;
    for i = 1, s, 1 do
        current = calcValue(current, i);
    end
    loading = false;
    LastTime=history:date(history:size()-1);
end

function handleUpdate()
    if not loading and history:size() > 0 then
      if history:date(history:size()-1)~=LastTime then
        calcValue(open:size() - 1, history:size() - 2);
        LastTime=history:date(history:size()-1);
      end  
    end 
end


 


