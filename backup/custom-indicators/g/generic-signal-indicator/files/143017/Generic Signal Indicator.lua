-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71381

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
    indicator:name("Generic Signal Indicator");
    indicator:description("Generic Signal Indicator");
	indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
 

    indicator.parameters:addGroup("Calculation");
	indicator.parameters:addBoolean("Signal_Mode", "Signal Mode","", true);	

	
	indicator.parameters:addGroup("First Line");
	indicator.parameters:addBoolean("Price_Cross", "Price Cross Mode","", false);			
	indicator.parameters:addString("INDICATOR1", "Indicator", "", "");
    indicator.parameters:setFlag("INDICATOR1",core.FLAG_INDICATOR);

	
	
	indicator.parameters:addGroup("Second Line");
	indicator.parameters:addBoolean("TwoSources", "Independent Source","", false);	
	indicator.parameters:addString("INDICATOR2", "Indicator", "", "");
    indicator.parameters:setFlag("INDICATOR2",core.FLAG_INDICATOR);
	
    indicator.parameters:addDouble("Y", "Y Shift (in Pips)", "Y Shift", 0);
    indicator.parameters:addInteger("X", "X Shift (in Candles)", "X Shift", 0);
	
    indicator.parameters:addGroup("1. Line Style");
    indicator.parameters:addColor("clrDPO1", "Color of DPO", "Color of DPO", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
    indicator.parameters:addGroup("2. Line Style");		
    indicator.parameters:addColor("clrDPO2", "Color of DPO", "Color of DPO", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
end

local first;
local source = nil; 
local Shift_DPO;
local Y, X;
local FIRST;
local Signal;

local INDICATOR1;
local Indicator1;
local INDICATOR2;
local Indicator2;

local Price_Cross; 
local Signal_Mode;
local TwoSources;
local Line1, Line2;
 function Prepare(nameOnly)   
 
    source = instance.source; 
	first = source:first()
	Signal_Mode=instance.parameters.Signal_Mode;	
	Price_Cross=instance.parameters.Price_Cross;
	TwoSources=instance.parameters.TwoSources;
	X=instance.parameters.X;
	Y=instance.parameters.Y*source:pipSize();
	INDICATOR1=instance.parameters.INDICATOR1; 
	INDICATOR2=instance.parameters.INDICATOR2; 
	Shift=instance.parameters.Shift;
	
	local name = profile:id() .. "(" .. source:name()  .. ")";
    instance:name(name);
	
	 if   (nameOnly) then
        return;
    end
	
	
	if not Price_Cross then 
		
	local iprofile1 = core.indicators:findIndicator(instance.parameters:getString("INDICATOR1"));
	local iparams1 = instance.parameters:getCustomParameters("INDICATOR1");
	
 
	if source:isBar() then
	Indicator1 = iprofile1:createInstance(source.close, iparams1); 
	else
	Indicator1 = iprofile1:createInstance(source , iparams1); 
	end

	end	
	
	if  X > 0 then
	FIRST= first + X;
	else
	FIRST= first;
	end
	
	
	if Signal_Mode then  
	Line1 = instance:addInternalStream(first, 0); 
	Line2= instance:addInternalStream(FIRST,   X); 
    else	
	Line1 = instance:addStream("Line1", core.Line, name .. ".Line1", "Line1", instance.parameters.clrDPO1, first);
	Line1:setWidth(instance.parameters.width1);
    Line1:setStyle(instance.parameters.style1);	
	Line1:setPrecision(math.max(2, instance.source:getPrecision())); 
	end
	
	local iprofile2 = core.indicators:findIndicator(instance.parameters:getString("INDICATOR2"));
	local iparams2 = instance.parameters:getCustomParameters("INDICATOR2");
	
	if TwoSources then
        	if source:isBar() then
			Indicator2 = iprofile1:createInstance(source.close, iparams2); 
			else
			Indicator2 = iprofile1:createInstance(source , iparams2); 
			end
	  
    else	
			if  iprofile2:requiredSource() == core.Tick then
			Indicator2 = iprofile2:createInstance(Line1, iparams2);
			else
			assert(false, "Line 2: Only Tick Based Indicator are allowed.");
			end  
	end
	
	if Signal_Mode then 
	Line2 = instance:addInternalStream(FIRST,   X); 
	else
	Line2 = instance:addStream("Line2", core.Line, name .. ".Line2", "Line2", instance.parameters.clrDPO2,FIRST,   X);
	Line2:setWidth(instance.parameters.width2);
    Line2:setStyle(instance.parameters.style2);	
	Line2:setPrecision(math.max(2, instance.source:getPrecision()));
	end
	
	if Signal_Mode then
	Signal = instance:addStream("Signal" , core.Bar, " Signal"," Signal",instance.parameters.clrDPO1, first ); 
    Signal:setPrecision(math.max(2, source:getPrecision()));
	else
	Signal = instance:addInternalStream(0, 0); 
    end
end

function Update(period, mode)


    if not Price_Cross then 
		Indicator1:update(mode);
		
		if (period<Indicator1.DATA:first()) then
		return;
		end
	
	end
	
	
	if Price_Cross then
	Line1[period]=source[period];
	else	
	Line1[period]=Indicator1.DATA[period];
	end
	
	Indicator2:update(mode); 
	if period < Indicator2.DATA:first() then
	return;
	end
	
	
    local p= period+X;	
	if  X < 0 then	
	
	   if  period+X < FIRST then
	   return;
	   end
	
	end
	 
	 Line2[p]= Indicator2.DATA[period]+Y ;	
	
	
 
	 
	 if X < 0  then
		 
		 if   Line1[p]  > Line2[p]
		 and Line1[p-1]  <= Line2[p-1]
		 then
		 Signal[p]=-1;	 
		 end
		 
		 
		 if   Line1[p]  < Line2[p]
		 and Line1[p-1]  >= Line2[p-1]
		 then
		 Signal[p]= 1;	 
		 end	
    elseif X > 0 or  X ==  0 then 
	
         if   Line1[period]  < Line2[period]
		 and Line1[period-1] >= Line2[period-1]
		 then
		 Signal[period]=-1;	 
		 end
		 
		 
		 if   Line1[period]  > Line2[period]
		 and Line1[period-1]  <= Line2[period-1]
		 then
		 Signal[period]= 1;	 
		 end
    end	 
     
end

