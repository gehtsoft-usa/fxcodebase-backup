-- Id: 3984
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=4435

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Differential Indicator");
    indicator:description("Differential Indicator");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
    
    AddSymbol(1);
    AddSymbol(2);
    
    indicator.parameters:addBoolean("AsPercentage", "AsPercentage", "AsPercentage", true);

    indicator.parameters:addGroup("Display");
    indicator.parameters:addColor("clrIndex", "Index Color", "", core.rgb(255, 0, 0));
    indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
end

local source;
local barSize;
local SS;
local loading={};
local offset;
local weekoffset;
local SourceData={};
local AsPercentage;
local Pair={};
-- indexes for the instruments in the data table
 
-- data table
 

function AddSymbol(ParName)
 indicator.parameters:addString("Pair"  .. ParName, "The instrument " .. ParName, "", "");
 indicator.parameters:setFlag("Pair"  .. ParName, core.FLAG_INSTRUMENTS);
end



-- prepare the indicator
function Prepare(nameOnly)
    source = instance.source;
    host = core.host;
    barSize = source:barSize();
	AsPercentage = instance.parameters.AsPercentage;
    offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");

    local name = profile:id();
	instance:name(name);
	if nameOnly then
		return;
	end
    SS = instance:addStream("SS", core.Line, name .. ".SS", "SS", instance.parameters.clrIndex, 0);
    SS:setPrecision(math.max(2, instance.source:getPrecision()));
    SS:setWidth(instance.parameters.widthLinReg);
    SS:setStyle(instance.parameters.styleLinReg);
	
	local i;
	for i = 1, 2, 1 do
	Pair[i]= instance.parameters:getString("Pair" .. i);
	SourceData[i] = core.host:execute("getSyncHistory",Pair[i], source:barSize(), source:isBid(), 0, 200+i, 100+i);
	loading[i]=true;
	end
end




-- the function which is called to calculate the period
function Update(period, mode)

   
   local Flag= false;
   
   for i= 1, 2, 1 do

		if loading[i] then		
		Flag=true;
		end
	end
		
	
	if Flag then
	return;
	end	
	
	 local p1 = Initialization(period,1);
	local p2 = Initialization(period,2); 	
	 local p3 = Initialization(period-1,1);
	local p4 = Initialization(period-1,2); 
	
	 if p1== false or  p2== false or p3== false or  p4== false then
	 return;
	 end

        if AsPercentage then
			 if (SourceData[1].close[p3]-SourceData[2].close[p4]) ~= 0 then
			 SS[period]=((SourceData[1].close[p1]-SourceData[2].close[p2]) - (SourceData[1].close[p3]-SourceData[2].close[p4]))/ (SourceData[1].close[p3]-SourceData[2].close[p4]);
			 else
			 SS[period]=0;
			 end
        else
         SS[period]=SourceData[1].close[p1]-SourceData[2].close[p2];
        end 
  

end


function   Initialization(period,id)

    local Candle;
    Candle = core.getcandle(source:barSize(), source:date(period), offset, weekoffset);
  
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

function AsyncOperationFinished(cookie)
     local j;	 
	local Flag = false;	
	local Count=0;	
	
	
	
    for j = 1, 2, 1 do
		
			  if cookie == (100 +j) then
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
		core.host:execute ("setStatus", " Loading ".. (2-Count) .."/" .. 2);
		else
		core.host:execute ("setStatus", " Loaded ".. (2-Count) .."/" .. 2);
		end
			  
	end    
   
        
		return core.ASYNC_REDRAW ;
end