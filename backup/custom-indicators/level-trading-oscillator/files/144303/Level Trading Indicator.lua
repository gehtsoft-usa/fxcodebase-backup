-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71655

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
--|SOL Address            : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                           |
--|Cardano/ADA            : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv             |  
--|Dogecoin Address       : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                     |
--|SHIB Address           : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                             |                                
--+------------------------------------------------------------------------------------------------+



function Init()
    indicator:name("Level Trading Indicator");
    indicator:description("Level Trading");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
  
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Frame", "Number of fractals", "Number of fractals", 4, 1,99);
 
	 
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("Top", "Top Line Color", "", core.rgb(255, 0, 0)); 
    indicator.parameters:addColor("Bottom", "Bottom Line Color", "", core.rgb(0, 255, 0)); 	
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	 
end
local Oscillator;
local source;
local Frame;
local Low, High; 
local first; 
local Top, Bottom;
function Prepare(nameOnly)

	Frame = instance.parameters.Frame;
    local name = profile:id() .. " ( " .. Frame  .. " )";
    instance:name(name);
	
    if   (nameOnly) then
        return;
    end	
	
	Top = instance.parameters.Top;
	Bottom = instance.parameters.Bottom;
    

    Fractal = instance:addInternalStream(0, 0);
    Direction = instance:addInternalStream(0, 0); 


	Oscillator = instance:addInternalStream(0, 0); 
 
    source = instance.source;
	first=source:first()+Frame*2;
 
end

function Update(period, mode)
 
 
 
    if (period <= first) then 
	return;
	end
	
 
	period = period-Frame;	

	    local test=true;
 
	
		
		
         for i= 1, Frame, 1 do
		
		     if  source.high[period] < source.high[period+i] or  source.high[period] < source.high[period-i] then
			 test=false;
			 end
			
		 end	
		 
		 if test then
		   Fractal[period]=1;		   
		 end

        test=true; 
		
        for i= 1, Frame, 1 do
		
		     if  source.low[period] > source.low[period+i] or source.low[period] > source.low[period-i] then
			 test=false;
			 end
			
		 end	
	   
	      if test then
		  Fractal[period]=-1;		
		  end
		  
	--period = period+Frame;		  
        
    local D1,I1=HighLow1(period);
    local D2,I2=HighLow2(period);	
	
	
	Direction[period]=Direction[period-1];
	
	if Direction[period] ==0 then 
	   Direction[period]=D1;
       return; 	   
	end
	
	
	if Direction[period] ==1 then 
	
       if 	D1 == -1 and source.low[I1] < source.high[I2] then
	    Direction[period] =-1 
	   end
	   
 
    else
	
	   if 	D1 == 1 and source.high[I1] > source.low[I2] then
	    Direction[period] = 1 
	   end
 
	end
	 
	
	if Direction[period]== 1 then
	Oscillator[period]=-1;
	else
	Oscillator[period]=1;
    end	
	
    LastTwo(period);
	  

end

function  LastTwo(period)

 
local Count=0;

	for i= period, source:first(), -1 do

		 if Oscillator[i]~= Oscillator[i-1] then
		 Count=Count+1;
		 
		 
				  if Direction[i]== 1 then
				  core.host:execute("drawLine", Count, source:date(i ), source.high[i ], source:date(source:size()-1), source.high[i ], Top); 
				  else
				  core.host:execute("drawLine", Count, source:date(i ), source.low[i ], source:date(source:size()-1), source.low[i ], Bottom); 
				  end
	   
			 if Count>=  2 then
			 break;
			 end		 
		 end

	end
 

end


function  HighLow1(period)

local D,I=0,0;

	for i= period, source:first(), -1 do

		if Fractal[period]==1 then
		D=1;
		I=i;
		break;
		end
		if Fractal[period]==-1 then
		D=-1;
		I=i;	
		break;		
		end

	end

return D,I;

end

function HighLow2(period)

local D,I=0,0;
local d = 0;

	for i= period, source:first(), -1 do

		if Fractal[period]==1 and d==0 then
		d=1;  
		end
		if Fractal[period]==-1 and  d==0 then
		d=-1; 	
		end

		if Fractal[period]==1 and d~=0 then
		D=1;
		I=i;
		break;
		end
		if Fractal[period]==-1 and  d~=0 then
		D=-1;
		I=i;	
		break;		
		end

	end

return D,I;

end
