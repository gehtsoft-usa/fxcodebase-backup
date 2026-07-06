-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=8109

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

function Init()
    indicator:name("Percentage Price Position");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation");
    indicator.parameters:addString("Mode", "Mode", "", "L");    
    indicator.parameters:addStringAlternative("Mode", "Live", "", "L");
    indicator.parameters:addStringAlternative("Mode", "End of Turn", "", "E");
	
    indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("IN", "Indicator color", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("NE", "Neutral color", "", core.rgb(0, 0, 0));		
    indicator.parameters:addColor("LABEL", "Label color", "", core.COLOR_LABEL);
     indicator.parameters:addInteger("Size", "Font Size", "", 10, 1, 20);

end


local font1, font2;
local fisrt, source;
local IN, NE, LABEL;

local Size;
local Lock;
local Mode;

function Prepare(nameOnly)  
    Size= instance.parameters.Size; 
    IN= instance.parameters.IN;
    NE= instance.parameters.NE;
    LABEL= instance.parameters.LABEL
     Mode= instance.parameters.Mode;
    source = instance.source;
    first= source:first();
  
	 
    local name =  profile:id()  ;
    
     name = name .."";  
    
    instance:name(name);
    if nameOnly then
      return;
    end
	
	font1 = core.host:execute("createFont", "Arial", Size, false, false);
	font2= core.host:execute("createFont", "Wingdings", 9, false, false);
	
end


function Update(period, mode)

         
	if not source:hasData(period) or  period < first then
	return
	end 
	
		
	DRAW(source.high , source.low , source.close, period);
			
      
end

function DRAW (max, min, value, period)


       if period == source:size()-1 
	and  Mode == "E"
        then	
	period= period-1;
        elseif  Mode == "E" then
        return;  	
	end
				

	
	if period ~= source:size()-1  
	and Mode == "L"
	then		
	return;	
	end
	
		
local id=1;
local Height= 700;
local i,j ;
local Range = max[period]-min[period];
local Percentage=  Range / 100;  
local Value = (value[period] -min[period] ) /  Percentage;   
local Index =  100/Height ;
local Color= NE;


   core.host:execute("drawLabel1", id, -50  - 30, core.CR_RIGHT, -50 , core.CR_BOTTOM, core.H_Left, core.V_Bottom, font1, LABEL,  string.format("%." .. 4 .. "f", min[period] ));
				id = id +1;
				
   core.host:execute("drawLabel1", id, -50 + 20, core.CR_RIGHT, -50 , core.CR_BOTTOM, core.H_Left, core.V_Bottom, font1, LABEL,  "0");
				id = id +1;	

   
core.host:execute("drawLabel1", id, -50  - 30, core.CR_RIGHT, -50 -Height , core.CR_BOTTOM, core.H_Left, core.V_Bottom, font1, LABEL, string.format("%." .. 4 .. "f", max[period])) ;  
				id = id +1;
				
   core.host:execute("drawLabel1", id, -50 + 20, core.CR_RIGHT, -50 -Height , core.CR_BOTTOM, core.H_Left, core.V_Bottom, font1, LABEL,  "100");
				id = id +1;	 


  core.host:execute("drawLabel1", id, -50  - 30, core.CR_RIGHT, -50 -Height/2 , core.CR_BOTTOM, core.H_Left, core.V_Bottom, font1, LABEL, string.format("%." .. 4 .. "f", min[period]+(max[period]-min[period])/2)) ;  
				id = id +1;
				
   core.host:execute("drawLabel1", id, -50 + 20, core.CR_RIGHT, -50 -Height/2 , core.CR_BOTTOM, core.H_Left, core.V_Bottom, font1, LABEL,  "50");
				id = id +1;



  core.host:execute("drawLabel1", id, -50  - 30, core.CR_RIGHT, -50 -(Height/4)*3 , core.CR_BOTTOM, core.H_Left, core.V_Bottom, font1, LABEL,   string.format("%." .. 4 .. "f", (min[period]+((max[period]-min[period])/4)*3))) ;  
  id = id +1;
				
   core.host:execute("drawLabel1", id, -50 + 20, core.CR_RIGHT, -50 -(Height/4)*3 , core.CR_BOTTOM, core.H_Left, core.V_Bottom, font1, LABEL,  "75");
				id = id +1;	  


  core.host:execute("drawLabel1", id, -50  - 30, core.CR_RIGHT, -50 -(Height/4)*1 , core.CR_BOTTOM, core.H_Left, core.V_Bottom, font1, LABEL,  string.format("%." .. 4 .. "f", (min[period]+((max[period]-min[period])/4)*1))) ;  
				id = id +1;
				
   core.host:execute("drawLabel1", id, -50 + 20, core.CR_RIGHT, -50 -(Height/4)*1 , core.CR_BOTTOM, core.H_Left, core.V_Bottom, font1, LABEL,  "25");
				id = id +1;


     core.host:execute("drawLabel1", id, -50  - 30, core.CR_RIGHT, -50 -Value /Index , core.CR_BOTTOM, core.H_Left, core.V_Bottom, font1, LABEL,  string.format("%." .. 4 .. "f", (value[period]))) ;  
				id = id +1;
	
    if 	round(Value, 1) ~= 100 and round(Value, 1) ~= 75 and round(Value, 1) ~= 50 and round(Value, 1) ~= 25 and round(Value, 1) ~= 100  then
   core.host:execute("drawLabel1", id, -64 + 20, core.CR_RIGHT, -50 - Value /Index , core.CR_BOTTOM, core.H_Right, core.V_Bottom, font1, LABEL,   string.format("%." .. 2 .. "f", (Value)));
				id = id +1;	  				
    end		      
	     

		for i =  1, Height , 10 do
		      Color= NE; 
		      
		      if Index *i <=  Value then
		      Color = IN;		      
		      end		      
		   
	
	              for j  = 1, 25 , 5 do		               
			       
				core.host:execute("drawLabel1", id, -50 - j, core.CR_RIGHT, -50-i, core.CR_BOTTOM, core.H_Left, core.V_Bottom, font2, Color,  "\108");
				id = id +1;
		      end		
		end

end	

function ReleaseInstance()
  core.host:execute("deleteFont", font1); 
  core.host:execute("deleteFont", font2);    
end

function round(num, idp)
  if idp and idp>0 then
    local mult = 10^idp
    return math.floor(num * mult + 0.5) / mult
  end
  return math.floor(num + 0.5)
end

