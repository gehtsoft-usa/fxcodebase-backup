-- Id: 14177
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=62214&p=100427#p100427

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
    indicator:name("MTF Normalized LWMA Slope");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    indicator.parameters:addGroup("Calculation");
 
 

    indicator.parameters:addInteger("LWMA_Period", "LWMA Period", "", 56);
    indicator.parameters:addInteger("ATR_Period", "ATR Period", "", 100);

	
	indicator.parameters:addString("TF2", "1. Time Frame", "", "D1");
    indicator.parameters:setFlag("TF2", core.FLAG_PERIODS);
	
	indicator.parameters:addString("TF3", "2. Time Frame", "", "W1");
    indicator.parameters:setFlag("TF3", core.FLAG_PERIODS);
	
	indicator.parameters:addString("TF4", "3. Time Frame", "", "M1");
    indicator.parameters:setFlag("TF4", core.FLAG_PERIODS);

    indicator.parameters:addGroup("Style"); 
    indicator.parameters:addColor("UpUp", "Color of Up in Up Trend", "UP color", core.rgb(255, 0, 0));
    indicator.parameters:addColor("DownUp", "Color of Down in Up Trend", "UP color", core.rgb(200, 0, 0));
	indicator.parameters:addColor("UpDown", "Color of Up in Down Trend", "UP color", core.rgb(0, 255, 0));
    indicator.parameters:addColor("DownDown", "Color of Down in Down Trend", "UP color", core.rgb(0, 200, 0));
	indicator.parameters:addColor("NeutralUp", "Color of Up in Neutral Trend", "Neutral Color", core.rgb(128, 128, 128));
    indicator.parameters:addColor("NeutralDown", "Color of Down in Neutral Trend", "Neutral Color", core.rgb(100, 100, 100)); 
   indicator.parameters:addDouble("Size", "Font Size (%)","",90, 50, 200);
   
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block
 
local first;
-- Streams block
local UpUp, UpDown,DownNeutral,UpNeutral , DownUp, DownDown;
 
local LWMA={};
local ATR_Period, LWMA_Period;
local Source={};
 
local lwma={};
local TF={};
local loading={};
local dayoffset, weekoffset;
local Size ;
-- Routine
function Prepare(nameOnly)
  
	UpUp= instance.parameters.UpUp;
	DownUp= instance.parameters.DownUp;
	NeutralUp= instance.parameters.NeutralUp;
	UpDown= instance.parameters.UpDown;
	DownDown= instance.parameters.DownDown;
	NeutralDown= instance.parameters.NeutralDown; 
	TF[2]= instance.parameters.TF2;
	TF[3]= instance.parameters.TF3;
	TF[4]= instance.parameters.TF4;
    Source[1] = instance.source;
	
	Size= instance.parameters.Size; 
	 
	dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");	
	
	LWMA_Period= instance.parameters.LWMA_Period;
	ATR_Period= instance.parameters.ATR_Period;
	local name = profile:id() .. "(" .. Source[1]:name() ..  ", " ..LWMA_Period .. ", " .. ATR_Period .. ")";
	instance:name(name); 
	if nameOnly then
		return;
	end
	
	assert(core.indicators:findIndicator("NORMALIZED LWMA SLOPE") ~= nil, "Please, download and install NORMALIZED LWMA SLOPE.LUA indicator"); 
    for i= 1, 4,1 do
	 if i~= 1 then
	 Source[i] = core.host:execute("getSyncHistory",Source[1]:instrument(), TF[i], Source[1]:isBid(), LWMA_Period*2, 200+i, 100+i);
	 loading[i]=true;	
	 end
     LWMA[i] = core.indicators:create("NORMALIZED LWMA SLOPE", Source[i], LWMA_Period, ATR_Period, UpUp, DownUp, UpDown,DownDown,NeutralUp, NeutralDown);
	  
    end

    first = LWMA[1].DATA:first() ;
	 	
	lwma[1] = instance:addStream("NLWMAS", core.Bar, name, "NLWMAS", NeutralUp, first);
    lwma[1]:setPrecision(math.max(2, instance.source:getPrecision()));
   
    instance:ownerDrawn(true);

	
end

-- Indicator calculation routine
function Update(period, mode)

		LWMA[1]:update(mode);
		
		
		if period < first then
		return;
		end

	lwma[1][period]= LWMA[1].DATA[period];
		
	if lwma[1][period]> 0 then		
        if lwma[1][period] > lwma[1][period-1] then 
        lwma[1]:setColor(period, UpUp); 
		else
		lwma[1]:setColor(period, DownUp); 
        end		
	else
	    if lwma[1][period] > lwma[1][period-1] then 
	    lwma[1]:setColor(period, UpDown); 
		else
		lwma[1]:setColor(period, DownDown); 
        end	
	end
	
		
end

local init = false;

function Draw(stage, context)
    if stage ~= 2 then
	return;
	end
	
        if not init then
            init = true;
        end

    	local FLAG=false; 

    for j = 2, 4, 1 do
		     
                 if loading[j] then
				 FLAG= true;
				 else
				 LWMA[j]:update(core.UpdateLast);
				 end
				 
	end    
    
	
	if FLAG then
	return;
	end
	
	   
	VCellSize =((context:bottom() -context:top())/ 5); 
	HCellSize = (context:right() -context:left())/50; 
	context:createFont(1, "Arial", (HCellSize/100)*Size, (VCellSize/100)*Size, context.NORMAL);
	local style =  context.VCENTER;
	 for i = 2, 4, 1 do
	         	
	            if LWMA[i].DATA:hasData( LWMA[i].DATA:size()-1) then     
					 Value= TF[i] .. ": " .. win32.formatNumber( LWMA[i].DATA[ LWMA[i].DATA:size()-1], false, Source[1]:getPrecision())
					 width, height = context:measureText (1,  Value , style)	 
					  context:drawText(1,  Value , LWMA[i].DATA:colorI(LWMA[i].DATA:size()-1), -1,context:right() -width , context:top()+VCellSize*(i-1) ,context:right(), context:top()+VCellSize*(i-1)+height , style);
				
			 end		 
    end
end


function   Initialization(period,id)

    local Candle;
    Candle = core.getcandle(Source[1]:barSize(),Source[1]:date(period), dayoffset, weekoffset);
  
    if loading[id] or Source[id]:size() == 0  then
        return false;
    end

    
    if period < Source[1]:first() then
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
	 
		
    for j = 2, 4, 1 do
		 
			  if cookie == (100+j) then
			  loading[j] = true;		
		      elseif  cookie == (200+j) then
	          LWMA[j]:update(core.UpdateLast); 
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
		core.host:execute ("setStatus", " Loading ".. (3-Count) .."/" .. 3);
		end
		
		
  
        
		return core.ASYNC_REDRAW ;
end
 