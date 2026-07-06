-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=2779


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
    indicator:name("Buy Sell Volume Pivots");
    indicator:description("Buy Sell Volume Pivots");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	
	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Lookback", "Lookback", "", 100, 10, 1000);
    indicator.parameters:addInteger("Number", "Number of Lines", "", 5);
	indicator.parameters:addBoolean("Show", "Show Vertical Lines", "", true);
	indicator.parameters:addBoolean("HShow", "Show Horizontal Lines", "", true);
	
	indicator.parameters:addGroup("Style");
	
   indicator.parameters:addGroup(" Buy Lines");
	
	indicator.parameters:addColor("colorB0", "Max. Volume Line", "Color of Line", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("widthB0", "Line width", "", 5, 1, 5);
    indicator.parameters:addInteger("styleB0", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleB0", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("colorB1", "Min. Volume Line", "Color of Line", core.rgb(0, 200, 0));
	indicator.parameters:addInteger("widthB1", "Line width", "", 5, 1, 5);
    indicator.parameters:addInteger("styleB1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleB1", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("colorB11", "1. Zone Volume Line", "Color of Line", core.rgb(0, 155, 0));
	indicator.parameters:addInteger("widthB11", "Line width", "", 5, 1, 5);
    indicator.parameters:addInteger("styleB11", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleB11", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("colorB21", "2. Zone Volume Line", "Color of Line", core.rgb(0, 155, 0));
	indicator.parameters:addInteger("widthB21", "Line width", "", 4, 1, 5);
    indicator.parameters:addInteger("styleB21", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleB21", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("colorB31", "3. Zone Volume Line", "Color of Line", core.rgb(0, 155, 0));
	indicator.parameters:addInteger("widthB31", "Line width", "", 3, 1, 5);
    indicator.parameters:addInteger("styleB31", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleB31", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("colorB41", "4. Zone Volume Line", "Color of Line", core.rgb(0, 155, 0));
	indicator.parameters:addInteger("widthB41", "Line width", "", 2, 1, 5);
    indicator.parameters:addInteger("styleB41", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleB41", core.FLAG_LINE_STYLE);
	
 
	
	indicator.parameters:addColor("colorB51", "5. Zone Volume Line", "Color of Line", core.rgb(0, 155, 0));
	indicator.parameters:addInteger("widthB51", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleB51", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleB51", core.FLAG_LINE_STYLE);
	
	 indicator.parameters:addGroup(" Sell Lines");

   indicator.parameters:addColor("colorS0", "Max. Volume Line", "Color of Line", core.rgb(255, 0 , 0));
	indicator.parameters:addInteger("widthS0", "Line width", "", 5, 1, 5);
    indicator.parameters:addInteger("styleS0", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleS0", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("colorS1", "Min. Volume Line", "Color of Line", core.rgb(  200, 0 , 0));
	indicator.parameters:addInteger("widthS1", "Line width", "", 5, 1, 5);
    indicator.parameters:addInteger("styleS1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleS1", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("colorS11", "1. Zone Volume Line", "Color of Line", core.rgb(155, 0, 0 ));
	indicator.parameters:addInteger("widthS11", "Line width", "", 5, 1, 5);
    indicator.parameters:addInteger("styleS11", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleS11", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("colorS21", "2. Zone Volume Line", "Color of Line", core.rgb(155, 0, 0 ));
	indicator.parameters:addInteger("widthS21", "Line width", "", 4, 1, 5);
    indicator.parameters:addInteger("styleS21", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleS21", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("colorS31", "3. Zone Volume Line", "Color of Line", core.rgb(155, 0, 0 ));
	indicator.parameters:addInteger("widthS31", "Line width", "", 3, 1, 5);
    indicator.parameters:addInteger("styleS31", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleS31", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("colorS41", "4. Zone Volume Line", "Color of Line", core.rgb(155, 0, 0 ));
	indicator.parameters:addInteger("widthS41", "Line width", "", 2, 1, 5);
    indicator.parameters:addInteger("styleS41", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleS41", core.FLAG_LINE_STYLE);
	
 
	
	indicator.parameters:addColor("colorS51", "5. Zone Volume Line", "Color of Line", core.rgb(155, 0, 0 ));
	indicator.parameters:addInteger("widthS51", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("styleS51", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("styleS51", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

 local BC={};
 local BW={};
 local BS={};
 local SC={};
 local SW={};
 local SS={};
 local HShow;
local Lookback;
local Show;
 local first;
local source = nil;
 
-- Streams block
local buyLine = {};
local sellLine = {};
local Number=0;
local buyvolume;
local sellvolume;
local Last;
local buyArray;
local sellArray;
-- Routine
function Prepare(nameOnly)
    Show= instance.parameters.Show;
	HShow= instance.parameters.HShow;
    Lookback = instance.parameters.Lookback;
	Number = instance.parameters.Number;
    
    source = instance.source;
    first = source:first();
	
	BC["X"]=instance.parameters.colorB0;
	BS["X"]=instance.parameters.styleB0;
	BW["X"]=instance.parameters.widthB0;
	BC["O"]=instance.parameters.colorB1;
	BS["O"]=instance.parameters.styleB1;
	BW["O"]=instance.parameters.widthB1;
	
	SC["X"]=instance.parameters.colorS0;
	SS["X"]=instance.parameters.styleS0;
	SW["X"]=instance.parameters.widthS0;
	SC["O"]=instance.parameters.colorS1;
	SS["O"]=instance.parameters.styleS1;
	SW["O"]=instance.parameters.widthS1;
	

    local name = profile:id() .. "(" .. source:name() .. ", " .. Lookback  .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	buyvolume  = instance:addInternalStream(0, 0);
	sellvolume = instance:addInternalStream(0, 0);
	
	buyArray  = instance:addInternalStream(0, 0);
	sellArray = instance:addInternalStream(0, 0);

	
	for i = 1, Number , 1 do
	
	
				if  (5/Number)*i <= 1 and (5/Number)*i > 0 then
				 BC[i]= instance.parameters.colorB11;
				 BS[i]= instance.parameters.styleB11;
				 BW[i]= instance.parameters.widthB11;
				end
			 if   (5/Number)*i <= 2 and (5/Number)*i > 1  then
			 BC[i]= instance.parameters.colorB21;
			 BS[i]= instance.parameters.styleB21;
			 BW[i]= instance.parameters.widthB21;
			 end
			 
			 if   (5/Number)*i <= 3 and (5/Number)*i > 2  then
			BC[i]= instance.parameters.colorB31;
			 BS[i]= instance.parameters.styleB31;
			 BW[i]= instance.parameters.widthB31;
			end
			
			if  (5/Number)*i <= 4  and (5/Number)*i > 3  then
			 BC[i]= instance.parameters.colorB41;
			 BS[i]= instance.parameters.styleB41;
			 BW[i]= instance.parameters.widthB41;
			end
			if  (5/Number)*i <= 5 and (5/Number)*i > 4  then
			BC[i]= instance.parameters.colorB51;
			 BS[i]= instance.parameters.styleB51;
			 BW[i]= instance.parameters.widthB51;
			end
	
			if i == 1 then
			buyLine[i] = instance:addStream("LineB"..i, core.Line, name .. ".Line"..i, "Line"..i, BC["X"], first);
			buyLine[i]:setWidth(BW["X"]);
			buyLine[i]:setStyle(BS["X"]);
			elseif i == Number then
			buyLine[i] = instance:addStream("LineB"..i, core.Line, name .. ".Line"..i, "Line"..i, BC["O"], first);
			buyLine[i]:setWidth(BW["O"]);
			buyLine[i]:setStyle(BS["O"]);
			else
			buyLine[i] = instance:addStream("LineB"..i, core.Line, name .. ".Line"..i, "Line"..i, BC[i], first);
			buyLine[i]:setWidth(BW[i]);
			buyLine[i]:setStyle(BS[i]);
			end
			
			
			if  (5/Number)*i <= 1 and (5/Number)*i > 0 then
				 SC[i]= instance.parameters.colorS11;
				 SS[i]= instance.parameters.styleS11;
				 SW[i]= instance.parameters.widthS11;
				end
			 if   (5/Number)*i <= 2 and (5/Number)*i > 1  then
			 SC[i]= instance.parameters.colorS21;
			 SS[i]= instance.parameters.styleS21;
			 SW[i]= instance.parameters.widthS21;
			 end
			 
			 if   (5/Number)*i <= 3 and (5/Number)*i > 2  then
			SC[i]= instance.parameters.colorS31;
			 SS[i]= instance.parameters.styleS31;
			 SW[i]= instance.parameters.widthS31;
			end
			
			if  (5/Number)*i <= 4  and (5/Number)*i > 3  then
			 SC[i]= instance.parameters.colorS41;
			 SS[i]= instance.parameters.styleS41;
			 SW[i]= instance.parameters.widthS41;
			end
			if  (5/Number)*i <= 5 and (5/Number)*i > 4  then
			SC[i]= instance.parameters.colorS51;
			 SS[i]= instance.parameters.styleS51;
			 SW[i]= instance.parameters.widthS51;
			end
	
			if i == 1 then
			sellLine[i] = instance:addStream("LineS"..i, core.Line, name .. ".Line"..i, "Line"..i, SC["X"], first);
			sellLine[i]:setWidth(SW["X"]);
			sellLine[i]:setStyle(SS["X"]);
			elseif i == Number then
			sellLine[i] = instance:addStream("LineS"..i, core.Line, name .. ".Line"..i, "Line"..i, SC["O"], first);
			sellLine[i]:setWidth(SW["O"]);
			sellLine[i]:setStyle(SS["O"]);
			else
			sellLine[i] = instance:addStream("LineS"..i, core.Line, name .. ".Line"..i, "Line"..i, SC[i], first);
			sellLine[i]:setWidth(SW[i]);
			sellLine[i]:setStyle(SS[i]);
			end
	end
	 
	
	core.host:execute ("setTimer", 1, 1)
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)  
 

  

	if period < source:size()-1 	
	or period < Lookback
	or source:serial(period) == Last
	then
			return;					
	end		
	
	Last= source:serial(period);
	
	for i = source:size()-1 -Lookback, period, 1 do	
       Filter(i);
    end
	
  
  Sort(period);
 
 
end

function Filter (period)

  if source.close[period]> source.close[period-1] then
  buyvolume[period]= source.volume[period];
  sellvolume[period]=0;
  else
  sellvolume[period]= source.volume[period];
  buyvolume[period]=0;
  end
  
  
end
function Sort(period)

	local max, maxpos, i;
		
	for i = 1, Number ,1 do	
	    buyArray[i] =0;
		max, maxpos = mathex.max (buyvolume, source:size()-1 -Lookback, source:size()-1);
		buyArray[i] =maxpos;
		buyvolume[maxpos]=0;
		
		
		 sellArray[i] =0;
		max, maxpos = mathex.max ( sellvolume, source:size()-1 -Lookback, source:size()-1);
		 sellArray[i] =maxpos;
		 sellvolume[maxpos]=0;
	end	
end		



function AsyncOperationFinished(cookie, success, message)

  if cookie ~= 1 then
  return  0;
  end
  

  local period;	 
  period = source:size()-1  
  local V={};
  local D={};
  
  
  if Number==0 or Number== nil then
  return;
  end
  
  local Flag= false;
  
  
  for i = 1 , Number, 1 do  
  if sellArray[i]== nil or  buyArray[i] == nil 
  or  sellArray[i]== 0 or  buyArray[i] == 0 
  or sellvolume[sellArray[i]]== 0 or sellvolume[sellArray[i]]==nil
   or buyvolume[buyArray[i]]== 0 or buyvolume[buyArray[i]]==nil
   then
   Fkag=true; 
  end
 end
	if Flag== true then
    return;
    end
	
		   for i = 1 , Number, 1 do
				 
				      V[i]= buyvolume[buyArray[i]];
					  D[i]= buyArray[i];
						 
						 
						 if HShow then
						 core.drawLine(buyLine[i], core.range(first, source:size()-1), source.close[D[i]], first, source.close[D[i]], source:size()-1);
						end
						
						
						if Show then
							    if i == 1 then
								core.host:execute ("drawLine", i,  source:date(D[i]), 0, source:date(D[i]), source.high[period] *2,  BC["X"], BS["X"],  BW["X"]);
								elseif i == Number then
								core.host:execute ("drawLine", i,  source:date(D[i]), 0, source:date(D[i]), source.high[period] *2,   BC["O"], BS["O"],  BW["O"]);
								else
								core.host:execute ("drawLine", i,  source:date(D[i]), 0, source:date(D[i]), source.high[period] *2,  BC[i], BS[i],  BW[i]);
								end
							  
						end
						
					  V[i]= sellvolume[sellArray[i]];
					  D[i]= sellArray[i];
						 
						 if HShow then
						 core.drawLine(sellLine[i], core.range(first, source:size()-1), source.close[D[i]], first, source.close[D[i]], source:size()-1);
						 end
						
					     	if Show then
						
						      if i == 1 then
							  core.host:execute ("drawLine", Number+ i,  source:date(D[i]), 0, source:date(D[i]), source.high[period] *2,  SC["X"], SS["X"],  SW["X"]);
								elseif i == Number then
								core.host:execute ("drawLine", Number+ i,  source:date(D[i]), 0, source:date(D[i]), source.high[period] *2,  SC["O"], SS["O"],  SW["O"]);
								else
								core.host:execute ("drawLine", Number+ i,  source:date(D[i]), 0, source:date(D[i]), source.high[period] *2,  SC[i], SS[i],  SW[i]);
								
							  
						        end
						end
						
				end
		
  end	
					 
			
			


 function ReleaseInstance()
 core.host:execute ("killTimer", 1)
end