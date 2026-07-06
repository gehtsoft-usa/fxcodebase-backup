-- Id: 2541
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=970

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
    indicator:name("Euro Index");
    indicator:description("Euro Index");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	
	indicator.parameters:addString("Method", "Index Method", "Method" , "Line");
    indicator.parameters:addStringAlternative("Method", "Line", "Line" , "Line");
    indicator.parameters:addStringAlternative("Method", "Candle", "Candle" , "Candle");
	
	indicator:setTag("group", "Currency Indexes");	
    indicator.parameters:addColor("color1", "color", "color", core.rgb(0, 255, 0));

end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
local first;
local source = nil;
local host;

local last;
local data;
local instrument;
local dummy = nil;
local dayoffset, weekoffset;

local N=4;
local SCALEFACTOR;

local Close;
local Open;
local High;
local Low;
local tmp1 
local tmp2 
local tmp3 
local tmp4 
local SourceData={};
local label={}
  
label[1]="EUR/USD"; 
label[2]="EUR/JPY";  
label[3]="EUR/GBP";
label[4]="EUR/CHF";
label[5]="EUR";
local pauto =  "(%a%a%a)/(%a%a%a)";
 local Index={};
local Number=4;
local loading={};
local Method;
local First;
-- Routine
function Prepare(nameOnly)
    source = instance.source;
    first = source:first();
    host = core.host;
    dayoffset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");
    Method=instance.parameters.Method;

    local name = profile:id() .. "()";
	instance:name(name);
	if nameOnly then
		return;
	end
   
    instrument=source:instrument();
	if Method == "Line" then
	Close = instance:addStream("Index", core.Line, label[5].. " Index", label[5].. " Index", instance.parameters.color1, first);
    Close:setPrecision(math.max(2, instance.source:getPrecision()));
	else
	Open = instance:addInternalStream(0, 0);
    High  = instance:addInternalStream(0, 0);
    Low = instance:addInternalStream(0, 0);
    Close = instance:addInternalStream(0, 0);
	 instance:createCandleGroup(label[5].. " Index", label[5].. " Index", Open, High, Low, Close);
	 end
   
   for i= 1, 4 , 1 do
    crncy1, crncy2 = string.match(label[i], pauto);
	if crncy1== label[5] then
	Index[i]= 1;
	else
	Index[i]= -1;
	end
   SourceData[i] = core.host:execute("getSyncHistory",label[i], source:barSize(), source:isBid(), 0, 200 +i, 100+i);
   loading[i]=true;
   end
   
   First=false;   
end

-- Indicator calculation routine
 
function Update(period )

 
   
	
    if period  < source:first()	
	then
    return;		
    end	
     
	  local Flag=false;
	for i= 1, Number, 1 do	
		if loading[i] then		
		Flag=true;
		end
	end
		
	
	if Flag then
	return;
	end	
			
	 local p={}
	   p[1]= Initialization(period,1)	 
       p[2]= Initialization(period,2)	
        p[3]= Initialization(period,3)	
        p[4]= Initialization(period,4)		
		
		
		if  not p[1] or not 	p[2]	or not p[3] or not p[4] then	
        Close[period]=nil;  		
		return;
		end
		
		
			     if not First then
				 First=true;
					          
				 Close[period]=100; 
				 tmp1=SourceData[1].close[p[1]];
				 tmp2=SourceData[2].close[p[2]];
				 tmp3=SourceData[3].close[p[3]];
				  tmp4=SourceData[4] .close[p[4]];  
				  SCALEFACTOR=100/((SourceData[1].close[p[1]]/tmp1)^(Index[1]/N) *(SourceData[2].close[p[2]]/tmp2)^(Index[2]/N)*(SourceData[3].close[p[3]]/tmp3)^(Index[3]/N)*(SourceData[4].close[p[4]]/tmp4)^(Index[4]/N));	 
				 else
						  
						  
				           Close[period]=((SourceData[1].close[p[1]]/tmp1)^(Index[1]/N) *(SourceData[2].close[p[2]]/tmp2)^(Index[2]/N)*(SourceData[3].close[p[3]]/tmp3)^(Index[3]/N)*(SourceData[4].close[p[4]]/tmp4)^(Index[4]/N))*SCALEFACTOR;
						   if Method ~= "Line" then
						     Open[period]=((SourceData[1].open[p[1]]/tmp1)^(Index[1]/N) *(SourceData[2].open[p[2]]/tmp2)^(Index[2]/N)*(SourceData[3].open[p[3]]/tmp3)^(Index[3]/N)*(SourceData[4].open[p[4]]/tmp4)^(Index[4]/N))*SCALEFACTOR;
							 High[period]=((SourceData[1].high[p[1]]/tmp1)^(Index[1]/N) *(SourceData[2].high[p[2]]/tmp2)^(Index[2]/N)*(SourceData[3].high[p[3]]/tmp3)^(Index[3]/N)*(SourceData[4].high[p[4]]/tmp4)^(Index[4]/N))*SCALEFACTOR;
						     Low[period]=((SourceData[1].low[p[1]]/tmp1)^(Index[1]/N) *(SourceData[2].low[p[2]]/tmp2)^(Index[2]/N)*(SourceData[3].low[p[3]]/tmp3)^(Index[3]/N)*(SourceData[4].low[p[4]]/tmp4)^(Index[4]/N))*SCALEFACTOR;
				           end
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
	local Count=0;	
	
	
	
    for j = 1, Number, 1 do
		
			  if cookie == (100+j) then
			  loading[j] = true;
		      elseif  cookie == (200+j) then
			  loading[j] = false;  
			  instance:updateFrom(0);		 
              end
			  
		if loading[j] then
		Count=Count+1;
		Flag=true;
		end	 

		  
		if Flag then
		core.host:execute ("setStatus", " Loading ".. (Number-Count) .."/" .. Number);
		else
		core.host:execute ("setStatus", " Loaded ".. (Number-Count) .."/" .. Number);
		end
			  
	end    
   
        
		return core.ASYNC_REDRAW ;
end
