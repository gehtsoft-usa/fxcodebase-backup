-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2754

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

-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Gann's Square Of Nine");
    indicator:description("Gann's Square Of Nine");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
   	
	
	indicator.parameters:addGroup("Calculation");
	indicator.parameters:addInteger("Step", "Step", "No description", 100);	
	indicator.parameters:addString("Type" , "Prime / Square", "", "Prime");
    indicator.parameters:addStringAlternative("Type", "Prime", "", "Prime");
    indicator.parameters:addStringAlternative("Type", "Square Of Nine", "", "Square"); 
	indicator.parameters:addBoolean("LOCK", "LOCK", "", true);
	
	indicator.parameters:addGroup("Gann Square Selector");
	indicator.parameters:addBoolean("DEGREE0On", "Gann  Square 0°", "", true);
	indicator.parameters:addBoolean("DEGREE45On", "Gann  Square 45°", "", true);
	indicator.parameters:addBoolean("DEGREE90On", "Gann  Square 90°", "", true);
	indicator.parameters:addBoolean("DEGREE135On", "Gann  Square 135°", "", true);
	indicator.parameters:addBoolean("DEGREE180On", "Gann  Square 180°", "", true);
	indicator.parameters:addBoolean("DEGREE225On", "Gann  Square 225°", "", true);
	indicator.parameters:addBoolean("DEGREE270On", "Gann  Square 270°", "", true);
	indicator.parameters:addBoolean("DEGREE315On", "Gann  Square 315°", "", true);
	
   indicator.parameters:addGroup("Style");	
   indicator.parameters:addColor("Gann", "Squere Of  Nine Lines Color", " ", core.rgb(255, 0, 0));

   
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Step;
local COLOR;
local PRIME={2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97};
local DEGREE0={6,19, 40, 69, 106, 151, 204, 265, 334};
local DEGREE90={316, 249, 190, 139, 96, 61, 34, 15, 4};
local DEGREE180={298, 233, 176, 127, 86, 53, 28, 11, 2};
local DEGREE270={8, 23, 46, 77, 116, 163, 218, 281, 352};

local DEGREE45={5, 17, 37, 65, 101, 145, 197, 256, 325};
local DEGREE135={3, 13, 31, 57, 91, 133, 183, 241, 307};
local DEGREE225={9, 25, 49, 81, 121, 169, 225, 289, 361};
local DEGREE315={7, 21, 43, 73, 111, 157, 211, 273, 343};

local Type;
local DEGREE0On;
local DEGREE90On;
local DEGREE180On;
local DEGREE270On;

local DEGREE45On;
local DEGREE135On;
local DEGREE225On;
local DEGREE315On;

local first;
local source = nil;

local LOW=nil;
local LAST=nil;
local LOCK;
local SET= true;
local size;

function Prepare(nameOnly)
    Type= instance.parameters.Type;
	DEGREE0On  = instance.parameters.DEGREE0On;
	DEGREE90On  = instance.parameters.DEGREE90On;
	DEGREE180On  = instance.parameters.DEGREE180On;
	DEGREE270On  = instance.parameters.DEGREE270On;
	
	DEGREE45On  = instance.parameters.DEGREE45On;
	DEGREE135On  = instance.parameters.DEGREE135On;
	DEGREE225On  = instance.parameters.DEGREE225On;
	DEGREE315On  = instance.parameters.DEGREE315On;

    COLOR = instance.parameters.Gann; 
    LOCK = instance.parameters.LOCK;
    Step = instance.parameters.Step;
    source = instance.source;
    first = source:first();
	
	local s, e;
    s, e = core.getcandle(source:barSize(), 0, 0);
	size=e-s;
	
	
	local name;
    if Type == "Prime" then
    name = profile:id() .. "(" .. source:name() .. ", " .. Step ..", Prime)";
	else
	name = profile:id() .. "(" .. source:name() .. ", " .. Step .. ",  Square Of Nine)";
	end
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
   
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < source:size()-1 or not source:hasData(period) then
	return;
	end
	
   
    local i;
	
	
	if LAST ~=  Type then
	core.host:execute ("removeAll");
	LAST = Type;
	end
	
	if not LOCK then
	LOW = mathex.min( source.low,  first, source:size()-1);
	elseif LOCK and SET then
    SET = false;  	
	LOW = mathex.min( source.low,  first, source:size()-1);
	end
	
	
	core.host:execute("drawLine", 1, source:date(first), LOW , source:date(source:size()-1),LOW, core.rgb(255, 0, 0));
   core.host:execute("drawLabel", 2,  source:date(source:size()-1)+2*size, LOW, "( 0. Line )");
	
	
		for i = 1, 25,1 do	
		
		    if  Type == "Prime" then
		        if   PRIME[i] ~= nil then 
				DRAW(i, LOW, period, 0);
				end
				
			elseif i < 10 then	
				if DEGREE0On  and DEGREE0[i] ~= nil then 
				DRAW(i, LOW, period, 1);
				end
				
				if DEGREE90On  and DEGREE90[i] ~= nil then 
				DRAW(i, LOW, period, 2);
				end
				
				if DEGREE180On  and DEGREE180[i] ~= nil then 
				DRAW(i, LOW, period, 3);
				end
				if DEGREE270On  and DEGREE270[i] ~= nil then 
				DRAW(i, LOW, period, 4);
				end
				
				if DEGREE45On  and DEGREE45[i] ~= nil then 
				DRAW(i, LOW, period, 5);
				end
				
				if DEGREE135On  and DEGREE135[i] ~= nil then 
				DRAW(i, LOW, period, 6);
				end
				
				if DEGREE225On  and DEGREE225[i] ~= nil then 
				DRAW(i, LOW, period, 7);
				end
				if DEGREE315On  and DEGREE315[i] ~= nil then 
				DRAW(i, LOW, period, 8);
				end
				
				
			end	
		end    
    
