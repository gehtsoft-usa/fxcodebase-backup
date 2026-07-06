-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=9673
-- Id: 5275

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--|                    Patreon : https://www.patreon.com/mariojemic  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Dow Jones FXCM Dollar Index");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addGroup("Display");
    indicator.parameters:addColor("color", "Index Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
end

local source;
local Instrument={"EUR/USD" ,"USD/JPY","GBP/USD","AUD/USD"};
local usdx;
local loading={};
local Source={};
local dayoffset;
local weekoffset;
local Weight={ 7479,812150,6410,9787};
local Inverse={};
local pattern = "(%a%a%a)/(%a%a%a)";
-- prepare the indicator
function Prepare(nameOnly)
    source = instance.source;
    
    local name = profile:id();
    instance:name(name);
    if nameOnly then
        return;
    end
	
	local First, Second;	
	
	dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");
	
	for i= 1 , 4, 1 do
	Source[i] = core.host:execute("getSyncHistory", Instrument[i], source:barSize(), source:isBid(), 0, 100+i, 200+i);
	loading[i]=true;
	
		First, Second= string.match( Instrument[i], pattern);
		if First== "USD" then
		Inverse[i]= true;
		else
		Inverse[i]= false;
		end
	end
	
    usdx = instance:addStream("usdx", core.Line, name .. ".usdx", "usdx", instance.parameters.color, 0);
    usdx:setPrecision(math.max(2, instance.source:getPrecision()));
	usdx:setWidth(instance.parameters.width);
    usdx:setStyle(instance.parameters.style);
end


-- the function which is called to calculate the period
function Update(period)


  local Flag= true
  local p={};

    for i= 1 , 4 ,1 do
    
        if loading[i]then
		Flag=false;        		
		end
    end
	
	
	if not Flag then
	return;
	end
	
	Flag= true
	
	for i= 1, 4, 1 do	
	p[i] = Initialization(i,period);
	   if p[i] == false then
		Flag=false;        		
		end
	end
	
	if not Flag then
	return;
	end
	
	
	local x = 0;
        for i = 1, 4, 1 do
		
		   if Inverse[i] then
		    x =   x+    (20000 -  Weight[i]/Source[i].close[p[i]] ) ;	
		   else
		    x =   x+    (20000 - Source[i].close[p[i]] * Weight[i]) ;	
		   end
          	               
					 
        end
        usdx[period] = x/4;

end

function   Initialization(id,period)

    local Candle;
    Candle = core.getcandle(source:barSize(), source:date(period), dayoffset, weekoffset);

  
    if loading[id] or Source[id]:size() == 0 then
        return false ;
    end

    
    if period < source:first() then
        return false;
    end

    local p = core.findDate(Source[id], Candle, false);

    -- candle is not found
    if p < 0 then
        return false;
	else return p;	
    end
	
end	


 
 
 -- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)


    local Flag= true

    for i= 1 , 4 ,1 do
		if cookie == 100+i then
			loading[i] = false;
		elseif cookie == 200 +i then
			loading[i] = true;
			Flag=false;
		end
	end
	
	if Flag then
	instance:updateFrom(0)
	end
	
	return core.ASYNC_REDRAW ;
end

