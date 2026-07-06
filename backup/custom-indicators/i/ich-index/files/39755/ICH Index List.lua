-- Id: 7306
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=23054

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
    indicator:name("Ichimoku Index List");
    indicator:description("Ichimoku Index List");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

	indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addString("Type", "Period Selection", "", "Identical");
    indicator.parameters:addStringAlternative("Type", "Identical for all", "", "Identical");
    indicator.parameters:addStringAlternative("Type", "Source Specific", "", "Source Specific");
    indicator.parameters:addInteger("Period", "One for All Period", "", 26);
	
	indicator.parameters:addInteger("SL", "SL Period", "", 26);
	indicator.parameters:addInteger("TL", "TL Period", "", 26);
	indicator.parameters:addInteger("CS", "CS Period", "", 26);
	indicator.parameters:addInteger("SA", "CA Period", "", 26);
    indicator.parameters:addInteger("SB", "CB Period", "", 26);
	
	indicator.parameters:addGroup("Ichimoku Calculation");	
	indicator.parameters:addInteger("TS", "Tenkan-sen period", "Tenkan-sen period", 9, 1, 1000);
    indicator.parameters:addInteger("KS", "Kijun-sen period", "Kijun-sen period", 26, 1, 1000);
    indicator.parameters:addInteger("SS", "Senkou Span B period", "Senkou Span B period", 52, 1, 1000);
	
	indicator.parameters:addGroup("Style");	
    indicator.parameters:addColor("Up_color", "Color of Up", "Color of Up", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Dn_color", "Color of Down", "Color of Down", core.rgb(255, 0, 0));
	--indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
  --  indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
  --  indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
	
	--indicator.parameters:addGroup("Levels Style" ); 
   -- indicator.parameters:addInteger("level_overboughtsold_width", "Width", "", 1, 1, 5);
   -- indicator.parameters:addInteger("level_overboughtsold_style", "Sryle", "", core.LINE_SOLID);
	--indicator.parameters:setFlag("level_overboughtsold_style", core.FLAG_LEVEL_STYLE);
   -- indicator.parameters:addColor("level_overboughtsold_color", "Color", "", core.rgb(0, 0, 255));
	
	indicator.parameters:addGroup("List Style"); 
    indicator.parameters:addInteger("Size", "Font Size", "", 13);  
	indicator.parameters:addInteger("Shift", "Vertical Shift", "", -50);  
    indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0));
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Period;
local TS, KS,SS;
local first;
local source = nil;
local ICH;
local Label, Size, Shift;
local P={};
-- Streams block

local Stream={};
local Short={"SL", "TL", "CS", "SA", "SB"};
local Type;
local VShift={};
local HShift={};

local F={};
local Font={};
local Data={};
local Color={};
local Last={};
local RowLabel={""};
local ColumnLabel={};
local Row,Column;
local ID={};
local Count;
local LastPeriod;
local LastValue;
local Up_color,Dn_color;
-- Routine
function Prepare(nameOnly)
	
	P[1]=instance.parameters.SL;
	P[2]=instance.parameters.TL;
	P[3]=instance.parameters.CS;
	P[4]=instance.parameters.SA;
	P[5]=instance.parameters.SB;
	
     Type=instance.parameters.Type;
    Up_color=instance.parameters.Up_color;
	Dn_color=instance.parameters.Dn_color;
     Label=instance.parameters.Label;
    Size=instance.parameters.Size;
	Shift=instance.parameters.Shift;
    Period = instance.parameters.Period;	
    source = instance.source;
	KS = instance.parameters.KS;
	TS = instance.parameters.TS;
	SS = instance.parameters.SS;
	
	
	  local name;
	if Type == "Identical" then
    name	= profile:id() .. "(" .. source:name() .. ", " .. tostring(Period)  .. ", " .. tostring(KS) .. ", " .. tostring(TS) .. ", " .. tostring(SS).. ", " .. tostring(Type).. ")";
	else
	 name	= profile:id() .. "(" .. source:name() .. ", " .. tostring(P[1]) .. ", " .. tostring(P[2]).. ", " .. tostring(P[3]).. ", " .. tostring(P[4]).. ", " .. tostring(P[5])
	 .. ", " .. tostring(KS) .. ", " .. tostring(TS) .. ", " .. tostring(SS).. ", " .. tostring(Type).. ")";
	end
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	Set(3,5);
   
	F[1] = core.host:execute("createFont", "Courier", Size , false, false);
	F[2] = core.host:execute("createFont", "Courier", Size , false, true);
	F[3] = core.host:execute("createFont", "Wingdings", Size , false, false);
	
	ICH = core.indicators:create("ICH", source,  TS , KS , SS);
 
	Stream[1] = ICH:getStream(0);
	Stream[2] = ICH:getStream(1);
	Stream[3] = ICH:getStream(2);
	Stream[4] = ICH:getStream(3);
	Stream[5] = ICH:getStream(4);
	
	first= source:first() ;

  

    
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values


