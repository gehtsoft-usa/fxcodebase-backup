-- Id: 20585
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65746

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

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Standard Relative Performance indicator");
    indicator:description("Standard Relative Performance indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);	
	
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addString("Instrument1" ,"1. Instrument (compared with)", "", "EUR/USD");
    indicator.parameters:setFlag("Instrument1" , core.FLAG_INSTRUMENTS);
	
	
	 indicator.parameters:addString("Instrument2" , "2. Instrument (compare with)", "", "SPX500");
    indicator.parameters:setFlag("Instrument2" , core.FLAG_INSTRUMENTS);
 
 
 
   	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
	
end

 

 
 
local dayoffset,weekoffset;
local Source ={};
  
local first;
local source = nil;
local loading={}; 
 
local Number=2 ; 
local Instrument={}; 
-- Routine
 function Prepare(nameOnly)   
 
    for i= 1, Number,1 do 
    Instrument[i]=  instance.parameters:getString ("Instrument"..i);
    end
	
	
	
    local name = profile:id() .. "(" ..  instance.source:name().. ", " .. Instrument[1] .. ", " ..  Instrument[2]   .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
  
	  
    source = instance.source; 
	dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");	

 
	
	local i;
    for  i = 1, Number, 1 do 
		
			Source[i] = core.host:execute("getSyncHistory",Instrument[i], source:barSize(), source:isBid(), 1, 200+i, 100+i);
		    loading[i]=true;
	end

 
  
    RP = instance:addStream("RP" , core.Line, " RP "," RP ",instance.parameters.color, source:first());
    RP:setPrecision(math.max(2, instance.source:getPrecision()));
	RP:setWidth(instance.parameters.width);
    RP:setStyle(instance.parameters.style);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period, mode)
  
  
    local p={};
    local Flag=false;
  
	for i= 1, Number, 1 do
	p[i]= Initialization(period,i)	
		if loading[i] or p[i]== false  then		
		Flag=true;
		end
	end
		
	
	if Flag then
	return;
	end	
	
	 --RP = ( stock_close / index_close ) * 100
	 
	 RP[period]= ( Source[1].close[p[1]] / Source[2].close[p[2]] ) * 100;

end




function   Initialization(period,id)

    local Candle;
    Candle = core.getcandle(source:barSize(), source:date(period), dayoffset, weekoffset);
  
    if loading[id] or Source[id]:size() == 0  then
        return false;
    end

    
    if period < source:first() then
        return false;
    end

    local P = core.findDate(Source [id], Candle, false);
	 

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
	local Count=0;	
	
	
	
    for j = 1, Number, 1 do
		
			  if cookie == (100+j) then
			  loading[j] = true;
		      elseif  cookie == (200+j) then
			  loading[j] = false; 	 
              end
			  
		if loading[j] then
		Count=Count+1;
		Flag=true;
		end	 
   end
   
   
		  
		if Flag then
		core.host:execute ("setStatus", " Loading ".. (Number-Count) .."/" .. Number);
		else
		core.host:execute ("setStatus", " Loaded ".. (Number-Count) .."/" .. Number);
		instance:updateFrom(0);	
		end
			  
	    
   
        
		return core.ASYNC_REDRAW ;
end
 


