-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=70753

--+------------------------------------------------------------------+
--|                               Copyright © 2020, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--|                           https://AppliedMachineLearning.systems |
--|                                Patreon :  https://goo.gl/GdXWeN  |
--+------------------------------------------------------------------+


-- Indicator profile initialization routine

function Init()
    indicator:name("SHERIFF’S LINES");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period", "Period", "", 9, 1, 2000);
    indicator.parameters:addDouble("Factor1", "1. Factor", "", 5.0);
    indicator.parameters:addDouble("Factor2", "2. Factor", "", 5.0);
	indicator.parameters:addDouble("Factor3", "3. Factor", "", 5.0);
	indicator.parameters:addDouble("Factor4", "4. Factor", "", 5.0);
	indicator.parameters:addDouble("Factor5", "5. Factor", "", 5.0);
	indicator.parameters:addDouble("Factor6", "6. Factor", "", 5.0);
	
	indicator.parameters:addGroup("1. Line Style"); 	
    indicator.parameters:addColor("color1", "Line Color", "", core.rgb(0, 128, 0));
	indicator.parameters:addInteger("style1", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width1", "Line Width", "", 3, 1, 5);
	
	
	indicator.parameters:addGroup("2. Line Style"); 	
    indicator.parameters:addColor("color2", "Line Color", "", core.rgb(0, 128, 0));
	indicator.parameters:addInteger("style2", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width2", "Line Width", "", 3, 1, 5);
	
	
	
	indicator.parameters:addGroup("3. Line Style"); 	
    indicator.parameters:addColor("color3", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style3", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width3", "Line Width", "", 3, 1, 5);
	
	
	indicator.parameters:addGroup("4. Line Style"); 	
    indicator.parameters:addColor("color4", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style4", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style4", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width4", "Line Width", "", 3, 1, 5);
	
	
	
	indicator.parameters:addGroup("5. Line Style"); 	
    indicator.parameters:addColor("color5", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style5", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style5", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width5", "Line Width", "", 3, 1, 5);
	
	
	indicator.parameters:addGroup("6. Line Style"); 	
    indicator.parameters:addColor("color6", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style6", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style6", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width6", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local Period; 
local first;
local source = nil;
 
local ATR,MA;
local Factor={};
local Line={};

local color={};
local style={};
local width={};
local TrendDown1, TrendUp1;
local IND0, IND1, IND2;
-- Routine
 function Prepare(nameOnly)   
 
 
    Period= instance.parameters.Period;
	
	
	for i= 1, 4 , 1 do 	
	color[i]= instance.parameters:getColor("color"..i);	
	style[i]= instance.parameters:getInteger("style"..i);	
	width[i]= instance.parameters:getInteger("width"..i);	
	end
 
	
	for i= 1, 6 , 1 do 	
	Factor[i]= instance.parameters:getDouble("Factor"..i);	
	end
	
	local Parameters= Period;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 
	
	ATR = core.indicators:create("ATR", source, Period);
    MA = core.indicators:create("MVA", source.close, Period);


    first=ATR.DATA:first()+1;
	
	TrendUp1= instance:addInternalStream(0, 0);
	TrendDown1= instance:addInternalStream(0, 0);
	IND0= instance:addInternalStream(0, 0);
    IND1= instance:addInternalStream(0, 0);
	IND2= instance:addInternalStream(0, 0);
    for i= 1, 4, 1 do
	Line[i] = instance:addStream("Line"..i , core.Line, i..". Line", i..". Line", color[i], first);
	Line[i]:setWidth( width[i]);
    Line[i]:setStyle( style[i]);
    Line[i]:setPrecision(math.max(2, source:getPrecision()));
	end
	
end

-- Indicator calculation routine
function Update(period, mode)
   
    ATR:update(mode);
	MA:update(mode);
 
	if period < first then
	return;
	end
	 
	 
   local Dn1A=(Factor[1]*ATR.DATA[period-1]) ;
   local DnA=(Factor[2]*ATR.DATA[period-1]) ;
   local Dn2A=(Factor[3]*ATR.DATA[period-1]) ;
   local UpA=(Factor[4]*ATR.DATA[period-1]) ;
   local Up2A=(Factor[5]*ATR.DATA[period-1]) ;
   local Up1A=(Factor[6]*ATR.DATA[period-1]) ;
   
   
   local Up1 =(MA.DATA[period]) - (Up1A ) ;
   local Dn1 =(MA.DATA[period]) + (Dn1A ) ;
   
   
 
	
	if  MA.DATA[period-1] >TrendUp1[period-1] then
	TrendUp1[period]=  math.max(Up1,TrendUp1[period-1]);
	else
	TrendUp1[period]=  Up1;
	end 
	   
   if  MA.DATA[period-1] <TrendDown1[period-1] then
	TrendDown1[period]= math.min(Dn1,TrendDown1[period-1])
	else
	TrendDown1[period]= Dn1;
	end
	   
	   
	   if MA.DATA[period] > IND0[period-1] then
	   IND0[period]=TrendUp1[period];
	   else
	   IND0[period]=TrendDown1[period];
	   end
	   

    
   if (IND0[period] >= MA.DATA[period]) then
    IND1[period] =IND0[period];
   else 
    IND1[period] = IND1[period-1]; 
	end
 
   if (IND0[period] <= MA.DATA[period]) then
    IND2[period] =IND0[period];
   else 
    IND2[period] = IND2[period-1]; 
   end

   
   local  Up =(MA.DATA[period]) - (UpA ) ;
   local  Dn =math.max(((Line[3][period-1]) + (DnA )) ,IND1[period]);
   local  Up2 =math.min(((Line[2][period-1]) - (Up2A )) , IND2[period]) ;
   local  Dn2 =(MA.DATA[period]) +  (Dn2A ) ;
 

   if MA.DATA[period-1] >Line[3][period-1] then
   Line[3][period]=math.max(Up ,Line[3][period-1]) 
   else
   Line[3][period]=Up;
   end
   
   
   
 
   if MA.DATA[period-1]<Line[2][period-1] then
   Line[2][period]=math.min(Dn2 ,Line[2][period-1]) 
   else
   Line[2][period]=Dn2  ;
   end
   
   
   
 
   
   if MA.DATA[period-1] > math.min(Line[4][period-1],  IND2[period-1] )then
   Line[4][period]=  math.max(Up2  ,math.min(Line[4][period-1] ,IND2[period-1]))
   else
   Line[4][period]= Up2 ;
   end
  
   
   if MA.DATA[period-1] < math.max( Line[1][period-1],IND1[period-1] ) then
   Line[1][period]=math.min(Dn  ,math.max( Line[1][period-1] ,IND1[period-1]));
   else
   Line[1][period]=Dn;
   end 
   

end