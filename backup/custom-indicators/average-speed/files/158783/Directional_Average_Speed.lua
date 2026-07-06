-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=32557&p=55455#p55455

-- +------------------------------------------------------------------------------------------------+
-- |                                                            Copyright © 2025, Gehtsoft USA LLC  | 
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
    indicator:name("Directional Average Speed");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Period", "Period", "", 3);
    indicator.parameters:addBoolean("Absolute", "Use absolute value", "", true);	
    indicator.parameters:addBoolean("Cumulative", "Cumulative", "", false);		

    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("UPclr1", "Up Candle Average Speed Up color", "Up color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("UPclr2", "Up Candle Average Speed Dn color", "Dn color", core.rgb(0, 200, 0));
	
    indicator.parameters:addColor("DNclr1", "Down Candle Average Speed Up color", "Up color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("DNclr2", "Down Candle Average Speed Dn color", "Dn color", core.rgb(200, 0, 0));	
	
    indicator.parameters:addInteger("width", "Line Width", "Width of the line", 2, 1, 5)
    indicator.parameters:addInteger("style", "Style", "Style of the oscillator line", core.LINE_SOLID)
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);	
end

local first;
local source = nil;
local Period;
local Speed;
local AS=nil;
local pipSize;

function Prepare(nameOnly)
    source = instance.source;
    Period=instance.parameters.Period;
	Absolute=instance.parameters.Absolute;
	Cumulative=instance.parameters.Cumulative;

    local name = profile:id() .. "(" .. source:name() .. ", " .. instance.parameters.Period .. ")";
    instance:name(name);
    if nameOnly then
        return;
    end
    Up_Speed = instance:addInternalStream(0, 0);
    Down_Speed = instance:addInternalStream(0, 0);
	
	first = source:first()+1 +Period;
	
	if not Cumulative then
    ASU = instance:addStream("ASU", core.Line, name .. ".ASU", "ASU", instance.parameters.UPclr1, first);
    ASU:setPrecision(math.max(2, instance.source:getPrecision()));
    ASU:setWidth(instance.parameters.width)
    ASU:setStyle(instance.parameters.style)	

	
    ASD = instance:addStream("ASD", core.Line, name .. ".ASD", "ASD", instance.parameters.DNclr1, first);
    ASD:setPrecision(math.max(2, instance.source:getPrecision()));	
    ASD:setWidth(instance.parameters.width)
    ASD:setStyle(instance.parameters.style)	
	
    else
	
	
	ASU = instance:addInternalStream(0, 0);
	ASD = instance:addInternalStream(0, 0);	
	
    AS = instance:addStream("AS", core.Bar, name .. ".AS", "AS", instance.parameters.UPclr1, first);
    AS:setPrecision(math.max(2, instance.source:getPrecision())); 
    end	
	
    pipSize=source:pipSize();
end

function Update(period, mode)
   if period<source:first()+1 then
   return;
   end
   
    local dt=source:date(period)-source:date(period-1);
	
	
	if Absolute then
		if source[period] > source[period-1] then 
		Up_Speed[period]=math.abs(source[period]-source[period-1])/(pipSize*dt);
		Down_Speed[period]=0;	
		else
		Up_Speed[period]=0;
		Down_Speed[period]=math.abs(source[period]-source[period-1])/(pipSize*dt);	
		end
	else
		if source[period] > source[period-1] then 
		Up_Speed[period]=(source[period]-source[period-1])/(pipSize*dt);
		Down_Speed[period]=0;	
		else
		Up_Speed[period]=0;
		Down_Speed[period]=(source[period]-source[period-1])/(pipSize*dt);	
		end	
    end
	
	
    if period<=first  then
	return;
	end
	
    ASU[period]=mathex.avg(Up_Speed, period-Period+1, period);
    ASD[period]=mathex.avg(Down_Speed, period-Period+1, period);
	
	
    if not Cumulative then
           if ASU[period]>=ASU[period-1] then
		  ASU:setColor(period, instance.parameters.UPclr1);
		 else
		  ASU:setColor(period, instance.parameters.UPclr2);
		 end	
		
		  if ASD[period]>=ASD[period-1] then
		  ASD:setColor(period, instance.parameters.DNclr1);
		 else
		  ASD:setColor(period, instance.parameters.DNclr2);
		 end	

    else  
	
	    if Absolute then
		AS[period]=ASU[period] -ASD[period]
		else
		AS[period]=ASU[period] +ASD[period]		
		end
		
		  if AS[period]>=AS[period-1] then
		  AS:setColor(period, instance.parameters.UPclr1);
		 else
		  AS:setColor(period, instance.parameters.DNclr2);
		 end			

    end	
 
		 
end

-- Available @ https://fxcodebase.com/code/viewtopic.php?f=17&t=32557&p=55455#p55455

-- +------------------------------------------------------------------------------------------------+
-- |                                                            Copyright © 2025, Gehtsoft USA LLC  | 
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