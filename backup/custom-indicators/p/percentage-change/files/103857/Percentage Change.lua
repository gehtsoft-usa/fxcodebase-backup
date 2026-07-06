-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Percentage Change");
    indicator:description("Percentage Change");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation"); 
	indicator.parameters:addString("TF", "Time Frame", "", "D1");
    indicator.parameters:setFlag("TF", core.FLAG_PERIODS);
	 indicator.parameters:addBoolean("Historical", "Show Historical", "Show Historical", true);
	 
	 indicator.parameters:addString("Type", "Price Source", "", "Last");
    indicator.parameters:addStringAlternative("Type", "Last", "", "Last");
    indicator.parameters:addStringAlternative("Type", "Previous", "", "Previous");
   
	
	indicator.parameters:addGroup("Levels"); 
	indicator.parameters:addDouble("R4", "4. Resistance (%)", "4. Resistance", 1, 0, 100);
    indicator.parameters:addDouble("R3", "3. Resistance (%)", "3. Resistance", 0.50, 0, 100);
	indicator.parameters:addDouble("R2", "2. Resistance (%)", "2. Resistance", 0.25, 0, 100);
	indicator.parameters:addDouble("R1", "1. Resistance (%)", "1. Resistance", 0.1, 0, 100);
	
	indicator.parameters:addDouble("S1", "1. Support (%)", "1. Support", 0.1, 0, 100);
	indicator.parameters:addDouble("S2", "2. Support (%)", "2. Support", 0.25, 0, 100);
	indicator.parameters:addDouble("S3", "3. Support (%)", "3. Support", 0.5, 0, 100);
   indicator.parameters:addDouble("S4", "4. Support (%)", "4. Support", 1, 0, 100);  



	indicator.parameters:addGroup("Resistance Line"); 

	indicator.parameters:addColor("color2", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addGroup("Day Open Line"); 
	indicator.parameters:addColor("color1", "Line Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_DASH);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addGroup("Support Line"); 

	indicator.parameters:addColor("color3", "Line Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("width3", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style3", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style3", core.FLAG_LINE_STYLE);

	
   
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Historical;
local TF;
local Show;
local first;
local source = nil;
local Source;
-- Streams block
local S1, S2, S3, S4, R1, R2, R3, R4;
local dayoffset,weekoffset; 
local loading;
local o, r1, r2, r3, r4, s1, s2, s3, s4;
local level={};
local label={ "o", "r1", "r2", "r3", "r4", "s1", "s2", "s3", "s4"};
local label2={ "O", "R1", "R2", "R3", "R4", "S1", "S2", "S3", "S4"};
local Percentages;
local Color={};
local Style={};
local Width={};
local Type;
-- Routine
function Prepare(nameOnly)
    Percentages = instance.parameters.Percentages;
	Type = instance.parameters.Type;
    TF = instance.parameters.TF;
	S1 = instance.parameters.S1;
	S2 = instance.parameters.S2;
	S3 = instance.parameters.S3;
	S4 = instance.parameters.S4;
	R1 = instance.parameters.R1;
	R2 = instance.parameters.R2;
	R3 = instance.parameters.R3;
	R4 = instance.parameters.R4;
	Show = instance.parameters.Show;
	Historical = instance.parameters.Historical;
	
	
	local i;
	
	for i = 1, 9 , 1 do
		if i== 1 then
		 Color[i]=  instance.parameters:getInteger("color" .. 1);	
		Style[i]=  instance.parameters:getInteger("style" .. 1);	
		Width[i]=  instance.parameters:getInteger("width" .. 1);
		elseif  i>1 and i < 5 then
		 Color[i]=  instance.parameters:getInteger("color" .. 2);	
		Style[i]=  instance.parameters:getInteger("style" .. 2);	
		Width[i]=  instance.parameters:getInteger("width" .. 2);
		else
		 Color[i]=  instance.parameters:getInteger("color" .. 3);	
		Style[i]=  instance.parameters:getInteger("style" .. 3);	
		Width[i]=  instance.parameters:getInteger("width" .. 3);
		end
	end
	
	
	dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");
	
    source = instance.source;
    first = source:first();
	
	
	local s, e, S, E;
    s, e = core.getcandle(source:barSize(), core.now(), 0, 0);
    S, E = core.getcandle(TF, core.now(), 0, 0);
    assert ((e - s) <= (E - S), "The chosen time frame must be equal to or bigger than the chart time frame!");

    local name = profile:id() .. "(" .. source:name() .. ", " ..TF  .. ")";
    instance:name(name);

   Source = core.host:execute("getSyncHistory", source:instrument(), TF, source:isBid(), 0, 100, 101);
   loading= true;
  
   if Historical then
   
   
   o = instance:addStream("O", core.Line, name, "O", Color[1], first);
   o:setWidth(Width[1]);
   o:setStyle(Style[1]);
     


 
   r1 = instance:addStream("R1", core.Line, name, "R1", Color[2], first);
   r1:setWidth(Width[2]);
   r1:setStyle(Style[2]);
  
   
 
   r2 = instance:addStream("R2", core.Line, name, "R2", Color[3], first);
   r2:setWidth(Width[3]);
   r2:setStyle(Style[3]);
  
   
 
   r3 = instance:addStream("R3", core.Line, name, "R3", Color[4], first);
   r3:setWidth(Width[4]);
   r3:setStyle(Style[4]);
    
   
 
   r4 = instance:addStream("R4", core.Line, name, "R4", Color[5], first);
   r4:setWidth(Width[5]);
   r4:setStyle(Style[5]);
    
 
   s1 = instance:addStream("S1", core.Line, name, "S1", Color[6], first);
   s1:setWidth(Width[6]);
   s1:setStyle(Style[6]);
 
   
 
   s2 = instance:addStream("S2", core.Line, name, "S2", Color[7], first);
   s2:setWidth(Width[7]);
   s2:setStyle(Style[7]);
  
   
   
   s3 = instance:addStream("S3", core.Line, name, "S3", Color[8], first);
   s3:setWidth(Width[8]);
   s3:setStyle(Style[8]);
 
   
  
   s4 = instance:addStream("S4", core.Line, name, "S4", Color[9], first);
   s4:setWidth(Width[9]);
   s4:setStyle(Style[9]);
 
  
   
   end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)

    if period < first  then
	return;
	end
	
	
	
	  local p =  Initialization(period) 
     
	    if not p then
		return;
		end
		
		if Type ~= "Last" then
	    p=p-1;
 		end
		
		
	if Historical then
	
		   if o[period-1]~=  Source.open[p] then	
		   o[period]= Source.open[p];
		   o:setBreak(period, true);   
		   level[1]= Source.open[p];
		   
		   level[2]= o[period]* (1 + (R1 /100));
		   r1[period]= level[2];
		   r1:setBreak(period, true);
		   
		   level[3]=o[period]* (1 + (R2 /100))
		   r2[period]= level[3];
		   r2:setBreak(period, true);
		   
		   level[4]= o[period]* (1 + (R3 /100))
		   r3[period]=level[4];
		   r3:setBreak(period, true);
		   
		   level[5]= o[period]* (1 + (R4 /100))
		   r4[period]= level[5];
		   r4:setBreak(period, true);
		   
		   level[6]= o[period]* (1 - (S1 /100))
		   s1[period]= level[6];
		   s1:setBreak(period, true);
		   
		   level[7]= o[period]* (1 - (S2 /100))
		   s2[period]=level[7];
		   s2:setBreak(period, true);
		   
		   level[8]= o[period]* (1 - (S3 /100))
		   s3[period]= level[8];
		   s3:setBreak(period, true);
		   
		   level[9]= o[period]* (1 - (S4 /100))
		   s4[period]= level[9];
		   s4:setBreak(period, true);
		   
		   else   
		   o[period]= o [period-1];
		   r1[period]= r1 [period-1];
		   r2[period]= r2 [period-1];
		   r3[period]= r3 [period-1];
		   r4[period]= r4 [period-1];
		   s1[period]= s1 [period-1];
		   s2[period]= s2 [period-1];
		   s3[period]= s3 [period-1];
		   s4[period]= s4 [period-1];	

		   
		   end
		   
		   
		 if Show    then
      
		  local i;  
			   if period == source:size()-1 then
				   for i = 1, 9, 1 do 
							
							core.host:execute ("drawLabel", i, source:date(period), level[i], label [i] )
				   end
			   end   
          end
	else
	   
            if level[1]~=  Source.open[p] then	
		    
		   level[1]= Source.open[p];		   
		   level[2]= level[1]* (1 + (R1 /100));		   
		   level[3]=level[1]* (1 + (R2 /100));		   
		   level[4]= level[1]* (1 + (R3 /100));		   
		   level[5]=level[1]* (1 + (R4 /100)); 
		   level[6]= level[1]* (1 - (S1 /100));
		   level[7]= level[1]* (1 - (S2 /100));
		   level[8]= level[1]* (1 - (S3 /100));
		   level[9]= level[1]* (1 - (S4 /100));		   
		    end
	    
	
	
	 if period == source:size()-1  then
	  core.host:execute("setStatus", " " .. label2[1].."  "..level[1]
	  .. ", " .. label2[2].."  "..level[2]
      .. ", " .. label2[3].."  "..level[3]
      .. ", " .. label2[4].."  "..level[4]	 
      .. ", " .. label2[5].."  "..level[5]
      .. ", " .. label2[6].."  "..level[6]
      .. ", " .. label2[7].."  "..level[7]
      .. ", " .. label2[8].."  "..level[8]
      .. ", " .. label2[9].."  "..level[9]  
	  ); 

	   local S,E;
		  S, E = core.getcandle(TF, core.now(), 0, 0);
		  
		  
	     for i = 1, 9, 1 do
		  core.host:execute("drawLine", i+10, S, level[i], E, level[i], Color[i] ,  Style[i], Width[i] );
 
		 
		
					core.host:execute ("drawLabel", i, E, level[i], label [i] )
					
		 end
    end
   
  
  end
	
end


-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    if cookie == 100 then
        loading = false;
        instance:updateFrom(0);
    elseif cookie == 101 then
        loading = true;
    end
end


function   Initialization(period)

    local Candle;
    Candle = core.getcandle(TF, source:date(period), dayoffset, weekoffset);

  
    if loading or Source:size() == 0 then
        return false ;
    end

    
    if period < source:first() then
        return false;
    end

    local p = core.findDate(Source, Candle, false);

    -- candle is not found
    if p < 0 then
        return false;
	else return p;	
    end
	
end	