function Init()
    indicator:name("Adv_Fractal_support_ resistance");
    indicator:description("Predicts a reversal in the current trend.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
  
  
    	indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("Fractals", "Number of fractals", "", 3, 5,99);
	 indicator.parameters:addInteger("Lenght", "Line Length", "", 50, 1, 1000);
	
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("R_color", "Up fractal color", "Up fractal color", core.rgb(0,255,0));
    indicator.parameters:addColor("S_color", "Down fractal color", "Down fractal color", core.rgb(255,0,0));
	indicator.parameters:addInteger("widthLinReg", "Line width", "Line width", 2, 1, 5);
	  indicator.parameters:addInteger("styleLinReg", "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("styleLinReg", core.FLAG_LINE_STYLE);
   
	

end
local LAST;
local source;
local buff;
local  flag={};
local frame=0;
local Rez=0;
local Size;
local id;
local  ID;
local NEW={};
local OLD={};
local LEVEL={};
local Lenght;
local FLAG={};
local FIRST={};
local COLOR={};
local COUNT={};
function Prepare(nameOnly)
    source = instance.source;
    Size = instance.parameters.Size;
	Lenght = instance.parameters.Lenght;
   
	Fractals=instance.parameters.Fractals
  	 
 
    first = source:first()+Fractals;
   
	local name = profile:id() .. " ( " .. Fractals .. " )";
	instance:name(name);
	if  (nameOnly) then 
	return;
	end
  
 
     buff = instance:addInternalStream(first, 0); 
 
	
    ID =0;
	id=0;
end

function Update(period, mode)

	if period <= first then
	ID =0;
	id=0;
	return;
	end
    
	

	test=true;
	 
	
	local x = period - Fractals;
	
 
	test=true;
	
		
         for i= 1, Fractals, 1 do
		
		     if  source.high[x]  < source.high[x+i]
			 or  source.high[x] < source.high[x-i]
			 then
			 test=false;
			 end
			
		 end	
		 
		 if test then		 
         buff[period - Fractals] =   source.high[period - Fractals]; 	
          id=id+1;
			 FIRST[id] = source:date(period - Fractals);
			 LEVEL[id]=source.high[period - Fractals];
             COLOR[id]= true;
             COUNT[id]= 2;		 
			 FLAG[id]= true; 
		 end

	test=true; 
       
	    
		
		  
          for i= 1, Fractals, 1 do
		
		  
		     if  source.low[x] > source.low[x+i]
			 or  source.low[x] > source.low[x-i]
			 then
			 test=false;
			 end
		 end
	   
	      if test then	      
			 buff[period - Fractals] =   -source.low[period - Fractals]; 	
			 id=id+1;
			 FIRST[id] = source:date(period - Fractals);
			 LEVEL[id]=source.low[period - Fractals];
			 COLOR[id]= false;
             COUNT[id]= 2;	
			 FLAG[id]= true;
		  end
        
    
	
 
	DRAW (period-1); 
end

function DRAW (period)
local i;
local j = period;
--local  i;
	for i=1, id, 1 do
	   
	        if  FLAG[i] ~= "STOP"  
			then
	   
		if NEW[i] == nil then
		NEW[i] =  FIRST[i];	
		end
			
				 if j > core.findDate (source, FIRST[i], false) then
				 
				  
				    if  j == core.findDate (source, FIRST[i], false)  +Lenght then
					 FLAG[i] = "STOP";
					 end
				  
				            
				  
							 if  FLAG[i] ~= "STOP"  and COUNT[i] >= 0 then
						  
									 if core.crossesOver( source.close, LEVEL[i] , j) then
									 OLD[i] = NEW[i];
									 NEW[i] = source:date(j);				 
									 
									  COLOR[i]= true;
                                    COUNT[i]= COUNT[i]-1;
									 if COUNT[i] >= 0 then
									 ID =ID+1;
									 core.host:execute("drawLine", ID, OLD[i], LEVEL[i], NEW[i], LEVEL[i], instance.parameters.R_color);
									 end
									 FLAG[i]= false; 
									 elseif core.crossesUnder( source.close, LEVEL[i] , j) then
									  OLD[i] = NEW[i]
									  NEW[i] = source:date(j);				 
									  
									  COLOR[i]= false;
                                     COUNT[i]= COUNT[i]-1;
									  if COUNT[i] >= 0 then
									 ID =ID+1;
									 core.host:execute("drawLine", ID, OLD[i], LEVEL[i], NEW[i], LEVEL[i], instance.parameters.S_color);
									 end
									 FLAG[i]= false; 					 
									 end
									 
									 
									 --*************
									  if FLAG[i]  and FLAG[i] ~= "STOP" and COUNT[i] >= 0  then  

										  if  COLOR[i] then 			 
											   ID =ID+1;
											 core.host:execute("drawLine", ID, FIRST[i], LEVEL[i], source:date( math.min(core.findDate (source, FIRST[i], false) +Lenght, period ) ), LEVEL[i], instance.parameters.R_color);
										 else
											   ID =ID+1;
											 core.host:execute("drawLine", ID, FIRST[i], LEVEL[i], source:date( math.min(core.findDate (source, FIRST[i], false) +Lenght, period ) ), LEVEL[i], instance.parameters.S_color);
											 end
										 end
									 --**************
							 end
				end
				  
				  
				
			end 
	 end
	 
	
end
