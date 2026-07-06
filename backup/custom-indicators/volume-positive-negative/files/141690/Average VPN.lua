-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&p=141844

--+------------------------------------------------------------------------+
--|                                    Copyright © 2021, Gehtsoft USA LLC  | 
--|                                                 http://fxcodebase.com  |
--+------------------------------------------------------------------------+
--|                                      Support our efforts by donating   | 
--|                                         Paypal: https://goo.gl/9Rj74e  |
--+------------------------------------------------------------------------+
--|                                           Developed by : Mario Jemic   |                    
--|                                               mario.jemic@gmail.com    |
--|                                https://AppliedMachineLearning.systems  |
--|                                     Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------+

--+------------------------------------------------------------------------+
--|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF         |
--|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D |
--|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C         |
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c |  
--|Binance Address (BEP2 only): bnb136ns6lfw4zs5hg4n85vdthaad7hq5m4gtkgf23 |
--|Binance MEMO (BEP2 only)   : 107152697                                  |   
--|LiteCoin Address           : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD         |  
--+------------------------------------------------------------------------+


-- Indicator profile initialization routine

function Init()
    indicator:name("Average VPN");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
    indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period", "VP Period", "", 30, 1, 2000); --Ok
    indicator.parameters:addInteger("SMOOTH", "SMOOTH", "", 3, 1, 2000);	--Ok
    indicator.parameters:addInteger("VPNCRIT", "VPNCRIT", "", 10, 1, 2000);
    --indicator.parameters:addInteger("MAB", "MA BARS", "", 30, 1, 2000); --Ok
    indicator.parameters:addDouble("Multiplier", "Multiplier", "", 0.1); --Ok
	
	
    Add(1, "Chart", "EUR/USD"); 
    Add(2, "Chart", "USD/JPY"); 
    Add(3, "Chart",  "GBP/USD");
 
 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(128, 128, 128));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

 function Add(id, TF,  Instrument )
   
    indicator.parameters:addGroup(id..". Slot" );
	indicator.parameters:addBoolean("On".. id , "Show This Slot", "",true);	  
 
 
    local TF={"m1", "m5", "m15", "m30", "H1", "H2", "H3", "H4", "H6", "H8", "D1", "W1", "M1", "Chart"}; 
    indicator.parameters:addString("TF" .. id, "Time Frame ", "", "Chart");
	
    for i = 1, 14, 1 do
	indicator.parameters:addStringAlternative("TF".. id, TF[i], "", TF[i]);
    end
	
	indicator.parameters:addString("Instrument" .. id, "Instrument", "", Instrument);
    indicator.parameters:setFlag("Instrument" .. id, core.FLAG_INSTRUMENTS);
	
	indicator.parameters:addInteger("Period".. id, "Number of periods", "", 14, 1, 200);
	
	if id == 1 then
	indicator.parameters:addColor("Color".. id, "Line Color", "", core.rgb(255, 0, 0));
    elseif id == 2 then
	indicator.parameters:addColor("Color".. id, "Line Color", "", core.rgb(0, 255, 0));
	else
	indicator.parameters:addColor("Color".. id, "Line Color", "", core.rgb(0, 0, 255));
	end
end


-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

local Period,SMOOTH, VPNCRIT, MAB,Multiplier; 
local Period; 
local first;
local source = nil;
local Period; 
local Oscillator;  
local Instrument={};
local Source={};
local loading={};
local Indicator={}; 
local Line= {};
local Color={};
local Number=0;
local TF={};
local iTF={};  
local day_offset, week_offset;
-- Routine
 function Prepare(nameOnly)   
 
    day_offset = core.host:execute("getTradingDayOffset");
    week_offset = core.host:execute("getTradingWeekOffset");
				
    source = instance.source; 
    first=source:first() ; 
	
	Period= instance.parameters.Period;
	SMOOTH= instance.parameters.SMOOTH;
	VPNCRIT= instance.parameters.VPNCRIT;
	--MAB= instance.parameters.MAB; 
	Multiplier= instance.parameters.Multiplier;
	
	--local Parameters= Period..", ".. SMOOTH..", ".. VPNCRIT..", ".. MAB..", ".. Multiplier;
	local Parameters= Period..", ".. SMOOTH..", ".. VPNCRIT..", ".. Multiplier;
	
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	assert(core.indicators:findIndicator("VPN") ~= nil, "Please, download and install VPN.LUA indicator");
  
 
   for i = 1, 3, 1 do
		       if    instance.parameters:getString("TF" .. i)== "Chart" then
	            TF[i]=source:barSize();
				else
				TF[i]=  instance.parameters:getString("TF" .. i);                		
				end		 		
	end
    

	
	
	local s1, e1, s2, e2;
	s1, e1 = core.getcandle(source:barSize(), 0, 0, 0);
	  
	Number=0;
	
	
	for i = 1, 3, 1 do
	
	
	s2, e2 = core.getcandle( TF[i], 0, 0, 0);
			
			 if  instance.parameters:getBoolean("On" .. i) and (e1 - s1) <= (e2 - s2)  then
			 Number=Number+1;
			 iTF[Number]=TF[i];
			 
			 Instrument[Number]=  instance.parameters:getString("Instrument" .. i);	 
			 
			Source[Number]  = core.host:execute("getSyncHistory",  Instrument[Number],  iTF[Number], source:isBid(),300, 2000 + Number , 1000 +Number);	 	 
			loading[Number]  = true;  	 
			Indicator[Number] = core.indicators:create("VPN", Source[Number] ,  Period,SMOOTH,VPNCRIT,30,Multiplier);   
			
			Color[Number]=instance.parameters:getColor("Color".. Number);
			
			end
			
			
			
	
	end
	
	
	for j= 1, Number , 1 do
	Line[j] = instance:addStream(  "Line".. j , core.Line, j.. ". Oscillator",j.. ". Oscillator", Color[j], first );
	Line[j]:setWidth(instance.parameters.width);
    Line[j]:setStyle(instance.parameters.style);
    Line[j]:setPrecision(math.max(2, source:getPrecision()));
	end

 
	Oscillator = instance:addStream("Oscillator" , core.Line, " Oscillator"," Oscillator",instance.parameters.color, first );
	Oscillator:setWidth(instance.parameters.width);
    Oscillator:setStyle(instance.parameters.style);
    Oscillator:setPrecision(math.max(2, source:getPrecision()));
	
	
end


function   Initialization(period,id)

    local Candle;
    Candle = core.getcandle(source:barSize(), source:date(period), day_offset, week_offset);
  
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


-- Indicator calculation routine
function Update(period, mode)

 
	if period < source:first() 
	then
	return;
	end
	
	
   local FLAG=false; 

    for j = 1, Number, 1 do
	Indicator[j]:update(mode );	     
                 if loading[j] 
				 then
				 FLAG= true;
				 end
				 
	end    
    
	
	if FLAG then
	return;	 
	end
	
	local Sum=0;
 
	
	for j= 1, Number,1 do
	
	local p= Initialization(period,j);
		if p~= false then
		Line[j][period]=Indicator[j].DATA[p];
		Sum=Sum+Line[j][period];
		end
	end
	
	
	
	
 
     Oscillator[period]= Sum/Number;
				  
end

 
-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)

 

local j;
local FLAG=false; 
local Num=0;
local Id=0;
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

