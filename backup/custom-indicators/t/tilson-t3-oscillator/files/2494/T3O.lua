-- Id: 885
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1305

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
    indicator:name("Tilson T3 Oscillator");
    indicator:description("Tilson T3 Oscillator");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Oscillator);
	
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("F1", "First T3 Period", "First T3 Period", 4,2,2000);
	indicator.parameters:addInteger("F2", "Second T3 Period", "Second T3 Period", 5,2,2000);
	indicator.parameters:addInteger("N", "Normalize Period", "Normalize Period", 10,0,2000);
	 indicator.parameters:addDouble("VF", "Volume Factor", "Volume Factor", 0.7);
	 
	 indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("T3O1_color", "Color of Short T3O", "Color of Short T3O", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);

	  indicator.parameters:addColor("T3O2_color", "Color of Long T3O", "Color of  Long T3O", core.rgb(0, 255, 0));
	  indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
      indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
      indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local T3Frame1=nil;
local T3Frame2=nil;
local NormalizeFrame=nil;
local T=nil

local first;
local source = nil;

-- Streams block
local T3O1 = nil;
local T3O2 = nil;
local Temp1= nil;
local Temp2= nil;

-- Routine
function Prepare(nameOnly)
     source = instance.source;
     
	
	 T = instance.parameters.VF;
	 NormalizeFrame = instance.parameters.N;
	 T3Frame1= instance.parameters.F1;
	 T3Frame2= instance.parameters.F2;
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. T3Frame1 .. ", " .. T3Frame2 .. ", " ..  NormalizeFrame  .. ", " .. T  .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end

	Temp2  = instance:addInternalStream(0, 0);
	Temp1 = instance:addInternalStream(0, 0);
	
	assert(core.indicators:findIndicator("T3") ~= nil, "Please, download and install T3.LUA indicator");    
	assert(core.indicators:findIndicator("GD") ~= nil, "Please, download and install GD.LUA indicator");    

	 T31 = core.indicators:create("T3", source, T, T3Frame1);
	 T32 = core.indicators:create("T3", source, T, T3Frame2);

    T3O1 = instance:addStream("T3A", core.Line, name, "T3O Short", instance.parameters.T3O1_color, T31.DATA:first() +  NormalizeFrame );
    T3O1:setPrecision(math.max(2, instance.source:getPrecision()));
	T3O1:setWidth(instance.parameters.width1);
    T3O1:setStyle(instance.parameters.style1);
	T3O2 = instance:addStream("T3B", core.Line, name, "T3O Long", instance.parameters.T3O2_color, T31.DATA:first() +  NormalizeFrame );
    T3O2:setPrecision(math.max(2, instance.source:getPrecision()));
	T3O2:setWidth(instance.parameters.width2);
    T3O2:setStyle(instance.parameters.style2);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period,mode)

T31:update(mode);
T32:update(mode);

if period > T31.DATA:first() +  NormalizeFrame then
			 Normalize1(period,NormalizeFrame);		
			T3O1[period] = (Temp1[period]*100+100)/2;
end


 
					 

		
if period > T32.DATA:first() +  NormalizeFrame then       		 
			 Normalize2(period,NormalizeFrame);		
			T3O2[period] = (Temp2[period]*100+100)/2;		
 end   
		
end

function Normalize1(i, Frame)

local  High,Low;
local Under;

if Temp1[i-1] == nil then
 Temp1[i-1] = T31.DATA[i-1];
 end 
 
 
        Low, High = mathex.minmax (T31.DATA,  i-Frame+1 , i );
	 
		 
				 if High - Low ==0  then
				 Under = 1 ;
				 else
				 Under = (High - Low);
				 end			 


		 Temp1[i]=0.5*2*((T31.DATA[i]-Low )/ Under - 0.5)+0.5 * Temp1[i-1];

			  if Temp1[i] > 0.9999 then

			   Temp1[i] = 0.9999;
			  end 

			  if Temp1[i] < -0.9999 then

			   Temp1[i] = -0.9999;
				
				end
				
end


function Normalize2(i, Frame)

local  High,Low;
local Under;

if Temp2[i-1] == nil then
 Temp2[i-1] = T32.DATA[i-1];
 end 
 
 
         Low,High = mathex.minmax (T32.DATA,  i-Frame+1, i);
		 
		 
				 if High - Low ==0  then
				 Under = 1 ;
				 else
				 Under = (High - Low);
				 end			 


		 Temp2[i]=0.5*2*((T32.DATA[i]-Low )/ Under - 0.5)+0.5 * Temp2[i-1];

			  if Temp2[i] > 0.9999 then

			   Temp2[i] = 0.9999;
			  end 

			  if Temp2[i] < -0.9999 then

			   Temp2[i] = -0.9999;
				
				end
				
end