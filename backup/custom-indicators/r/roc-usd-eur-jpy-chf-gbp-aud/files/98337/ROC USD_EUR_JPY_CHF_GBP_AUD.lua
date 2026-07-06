-- Id: 13505
-- More information about this indicator can be found at:
-- hhttp://fxcodebase.com/code/viewtopic.php?f=17&t=61758

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("ROC USD_EUR_JPY_CHF_GBP");
    indicator:description("ROC USD_EUR_JPY_CHF_GBP");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addInteger("Period", "Period", "Period", 20);
    indicator.parameters:addInteger("TotalDevise", "TotalDevise", "TotalDevise", 7);
	
    indicator.parameters:addColor("USD_color", "Color of USD", "Color of USD", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
    indicator.parameters:addColor("EUR_color", "Color of EUR", "Color of EUR", core.rgb(255, 128, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	
    indicator.parameters:addColor("JPY_color", "Color of JPY", "Color of JPY", core.rgb(128, 255, 0));
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);
	
	
    indicator.parameters:addColor("CHF_color", "Color of CHF", "Color of CHF", core.rgb(0, 0, 0));
	indicator.parameters:addInteger("width4", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style4", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style4", core.FLAG_LINE_STYLE);
	
	
    indicator.parameters:addColor("GBP_color", "Color of GBP", "Color of GBP", core.rgb(128, 128, 128));
	indicator.parameters:addInteger("width5", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style5", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style5", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addColor("AUD_color", "Color of AUD", "Color of AUD", core.rgb(255, 255, 128));
	indicator.parameters:addInteger("width6", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style6", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style6", core.FLAG_LINE_STYLE);
	
	
    indicator.parameters:addColor("ROC_color", "Color of ROC", "Color of ROC", core.rgb(0, 0, 255));
	
	
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;
local TotalDevise;

local first;
local source = nil;

-- Streams block
local Out={};

local Instrument={};
local Source={};
local loading={};
local Data={}
local PointSize={};
local dayoffset, weekoffset;

local pauto =  "(%a%a%a)/(%a%a%a)";
local Nil;

local Instrument={ "EUR/USD",  "EUR/JPY", "USD/JPY","GBP/USD", "EUR/GBP", "GBP/JPY", "GBP/CHF", "CHF/JPY",   "EUR/CHF" ,"USD/CHF" , "AUD/USD", "EUR/AUD", "GBP/AUD", "AUD/CHF", "AUD/JPY"}
local Color={};
local Style={};
local Width={};
local Number=15;
-- Routine
function Prepare(nameOnly)
    Period = instance.parameters.Period;
    TotalDevise = instance.parameters.TotalDevise;
	
	dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");	
	
    source = instance.source;
    first = source:first();
    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ", " .. tostring(TotalDevise) .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
	
	local id=0;
	
	for i = 1 , Number , 1 do   
	 
	 if core.host:findTable("offers"):find("Instrument", Instrument[i]).Instrument == nil then
	 error(" Please Subscribe to " .. Instrument[i] );
     end	
	 
	 id=id+1;
	 Source[i] = core.host:execute("getSyncHistory",Instrument[i], source:barSize(), source:isBid(), Period, 200+id, 100+id);
	 PointSize[i]= core.host:findTable("offers"):find("Instrument", Instrument[i]).PointSize;	
	loading[i]=true;	  
	end 


    if (not (nameOnly)) then
        Out[1] = instance:addStream("USD", core.Line, name .. ".USD", "USD", instance.parameters.USD_color, first);
    Out[1]:setPrecision(math.max(2, instance.source:getPrecision()));
		Out[1]:setWidth(instance.parameters.width1);
        Out[1]:setStyle(instance.parameters.style1);
		
        Out[2] = instance:addStream("EUR", core.Line, name .. ".EUR", "EUR", instance.parameters.EUR_color, first);
    Out[2]:setPrecision(math.max(2, instance.source:getPrecision()));
		Out[2]:setWidth(instance.parameters.width2);
        Out[2]:setStyle(instance.parameters.style2);
		
        Out[3] = instance:addStream("JPY", core.Line, name .. ".JPY", "JPY", instance.parameters.JPY_color, first);
    Out[3]:setPrecision(math.max(2, instance.source:getPrecision()));
		Out[3]:setWidth(instance.parameters.width3);
        Out[3]:setStyle(instance.parameters.style3);
		
        Out[4] = instance:addStream("CHF", core.Line, name .. ".CHF", "CHF", instance.parameters.CHF_color, first);
    Out[4]:setPrecision(math.max(2, instance.source:getPrecision()));
		Out[4]:setWidth(instance.parameters.width4);
        Out[4]:setStyle(instance.parameters.style4);
		
		Out[5] = instance:addStream("GBP", core.Line, name .. ".GBP", "GBP", instance.parameters.GBP_color, first);
    Out[5]:setPrecision(math.max(2, instance.source:getPrecision()));
		Out[5]:setWidth(instance.parameters.width5);
        Out[5]:setStyle(instance.parameters.style5);
		
		Out[6] = instance:addStream("AUD", core.Line, name .. ".AUD", "AUD", instance.parameters.AUD_color, first);
    Out[6]:setPrecision(math.max(2, instance.source:getPrecision()));
		Out[6]:setWidth(instance.parameters.width6);
        Out[6]:setStyle(instance.parameters.style6);
		
        ROC = instance:addStream("ROC", core.Bar, name .. ".ROC", "ROC", instance.parameters.ROC_color, first);
    ROC:setPrecision(math.max(2, instance.source:getPrecision()));
		
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    
	if period <first+2 or not  source:hasData(period) then
	return;
	end
	
	Nil = 0;
	for i= 1, 15, 1 do
    Calculate(period, i);
	end
	
	
	if Nil~= 0 then
	return;
	end
	
        Out[1][period] = ( Out[1][period-1]+Out[1][period-2]+((Data[3]-Data[1]-Data[4]+Data[10]-Data[11])/(TotalDevise-1)))/5;
        Out[2][period] = ( Out[2][period-1]+Out[2][period-2]+((Data[1]+Data[2]+Data[5]+Data[9]+Data[12])/(TotalDevise-1)))/5;
        Out[3][period] =  (Out[3][period-1]+Out[3][period-2]+((-Data[2]-Data[3]-Data[6]-Data[8]-Data[15])/(TotalDevise-1)))/5; 
        Out[4][period] =  (Out[4][period-1]+Out[4][period-2]+((Data[8]-Data[7]-Data[10]-Data[9]-Data[14])/(TotalDevise-1)))/5;
        Out[5][period] = ( Out[5][period-1]+Out[5][period-2]+((-Data[5]+Data[6]+Data[4]+Data[7]+Data[13])/(TotalDevise-1)))/5;
		Out[6][period] =(  Out[6][period-1]+Out[6][period-2]+((Data[11]-Data[12]-Data[13]+Data[14]+Data[15])/(TotalDevise-1)))/5;
		
	

     for i= 1, 15, 1 do
	 
	  Add(i,period);
	  
	end 
 	 
	  
 
end

function  Add(i, period)
     if (source:instrument()~=Instrument[i]) then
	 return;
	 end
	 
	 local crncy1, crncy2 = string.match(source:name(), pauto);
	 
	local X1= Decode(crncy1);
	local X2= Decode(crncy2); 
	 
    if X1== nil or X2== nil then
    return;
    end

    ROC[period]= Out[X1][period]-Out[X2][period];	
	
end

function Decode (crncy)

	if crncy== "USD" then
	return 1;
	elseif crncy== "EUR" then
	return 2;
	elseif crncy== "JPY" then
	return 3;
	elseif crncy== "CHF" then
	return 4;
	elseif crncy== "GBP" then
	return 5;
    elseif crncy== "AUD" then
	return 6;
	else
	return nil;
	end
end

function Calculate(period, i)

     p1= Initialization(period,i);
	 p2= Initialization(period-Period+1,i);
			
		if  not p1 or not p2 then 
		Nil=Nil+1;
		return;
		end
		
    Data[i]= (Source[i].close[p1]-Source[i].close[p2])/PointSize[i];
 
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

    local P = core.findDate(Source[id], Candle, false);
	 

    -- candle is not found
    if P < 0    then
        return false;
	else return P;	
    end
			
end	




-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
     local j;	 
	local Flag = true;	
	local Count=0;	
	
	
	    local id=0;
		
    for j = 1, Number, 1 do
		id=id+1;
			  if cookie == (100+id) then
			  loading[j] = true;
		      elseif  cookie == (200+id) then
			  loading[j] = false;			  		 
              end
			  
		if loading[j] then
		Count=Count+1;
		Flag=false;
		end	 

		  
		
	end    
	
	    if Flag then
		core.host:execute ("setStatus", " ");
		instance:updateFrom(0);
		else
		core.host:execute ("setStatus", " Loading ".. (Number-Count) .."/" .. Number);
		end
			     
        
		return core.ASYNC_REDRAW ;
end

 