end



function DRAW(i, low, p, k)

		if Type == "Prime" then
		core.host:execute("drawLine", k*1000+1*100+i, source:date(first), low +PRIME[i]*Step*source:pipSize(), source:date(p),low +PRIME[i]* Step*source:pipSize(), COLOR);
		core.host:execute("drawLabel", k*1000+2*100+ i,  source:date(p)+2*size, low +PRIME[i]*Step*source:pipSize(), "(" ..tostring(PRIME[i]) ..")");
		elseif k==1 then
		core.host:execute("drawLine", k*1000+1*100+i, source:date(first), low +DEGREE0[i]*Step*source:pipSize(), source:date(p),low +DEGREE0[i]* Step*source:pipSize(), COLOR);
		core.host:execute("drawLabel", k*1000+2*100+ i,  source:date(p)+2*size, low +DEGREE0[i]*Step*source:pipSize(), "(" ..tostring(DEGREE0[i]) ..", 0°"..  ")");
		elseif k==2 then
		core.host:execute("drawLine", k*1000+1*100+i, source:date(first), low +DEGREE90[i]*Step*source:pipSize(), source:date(p),low +DEGREE90[i]* Step*source:pipSize(), COLOR);
		core.host:execute("drawLabel", k*1000+2*100+ i,  source:date(p)+2*size, low +DEGREE90[i]*Step*source:pipSize(), "(" ..tostring(DEGREE90[i]) ..", 90°"..")");
		elseif k==3 then
		core.host:execute("drawLine", k*1000+1*100+i, source:date(first), low +DEGREE180[i]*Step*source:pipSize(), source:date(p),low +DEGREE180[i]* Step*source:pipSize(), COLOR);
		core.host:execute("drawLabel", k*1000+2*100+ i,  source:date(p)+2*size, low +DEGREE180[i]*Step*source:pipSize(), "(" ..tostring(DEGREE180[i]) ..", 180°"..")");
		elseif k==4 then
		core.host:execute("drawLine", k*1000+1*100+i, source:date(first), low +DEGREE270[i]*Step*source:pipSize(), source:date(p),low +DEGREE270[i]* Step*source:pipSize(), COLOR);
		core.host:execute("drawLabel", k*1000+2*100+ i,  source:date(p)+2*size, low +DEGREE270[i]*Step*source:pipSize(), "(" ..tostring(DEGREE270[i]) ..", 270°" ..")");
		
		elseif k==5 then
		core.host:execute("drawLine", k*1000+1*100+i, source:date(first), low +DEGREE45[i]*Step*source:pipSize(), source:date(p),low +DEGREE45[i]* Step*source:pipSize(), COLOR);
		core.host:execute("drawLabel", k*1000+2*100+ i,  source:date(p)+2*size, low +DEGREE45[i]*Step*source:pipSize(), "(" ..tostring(DEGREE45[i]) ..", 45°" ..")");
		elseif k==6 then
		core.host:execute("drawLine", k*1000+1*100+i, source:date(first), low +DEGREE135[i]*Step*source:pipSize(), source:date(p),low +DEGREE135[i]* Step*source:pipSize(), COLOR);
		core.host:execute("drawLabel", k*1000+2*100+ i,  source:date(p)+2*size, low +DEGREE135[i]*Step*source:pipSize(), "(" ..tostring(DEGREE135[i]) ..", 135°" ..")");
		elseif k==7 then
		core.host:execute("drawLine", k*1000+1*100+i, source:date(first), low +DEGREE225[i]*Step*source:pipSize(), source:date(p),low +DEGREE225[i]* Step*source:pipSize(), COLOR);
		core.host:execute("drawLabel", k*1000+2*100+ i,  source:date(p)+2*size, low +DEGREE225[i]*Step*source:pipSize(), "(" ..tostring(DEGREE225[i]) ..", 225°" ..")");
		elseif k==8 then
		core.host:execute("drawLine", k*1000+1*100+i, source:date(first), low +DEGREE315[i]*Step*source:pipSize(), source:date(p),low +DEGREE315[i]* Step*source:pipSize(), COLOR);
		core.host:execute("drawLabel", k*1000+2*100+ i,  source:date(p)+2*size, low +DEGREE315[i]*Step*source:pipSize(), "(" ..tostring(DEGREE315[i]) ..", 315°" ..")");		
		end  
end