-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=72177

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
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

--Your donations will allow the service to continue onward.
--+------------------------------------------------------------------------------------------------+
--|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
--|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
--|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
--|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
--|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
--|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
--+------------------------------------------------------------------------------------------------+



-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("MTF SAR");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);


	indicator.parameters:addGroup("Calculation");	
  	indicator.parameters:addBoolean("Ignore" , "Ignore Repeated Indications", "", true);	
  	indicator.parameters:addBoolean("Current" , "Current Indications Only ", "", true);	
    Add(1 ); 
    Add(2 ); 
    Add(3 ); 
    Add(4 ); 
    Add(5 ); 
    Add(6 ); 
    Add(7 ); 
    Add(8  ); 
    Add(9 ); 
    Add(10 ); 
	Add(11  ); 
    Add(12  ); 
    Add(13 ); 
	
	indicator.parameters:addGroup("Arrow  Style");	
	indicator.parameters:addInteger("Size", "Arrow Size", "", 20); 
   indicator.parameters:addColor("clrUP", "Up Arrow", "" ,  core.COLOR_UPCANDLE);
    indicator.parameters:addColor("clrDN",  "Down Arrow", "" , core.COLOR_DOWNCANDLE);	
end
function Add(id )

    local TF={"m1", "m5","m15", "m30", "H1", "H2", "H3","H4", "H6", "H8", "D1", "W1", "M1"};
    indicator.parameters:addGroup(id .. ". Slot");	
	indicator.parameters:addBoolean("On"..id, "Use This Slot", "", true);	
	
	indicator.parameters:addString("TF" .. id, "Time Frame", "", TF[id]);
    indicator.parameters:setFlag("TF" .. id, core.FLAG_PERIODS);
	
	
	
	indicator.parameters:addDouble("Step".. id , "Step", "The sensitivity of SAR.", 0.2, 0.001, 1)	 
    indicator.parameters:addDouble("Max"..id, "Max", "The maximum value of Step.", 1, 0.001, 10)
	 
end 
 
-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Size, Label;
local first;
local source = nil;
local Source={};
local Number;
-- Streams block
local Max = {};
local Step = {};
local TF={};
local loading={};
local SAR={}; 
local Ignore;
-- Routine
function Prepare(nameOnly)
    source = instance.source;
    first = source:first(); 
 
    dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");
	
	Ignore=instance.parameters.Ignore;
	Current=instance.parameters.Current;
	

    local name = profile:id() .. "(" .. source:name() .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
    Signal = instance:addInternalStream(0, 0);	

    Number=0;


	
	
   local s, e, s1, e1 ; 
    s, e = core.getcandle(source:barSize(), 0, 0, 0);
	
	
	for i= 1 , 13 , 1 do
	
	    s1, e1 = core.getcandle( instance.parameters:getString("TF" .. i), 0, 0, 0);
	
	 if  instance.parameters:getBoolean("On" .. i) and (e - s) <= (e1 - s1)   then
	 Number=Number+1;
	 TF[Number]=  instance.parameters:getString("TF" .. i);	 
	 Step[Number]=  instance.parameters:getDouble("Step" .. i);	 
	 Max[Number]=  instance.parameters:getDouble("Max" .. i); 
     Source[Number]  = core.host:execute("getSyncHistory",  source:instrument(),  TF[Number], source:isBid(), 300, 2000 + Number , 1000 +Number);	 
 
     SAR[Number] = core.indicators:create("SAR", Source[Number], Step[Number], Max[Number]  );	 
	 loading[Number]  = true;  	 
	 
	 end
	 
	end
	
	
	up = instance:createTextOutput ("Up", "Up", "Wingdings", instance.parameters.Size, core.H_Center,core.V_Bottom , instance.parameters.clrUP, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", instance.parameters.Size, core.H_Center, core.V_Top, instance.parameters.clrDN, 0);
 
end


function   Initialization(id, period)

    local Candle;
    Candle = core.getcandle(TF[id], source:date(period), dayoffset, weekoffset);

  
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


-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)


    if period < source:first() then
	return;
	end


   local FLAG=false; 
 
    for j = 1, Number, 1 do 
		       
                 if loading[j] then
				 FLAG= true; 
				 end
	end    
	
	
	if FLAG then
	return;
	end
	
	
    for j = 1, Number, 1 do
	SAR[j]:update(core.UpdateLast); 
	end	
 
	local p;
	local IsBuy=true;
	local IsSell=true;	
    for j = 1, Number, 1 do 
	p= Initialization(j, period);
	
	    if p~=false then
			if  not  SAR[j]:getStream(1):hasData(p) then
			IsBuy=false;
			end
			
			if  not SAR[j]:getStream(0):hasData (p) then
			IsSell=false;
			end	
		end
		
	
	end 
	
	Signal[period]=0;
    
	if IsBuy and not IsSell then
--	if IsBuy  then	
	Signal[period]=1;
	elseif not IsBuy and IsSell then	
--	elseif  IsSell then		
    Signal[period]=-1;	
	elseif not Current then
    Signal[period]= Signal[period-1];
    end	

	
    up:setNoData(period);
    down:setNoData(period);	
	
	if Signal[period]== 1 and ( Signal[period-1]~= 1 or not Ignore ) then  
    up:set(period, source.low[period], "\217", source.low[period]);	 
	elseif Signal[period]== -1 and ( Signal[period-1]~= -1 or  not Ignore)then  
    down:set(period, source.high[period], "\218", source.high[period]);	
	end
	
    
end





function AsyncOperationFinished(cookie)

local j;
local FLAG=false; 
local Num=0; 
    for j = 1, Number, 1 do
		   
			  if cookie == (1000 + j) then
			  loading[j]  = true;
		      elseif  cookie == (2000 + j ) then
			  loading[j]  = false;     
			  end
		 
		       
                 if loading[j] then
				 FLAG= true;
				 Num=Num+1;
				 end
	end    
   
   
	
	if FLAG then
	 core.host:execute ("setStatus", "  Loading "..((Number) - Num) .. " / " .. (Number) );	 
	else
	core.host:execute ("setStatus", "Loaded");
	instance:updateFrom(0);
	end
   
        
    return core.ASYNC_REDRAW ;
	
end


