
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61641

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                Patreon :  https://goo.gl/GdXWeN  |  
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+


function Init()
    indicator:name("Three Line Break View");
    indicator:description("Three Line Break View");
    indicator:requiredSource(core.Tick);
    indicator:type(core.View);

    indicator.parameters:addGroup("Calculation");
	indicator.parameters:addString("Instrument","Instrument","", "EUR/USD");
    indicator.parameters:setFlag("Instrument", core.FLAG_INSTRUMENTS);
	
	
	indicator.parameters:addString("TF", "Base Time Frame", "Base Time Frame" , "H1");
     indicator.parameters:setFlag("TF", core.FLAG_PERIODS);

	
	indicator.parameters:addInteger("N", "Number of periods", "", 3, 1, 100);
	
	indicator.parameters:addBoolean("type", "Price Type","", true);
    indicator.parameters:setFlag("type", core.FLAG_BIDASK);
   


indicator.parameters:addGroup("Range");
   indicator.parameters:addDate("from", "From","", -1000);
   indicator.parameters:addDate("to", "To","", 0);
  indicator.parameters:setFlag("to", core.FLAG_DATE_OR_NULL);

end


local loading;
local History;
local open, high, low, close, volume;
local offer;
local LastTime;
local Instrument;
local N;
local TF;
local OneSecond;

-- initializes the instance of the indicator
function Prepare(onlyName)

    N = instance.parameters.N;
	TF = instance.parameters.TF;
	Instrument = instance.parameters.Instrument;

    local name = profile:id().. ", " .. Instrument .. ", " .. TF .. ", "..  N
    instance:name(name);

    if onlyName then
        return ;
    end
	

    -- check whether the instrument is available
    local offers = core.host:findTable("offers");
    local enum = offers:enumerator();
    local row=nil;

    row = enum:next();
    while row ~= nil do
        if row.Instrument == Instrument then
            break;
        end
        row = enum:next();
    end
	


    assert(row ~= nil, "Selected instrument is not available");
    offer = row.OfferID;

   

 History = core.host:execute("getHistory", 1000, Instrument, TF, instance.parameters.from, instance.parameters.to, instance.parameters.type);
 loading = true;
 
 	
   if instance.parameters.to == 0 then 
   core.host:execute("subscribeTradeEvents", 2000, "offers");  
	end
    core.host:execute("setStatus", "Loading");

    instance:initView(Instrument, row.Digits, row.PointSize, instance.parameters.type, instance.parameters.to == 0);
	
    open = instance:addStream("open", core.Line, name .. "." .. "Open", "open", 0, 0, 0);
    high = instance:addStream("high", core.Line, name .. "." .. "High", "high", 0, 0, 0);
    low = instance:addStream("low", core.Line, name .. "." .. "Low", "low", 0, 0, 0);
    close = instance:addStream("close", core.Line, name .. "." .. "Close", "close", 0, 0, 0);
	volume = instance:addStream("volume", core.Line, name .. "." .. "Volume", "Volume", 0, 0, 0);

    instance:createCandleGroup("candle", "candle", open, high, low, close, volume , TF);
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


function calcValue( period, Index)
    
	 
	  		
   if  Index==-1   then 	 
	  
	    Index = Index + 1;	
        if Index==0 then
            instance:addViewBar(History:date(0));
        else
            instance:addViewBar(open:date(Index-1)+OneSecond);
        end
	
		open[Index] =  History.open[period]; 
		close[Index]=History.close[period];
	    volume[Index] = History.volume[period];  
		
		if close[Index]> open[Index] then
		low[Index] = History.open[period]; 
		high[Index] = History.close[period]; 
		else
		low[Index] = History.close[period]; 
		high[Index] = History.open[period]; 
		end
		
	 	return Index;    
    
	elseif Index<=N	 then 
	
	            if  History.close[period] < high[Index]--mathex.max(high:first(), high:size()-1) 
				and  History.close[period] > low[Index] --mathex.min(low:first(), low:size()-1) 
				then
					volume[Index]=volume[Index]+ History.volume[period];  
					return Index;   		
					
				else   
					
					Index=Index+1;
					
					 if open:date(Index-1) < History:date(period) then
						instance:addViewBar(History:date(period));
					else
						instance:addViewBar(open:date(Index-1)+OneSecond);
					end
					
					volume[Index] = History.volume[period];  
					
					
					open[Index] = close[Index-1]; 
					close[Index]=History.close[period];
					
					if close[Index]> open[Index] then
					low[Index] = open[Index]; 
					high[Index] = close[Index]; 
					else
					low[Index] =close[Index]; 
					high[Index] =open[Index]; 
			     	end	
					
					return Index;
                end
	
	
		
    else
	
	min = mathex.min(low, Index-N+1,Index);
	max = mathex.max(high, Index-N+1,Index);
	
				if  History.close[period] <  max 
				and  History.close[period] > min 
				then
					volume[Index] =volume[Index]+ History.volume[period];  
					return Index;   		
					
				else   
					
					Index=Index+1;
					
					 if open:date(Index-1) < History:date(period) then
						instance:addViewBar(History:date(period));
					else
						instance:addViewBar(open:date(Index-1)+OneSecond);
					end
					
					volume[Index] = History.volume[period];  
					
					
					open[Index] = close[Index-1]; 
					close[Index]=History.close[period];
					
					if close[Index]> open[Index] then
					low[Index] = open[Index]; 
					high[Index] =close[Index]; 
					else
					low[Index] = close[Index]; 
					high[Index] = open[Index]; 
					
					 return Index;   
					 
				end	
		end 
		 
	end

     return Index;  
 end

function handleHistory()
    	
	local current = open:size() - 1;
	local Last=History:size()-2;
    local i; 
	
    for i = 1, Last, 1 do
        current= calcValue(i, current);
    end
	
	 loading = false; 
	 LastTime=History:date(History:size()-2);
end

function handleUpdate()
     if not loading and History:size() > 0 then
      if History:date(History:size()-2)~=LastTime then
        calcValue( History:size() - 2,open:size() - 1);
        LastTime=History:date(History:size()-2);
      end  
    end 
end