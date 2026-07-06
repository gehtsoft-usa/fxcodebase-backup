-- Available @  https://fxcodebase.com/code/viewtopic.php?f=17&t=76179

-- +------------------------------------------------------------------------------------------------+
-- |                                                              Copyright 2025, Gehtsoft USA LLC  | 
-- |                                                                         http://fxcodebase.com  |
-- |                                                               Paypal:  https://goo.gl/9Rj74e   |
-- +------------------------------------------------------------------------------------------------+
-- |                                                                   Developed by : Mario Jemic   |                    
-- |                                                                       mario.jemic@gmail.com    |
-- |                                                                       https://mario-jemic.com/ | 
-- |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
-- |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  Cryptocurrency |  Network             |  Address                                              |
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
-- |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
-- |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
-- |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- +-----------------+----------------------+-------------------------------------------------------+ 
function Init()
    indicator:name("Simplified Level and Strength");
    indicator:description("Simplified Level and Strength");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
 
	
	
    indicator.parameters:addGroup("Calculation");
	indicator.parameters:addInteger("Period", "Period", "Period", 20);
	indicator.parameters:addDouble("Deviations", "Deviations", "Deviations", 2);			
	indicator.parameters:addBoolean("Average", "Average", "Average", false); 
	indicator.parameters:addBoolean("SignalMode", "Signal Mode", "Signal Mode", false); 	
	
     indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("Up", "Up Color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("Down", "Down Color", "", core.rgb(255, 0, 0)); 
    indicator.parameters:addInteger("Size", "Size", "", 20); 	
 
	
	
end
local pauto =  "(%a%a%a)/(%a%a%a)";
local Instrument;
local Count;
local SourceData={};
local List={}; 
local Point={};  
local Index={}; 
local loading={};
local Indicator={};

local price={};
local Price={};
-- Routine
function Prepare(nameOnly)
    source = instance.source;
    first = source:first();
    host = core.host;
    dayoffset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");
    Up=instance.parameters.Up;
    Down=instance.parameters.Down;	
	Period=instance.parameters.Period;
	Deviations=instance.parameters.Deviations;
	Average=instance.parameters.Average;
	Size=instance.parameters.Size;
	SignalMode=instance.parameters.SignalMode;

    local name = profile:id() .. "(".. Period  .. ", "..  Deviations.. ")";
    instance:name(name);
	if nameOnly then
		return;
	end
	
	
	crncyA, crncyB = string.match(source:instrument(), pauto);	
	
	local list, count,point= getInstrumentList()
	
	
	Count=0;
	for i= 1, count, 1 do	
		crncy1, crncy2 = string.match(list[i], pauto);
		if crncy1== crncyA or  crncy2==crncyA 
		or crncy1== crncyB or  crncy2==crncyB 
		
		then
		    Count=Count+1;
		
			if  crncyA == crncy1 then
			Index[Count]= 1;
			elseif  crncyA == crncy2 then
			Index[Count]= -1;
			elseif  crncyB == crncy1 then
			Index[Count]= -2;
			elseif  crncyB == crncy2 then
			Index[Count]= 2;
			else
			Index[Count]= 0;			
			end
			Point[Count]=point[i];  
			List[Count]=list[i];   
		end
   end
   
   for i= 1, Count , 1 do  
   
   SourceData[i] = core.host:execute("getSyncHistory",List[i], source:barSize(), source:isBid(), Period, 2000 +i, 1000+i);
   loading[i]=true;

	Indicator[i] = core.indicators:create("BB", SourceData[i].close, Period,Deviations);	 
   end
   


    
    Price[1] = instance:addInternalStream(0, 0);		 
    Price[2] = instance:addInternalStream(0, 0);	
	
    price[1] = instance:addInternalStream(0, 0);		 
    price[2] = instance:addInternalStream(0, 0);	

        up = instance:createTextOutput("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Bottom, Up, first);
        down = instance:createTextOutput("Down", "Down", "Wingdings", Size, core.H_Center, core.V_Top, Down, first);	
   
    if SignalMode then
	Signal= instance:addStream("Signal", core.Bar, name, "Signal", Up, 0) 
    Signal:setPrecision(math.max(2, instance.source:getPrecision()));	
    else
    Signal = instance:addInternalStream(0, 0);	
	end
	
end


function getInstrumentList()
    local list={};
	local point={};
	
    local count = 0;	
    local row, enum;	
	
    enum = core.host:findTable("offers"):enumerator();
    row = enum:next();
    while row ~= nil do
	    
        count = count + 1;
        list[count] = row.Instrument;
		point[count] = row.PointSize;
		 
        row = enum:next();
    end
	
	 
    return list, count,point;
end

-- Indicator calculation routine
 
function Update(period )

 
   
	
    if period  < source:first()	
	or Count==0 	
	then
    return;		
    end	
	p={};
     
	local Flag=false;
    for i= 1, Count , 1 do 
	    p[i]= Initialization(period,i)		
	
		if loading[i] or p[i]==false  then		
		Flag=true;
		end
	end
		
	
	if Flag then
	return;
	end	
	
	
    Signal[period]=0;
    
	up:setNoData(period);
	down:setNoData(period);	
	
    Price[1][period]=0; 
    Price[2][period]=0; 
	
    for i= 1, Count , 1 do 			
    Indicator[i]:update(mode); 
	end
    
	local Count1=0;
	local Count2=0;

	
    for i= 1, Count , 1 do 		

	        if p[i]> 0 and p[i] ~= false and  Indicator[i].BL:hasData(p[i]) then
				if math.abs(Index[i]) ==1 then
                Count1=Count1+1;	
				
							if 	 Index[i] > 0 then
											Price[1][period]= Price[1][period]+ (SourceData[i].close[p[i]]-Indicator[i].BL[p[i]]) / ((Indicator[i].TL[p[i]]- Indicator[i].BL[p[i]])/100)	
											 		
									else
											Price[1][period]= Price[1][period]+ (Indicator[i].TL[p[i]]-SourceData[i].close[p[i]]) / ((Indicator[i].TL[p[i]]- Indicator[i].BL[p[i]])/100)	
											 
									end						
				
				elseif math.abs(Index[i]) ==2 then				
                Count2=Count2+1;
				
				
									if 	 Index[i] > 0 then
											Price[2][period]= Price[2][period]+ (SourceData[i].close[p[i]]-Indicator[i].BL[p[i]]) / ((Indicator[i].TL[p[i]]- Indicator[i].BL[p[i]])/100)	
											 		
									else
											Price[2][period]= Price[2][period]+ (Indicator[i].TL[p[i]]-SourceData[i].close[p[i]]) / ((Indicator[i].TL[p[i]]- Indicator[i].BL[p[i]])/100)	
											 
									end							
				end
				
				
            end	
    end				
 

			
				
				
				
		 
 
      
    Price[1][period]=Price[1][period]/Count1;			
    Price[2][period]=Price[2][period]/Count2;	
   
	if Average and period > Period then
    price[1][period]=mathex.avg(Price[1], period-Period/2+1, period);			
    price[2][period]=mathex.avg(Price[2], period-Period/2+1, period);	
    else
    price[1][period]= Price[1][period]		
    price[2][period]=Price[2][period]		
	end
 
 
 
 
        if price[1][period] > price[2][period]
		and price[1][period-1] <= price[2][period-1]
		then
        up:set(period, source.low[period], "\217");
		Signal[period]=1;
		elseif price[1][period] < price[2][period]
		and price[1][period-1] >= price[2][period-1]
		then		
        down:set(period, source.high[period], "\218");	
		Signal[period]=-1;		
        end		
end





function   Initialization(period,id)

    local Candle;
    Candle = core.getcandle(source:barSize(), source:date(period), dayoffset, weekoffset);
  
    if loading[id] or SourceData[id]:size() == 0  then
        return false;
    end

    
    if period < source:first() then
        return false;
    end

    local P = core.findDate(SourceData[id], Candle, false);
	 

    -- candle is not found
    if P < 0    then
        return false;
	else return P;	
    end
			
end	




-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
     local j;	 
	local Flag = false;	
	local Number=0;	
	
	
	
    for j = 1, Count, 1 do
		
			  if cookie == (1000+j) then
			  loading[j] = true;
		      elseif  cookie == (2000+j) then
			  loading[j] = false;  
			  instance:updateFrom(0);		 
              end
			  
		if loading[j] then
		Number=Number+1;
		Flag=true;
		end	 

		  
		if Flag then
		core.host:execute ("setStatus", " Loading ".. (Count-Number) .."/" .. Count);
		else
		core.host:execute ("setStatus", " Loaded ".. (Count-Number) .."/" .. Count);
		end
			  
	end    
   
        
		return core.ASYNC_REDRAW ;
end
-- Available @  https://fxcodebase.com/code/viewtopic.php?f=17&t=76179

-- +------------------------------------------------------------------------------------------------+
-- |                                                              Copyright 2025, Gehtsoft USA LLC  | 
-- |                                                                         http://fxcodebase.com  |
-- |                                                               Paypal:  https://goo.gl/9Rj74e   |
-- +------------------------------------------------------------------------------------------------+
-- |                                                                   Developed by : Mario Jemic   |                    
-- |                                                                       mario.jemic@gmail.com    |
-- |                                                                       https://mario-jemic.com/ | 
-- |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
-- |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  Cryptocurrency |  Network             |  Address                                              |
-- +-----------------+----------------------+-------------------------------------------------------+
-- |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
-- |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
-- |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
-- |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
-- +-----------------+----------------------+-------------------------------------------------------+ 