function Set(R,C)

    Column=C;
	Row=R;
	Count=0;
   	
	
	local i,id;
	
	for i = 1, Row, 1 do   
	   		
		   for j = 1, Column, 1 do  
		   
		   Count= Count+1;		
		   ID[ Count]= Count;
		   id = ID[ Count];		  
		   
		   VShift[id]= RowShift(j);
		   HShift[id]= ColumnShift(i);
		   end   
	end	   
end

function Update(period, mode)
 	
	ICH:update(mode);	
	
	if period < source:size()-1 or not source:hasData(period) then
	return;
	end
	
	local i, j;	
	local Up={}
    local Dn={};
	local X;
	
	 
	 
	
		--
		
		     for j = 1 , 5 , 1 do
			 
			    if Type == "Identical" then
				X = Period;
				else
				X = P[j];
				end
				--
				for i=  period-X+1, period, 1 do
		
		        if i == period-X+1 then
				Up[j]=0;
				Dn[j]=0;
				end
				
				
					 if j== 3 then 
					    if Stream[j]:hasData(i-KS) then
						
							if source.close[i ] > Stream[j][period-KS] then
							Up[j]=Up[j]+1;
							end
							
							if source.close[i] < Stream[j][period-KS] then
							Dn[j]=Dn[j]+1;
							end
						 end	
					 else
						if Stream[j]:hasData(i) then
						
							if source.close[i] > Stream[j][period] then
							Up[j]=Up[j]+1;
							end
							
							if source.close[i] < Stream[j][period] then
							Dn[j]=Dn[j]+1;
							end
						end	
					 end	
		    end
		end
		
	
   
		if  source[source:size()-1] == LastValue 
	and source:serial(source:size()-1) == LastPeriod	
	then
	return;
	end
	
	LastPeriod= source:serial(source:size()-1);
    LastValue= source[source:size()-1];
	
	local i, id;
	
	for i= 1, 5 , 1 do
		
		   
		     id= ID[i];
			 Color[id] = Label;
			 Font[id] = F[1]; 			 
			
			
			  ---    Id, Value
			  Entry (id, Short[i]);			
	end
	 
	
	
	
	for i = 6, 10, 1 do   
	   		
		
		   
		     id= ID[i];
			 Color[id] = Up_color;
			 Font[id] = F[1]; 			 
			
			
			  ---    Id, Value
			  Entry (id, Up[i-5]);			 
		 
	end	  

    	for i = 11, 15, 1 do   
	   		
		
		   
		     id= ID[i];
			 Color[id] = Dn_color;
			 Font[id] = F[1]; 			 
			
			
			  ---    Id, Value
			  Entry (id, Dn[i-10]);			 
		 
	end	   	
	
end


function Entry (id, value)

	    if  Data[id]~= value then
		
		  Data[id]= value;			  
		  DRAW (id)
		end	  
end			  
			  

function DRAW (id)
     		     			
		 core.host:execute("drawLabel1", id , VShift[id],  core.CR_RIGHT,  HShift[id] , core.CR_TOP, core.H_Left, core.V_Center, Font[id], Color[id], tostring(Data[id]));
	
end

function RowShift(R) 
   return -50 + -R *100;
end


function ColumnShift(C)
   return Shift +  50+ C *Size*1.5;
end


function ReleaseInstance()
       core.host:execute("deleteFont", F[1]);
	   core.host:execute("deleteFont", F[2]);
	   core.host:execute("deleteFont", F[3]);
 end  



