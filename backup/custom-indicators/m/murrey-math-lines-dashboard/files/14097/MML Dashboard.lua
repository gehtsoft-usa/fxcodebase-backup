-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=6030

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


function Init()
    indicator:name("MML Dashboard");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);	

       indicator.parameters:addBoolean("EL", "Exended labels", "", false);
	 
	 indicator.parameters:addGroup("Calculation");
    indicator.parameters:addInteger("P", "Number of periods", "", 64, 2, 1000);
    indicator.parameters:addInteger("N", "Size of the period in minutes", "", 60, 2, 1000); 

	
	
	
	 indicator.parameters:addBoolean("Lock", "Lock", "", false);
	 
	 indicator.parameters:addString("Type", "Lock Type", "", "Frame");
    indicator.parameters:addStringAlternative("Type", "Time Frame", "", "Frame");
    indicator.parameters:addStringAlternative("Type", "Instrument", "", "Instrument");
   
	
	Parameters (1 , "m1", false);
	Parameters (2 , "m5", false );
	Parameters (3 , "m15", false );
	Parameters (4 , "m30", false );
	Parameters (5 , "H1" , true );
	Parameters (6 , "H4", false);
	Parameters (7 , "H8", false );
	Parameters (8 , "D1", true );
	Parameters (9 , "W1", true );
	Parameters (10 , "M1", true  );
	
	
	  indicator.parameters:addGroup("Style");
	 indicator.parameters:addInteger("Position", "Vertical Position", "", 0, 0 , 500);
	  indicator.parameters:addInteger("Size", "Font Size", "", 10, 0 , 100);
	  
	
    indicator.parameters:addColor("clrM28", "Color of the [+2/8] line", "", core.rgb(0, 0, 0));
    indicator.parameters:addColor("clrM18", "Color of the [+1/8] line", "", core.rgb(255, 0, 255));
    indicator.parameters:addColor("clr08",  "Color of the [8/8] line", "", core.rgb(0, 128, 192));
    indicator.parameters:addColor("clr18",  "Color of the [7/8] line", "", core.rgb(255, 255, 0));
    indicator.parameters:addColor("clr28",  "Color of the [6/8] line", "", core.rgb(255, 128, 0));
    indicator.parameters:addColor("clr38",  "Color of the [5/8] line", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clr48",  "Color of the [4/8] line", "", core.rgb(0, 255, 255));
    indicator.parameters:addColor("clr58",  "Color of the [3/8] line", "", core.rgb(0, 255, 0));
    indicator.parameters:addColor("clr68",  "Color of the [2/8] line", "", core.rgb(255, 128, 0));
    indicator.parameters:addColor("clr78",  "Color of the [1/8] line", "", core.rgb(255, 255, 0));
    indicator.parameters:addColor("clr88",  "Color of the [0/8] line", "", core.rgb(0, 128, 192));
    indicator.parameters:addColor("clrP18", "Color of the [-1/8] line", "", core.rgb(255, 0, 255));
    indicator.parameters:addColor("clrP28", "Color of the [-2/8] line", "", core.rgb(0, 0, 0));
    indicator.parameters:addColor("clrT", "Color of the time line", "", core.rgb(127, 0, 0));
	indicator.parameters:addColor("clrLabel", "Color of label", "", core.rgb(0, 0, 0));
	 
	
end


function Parameters (id , FRAME , DEFAULT )
    indicator.parameters:addGroup(id ..". DMI Calculation");
	indicator.parameters:addBoolean("ON"..id, "Use This TimeFrame", "", DEFAULT);
    indicator.parameters:addInteger("N"..id, "Periods", "", 14);
	
	indicator.parameters:addString("INSTRUMENT"..id, "Instrumet", "", "");
    indicator.parameters:setFlag("INSTRUMENT"..id, core.FLAG_INSTRUMENTS );
   
    indicator.parameters:addString("B"..id, "Time frame", "", FRAME);
    indicator.parameters:setFlag("B"..id, core.FLAG_PERIODS);
end

local P, N;  -- indicator parameters
local  clrT, clrLabel;
local EL;

local labels = {};  -- line labels
local colors = {};  -- line colors

local barsize;      -- the size of the bar in minutes
local depth;        -- depth for finding the data

local Lock;
local Type;

local MAX;

local source; 
local day_offset, week_offset;
 
local stream={};
local loading={};
local host;
local first;

local INSTRUMENT={};
local Label={};
local FRAME={};
local  FrameLabel={};

local ON={};
local Position;
local font1;
local font3;

local COUNT=0;
local LABEL;
local Size;
local Style;

local PERIOD={};

function Prepare(nameOnly)  

     EL = instance.parameters.EL;
     clrT = instance.parameters.clrT;
     clrLabel= instance.parameters.clrLabel;
    P = instance.parameters.P;
    N = instance.parameters.N;
    Size=instance.parameters.Size;
    Style=instance.parameters.Style;
    LABEL=instance.parameters.LABEL;
    Position=instance.parameters.Position;  
    Lock=instance.parameters.Lock;
	Type=instance.parameters.Type;
    source = instance.source;
	first= source:first();
    host = core.host;	
	

	
		local s, e;
    s, e = core.getcandle(source:barSize(), core.now(), 0);
    barsize = math.floor(((e - s) * 1440) + 0.5);
	
		depth = P * math.ceil(N / barsize);
    if (depth == 0) then
        depth = P;
    end
   
     local name = profile:id() .. "(" .. source:name() .. ",[" .. P .. "," .. N .. ":=" .. depth .. " periods])";
	instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
    colors[0] = instance.parameters.clrM28;
    colors[1] = instance.parameters.clrM18;
    colors[2] = instance.parameters.clr08;
    colors[3] = instance.parameters.clr18;
    colors[4] = instance.parameters.clr28;
    colors[5] = instance.parameters.clr38;
    colors[6] = instance.parameters.clr48;
    colors[7] = instance.parameters.clr58;
    colors[8] = instance.parameters.clr68;
    colors[9] = instance.parameters.clr78;
    colors[10] = instance.parameters.clr88;
    colors[11] = instance.parameters.clrP18;
    colors[12] = instance.parameters.clrP28;
	
	 if EL then
        labels[2]  = "[-2/8] (Extreme Overshoot)";
        labels[3]  = "[-1/8] (Overshoot)";
        labels[4]  = "[0/8] (Ultimate Support - Extremely Oversold)";
        labels[5]  = "[1/8] (Weak, Place to Stop and Reverse)";
        labels[6]  = "[2/8] (Strong, Pivot, Reverse)";
        labels[7]  = "[3/8] (Bottom of Trading Range)";
        labels[8]  = "[4/8] (Major Support/Resistance Pivotal Point)";
        labels[9]  = "[5/8] (Top of Trading Range)";
        labels[10]  = "[6/8] (Strong, Pivot, Reverse)";
        labels[11]  = "[7/8] (Weak, Place to Stop and Reverse)";
        labels[12]  = "[8/8] (Ultimate Resistance - Extremely Overbought)";
        labels[13]  = "[+1/8] (Overshoot)";
        labels[14]  = "[+2/8] (Extreme Overshoot)";
		labels[0]  = "Instrument";
        labels[1]  = "Time Frame";
    else
        labels[2]  = "[-2/8]";
        labels[3]  = "[-1/8]";
        labels[4]  = "[0/8]";
        labels[5]  = "[1/8]";
        labels[6]  = "[2/8]";
        labels[7]  = "[3/8]";
        labels[8]  = "[4/8]";
        labels[9]  = "[5/8]";
        labels[10]  = "[6/8]";
        labels[11]  = "[7/8]";
        labels[12]  = "[8/8]";
        labels[13]  = "[+1/8]";
        labels[14]  = "[+2/8]";
		labels[0]  = "Instrument";
        labels[1]  = "Time Frame";
    end
	
	




	 
  
	
	local i;
   COUNT=0;
   
	
	for i = 1 , 10 , 1 do    
	
	
	    
	   
	   if instance.parameters:getBoolean ("ON"..i)  then
				   COUNT= COUNT+1;
				   
				   
				   PERIOD[COUNT]= instance.parameters:getInteger ("N"..i);
				   
					 if instance.parameters:getString ("INSTRUMENT"..i) == "" then
					  INSTRUMENT[COUNT]= source:instrument();
				  else
				  INSTRUMENT[COUNT] = instance.parameters:getString ("INSTRUMENT"..i);
				  end
				
				   if Lock and  Type=="Instrument" then
				   INSTRUMENT[COUNT] = INSTRUMENT[1];
				   else
				   INSTRUMENT[COUNT] = INSTRUMENT[COUNT];
				   end
				   
					if Lock and  Type=="Instrument" and i ~= 1 then
					INSTRUMENT[COUNT]="";		  
					else
					INSTRUMENT[COUNT]=INSTRUMENT[COUNT];
					end

						
				  
				   FRAME[COUNT]=  instance.parameters:getString ("B"..i);
				  
				  if Lock and  Type=="Frame" then
				  FRAME[COUNT]	= FRAME[1];		   
				  end
				  
				   if Lock and  Type=="Frame" and i ~= 1 then
					FrameLabel[COUNT]="";		  
					else
					 FrameLabel[COUNT]=FRAME[COUNT];
					end 	
				 
	   
	   
	   
	   end
	
	 
	  
    
	end	
	
	font1 = core.host:execute("createFont", "Ariel", Size, false, false);
	font3 = core.host:execute("createFont", "Ariel", Size, false, true);

	
    day_offset = host:execute("getTradingDayOffset");
    week_offset = host:execute("getTradingWeekOffset"); 
	
 
	   for i = 1, COUNT , 1 do 
			     stream[i] = core.host:execute("getSyncHistory",  INSTRUMENT[i],  FRAME[i], source:isBid(), 300, 2000 + i , 1000 +i);	 	 
				 loading[i]  = true;  	 
		end

end


function Calculation (Number)
 
local period = stream[Number]:size()-1;

   for i = 14, 0, -1 do


			core.host:execute("drawLabel1",   i, Size*5*(Number+1), core.CR_LEFT, Position+ Size+ Size*i, core.CR_TOP, core.H_Right, core.V_Bottom, font1, clrLabel, labels[14-i] );
   			

end			


 if period == stream[Number]:size() - 1 and stream[Number]:size() > depth + stream[Number]:first() then
        local min, max, minp, maxp, fractal, range, octave, sum, mn, mx;
        min, max, minp, maxp = core.minmax(stream[Number], core.rangeTo(period, depth));
        if max <= 250000 and max > 25000 then
            fractal = 100000;
        elseif  max <= 25000 and max > 2500 then
            fractal = 10000;
        elseif max <= 2500 and max > 250 then
            fractal = 1000;
        elseif max <= 250 and max > 25 then
            fractal = 100;
        elseif max <= 25 and max > 12.5 then
            fractal = 12.5;
        elseif max <= 12.5 and max > 6.25 then
            fractal = 12.5;
        elseif max <= 6.25 and max > 3.125 then
            fractal = 6.25;
        elseif max <= 3.125 and max > 1.5625 then
            fractal = 3.125;
        elseif max <= 1.5625 and max > 0.390625 then
            fractal = 1.5625;
        elseif max <= 0.390625 and max > 0 then
             fractal = 0.1953125;
        else
            assert(false, "The price is out of range");
        end
        range = max - min;
        sum = math.floor(math.log(fractal / range) / math.log(2));
        octave = fractal * (math.pow(0.5, sum));
        mn = math.floor(min / octave) * octave;
        if mn + octave > max then
            mx = mn + octave;
        else
            mx = mn + (2 * octave);
        end

        local x1, x2, x3, x4, x5, x6;
        local y1, y2, y3, y4, y5, y6;
        local finalH, finalL;

        if (min >= (3 * (mx - mn) / 16 + mn)) and (max <= (9 * (mx - mn) / 16 + mn)) then
            x2 = mn + (mx - mn) / 2;
        else
            x2 = 0;
        end

        if (min >= (mn - (mx - mn) / 8)) and (max <= (5 * (mx - mn) / 8 + mn)) and (x2 == 0) then
            x1 = mn + (mx - mn) / 2;
        else
            x1 = 0;
        end


        if (min >= (mn + 7 * (mx - mn) / 16)) and (max <= (13 * (mx - mn) / 16 + mn)) then
            x4 = mn + 3 * (mx - mn) / 4;
        else
            x4 = 0;
        end


        if (min >= (mn + 3 * (mx - mn) / 8)) and (max <= (9 * (mx - mn) / 8 + mn)) and (x4 == 0) then
            x5 = mx;
        else
            x5 = 0;
        end


        if (min >= (mn + (mx - mn) / 8)) and (max <= (7 * (mx - mn) / 8 + mn)) and (x1 == 0) and (x2 == 0) and (x4 == 0) and (x5 == 0) then
            x3 = mn + 3 * (mx - mn) / 4;
        else
            x3 = 0;
        end

        if (x1 + x2 + x3 + x4 + x5) == 0 then
            x6 = mx;
        else
            x6 = 0;
        end

        finalH = x1 + x2 + x3 + x4 + x5 + x6;

        if x1 > 0 then
            y1 = mn;
        else
            y1 = 0;
        end


        if x2 > 0 then
            y2 = mn + (mx - mn) / 4;
        else
            y2 = 0;
        end


        if x3 > 0 then
            y3 = mn + (mx - mn) / 4;
        else
            y3 = 0;
        end


        if x4 > 0 then
            y4 = mn + (mx - mn) / 2;
        else
            y4 = 0;
        end

        if x5 > 0 then
            y5 = mn + (mx - mn) / 2;
        else
            y5 = 0;
        end


        if (finalH > 0) and ((y1 + y2 + y3 + y4 + y5) == 0) then
            y6 = mn;
        else
            y6 = 0;
        end

        finalL = y1 + y2 + y3 + y4 + y5 + y6;

        local dmml, price, i, d1, d2, price0, pricel;
        dmml = (finalH - finalL) / 8;

        price = finalL - dmml * 2;

        d1 = stream[Number]:date(stream[Number]:first());
        d2 = stream[Number]:date(period);
        price0 = price;
		
		local Min,Max;

        for i = 14, 0, -1 do
		
		     if i == 0 then
			 Max= price;
             elseif i == 12 then
			  Min= price;
             end		

              			 
            
			--if Number == COUNT then		
			--core.host:execute("drawLabel1",   i, Size*5*(Number+1), core.CR_LEFT, Position+ Size+ Size*i, core.CR_TOP, core.H_Right, core.V_Bottom, font1, clrLabel, labels[i] );
            --end			
		 
		 
		       if i <13 then
		       core.host:execute("drawLabel1",  Number *20 + i,  Size*5*Number, core.CR_LEFT, Position +Size+ Size*i, core.CR_TOP, core.H_Right, core.V_Bottom, font1, colors[i], tostring(round(price, 4)));
		       price = price + dmml;
			   elseif i == 14 then
			    core.host:execute("drawLabel1",  Number *20 + i,  Size*5*Number, core.CR_LEFT, Position +Size+ Size*i, core.CR_TOP, core.H_Right, core.V_Bottom, font1, clrLabel, INSTRUMENT[Number]);
			   elseif i== 13 then
			    core.host:execute("drawLabel1",  Number *20 + i, Size*5*Number, core.CR_LEFT, Position +Size+ Size*i, core.CR_TOP, core.H_Right, core.V_Bottom, font1, clrLabel, FRAME[Number]);
			   end
			end
        
		
		local Shift;
		Shift = (Max -stream[Number].close[stream[Number]:size()-1 ]  )/  ( math.abs(Max-Min)/100);
		
		core.host:execute("drawLabel1",   10000+ Number,  Size*5*(Number), core.CR_LEFT, Position+ Size+  ((Size*12)/100 *Shift), core.CR_TOP, core.H_Right, core.V_Bottom, font3, clrLabel, tostring(round(stream[Number].close[stream[Number]:size()-1], 4)) );
		
        pricel = price - dmml;
		
	end	
end

function round(num, idp)
  if idp and idp>0 then
    local mult = 10^idp
    return math.floor(num * mult + 0.5) / mult
  end
  return math.floor(num + 0.5)
end

function Update(period )


 if  period < source:size()-1 then
 return;
 end
 
 local FLAG=false;
 
 
     for j = 1, COUNT, 1 do
		     
		 
		       
                 if loading[j] then
				 FLAG= true; 
				 end
	end    
 
		
 
	 
	
	if FLAG then
    return;
	end
	
	
 
 

			for i = 1, COUNT, 1  do

					
				  Calculation(i);
									
				
			end
	 
 

end
 
function round(num, idp)
  if idp and idp>0 then
    local mult = 10^idp
    return math.floor(num * mult + 0.5) / mult
  end
  return math.floor(num + 0.5)
end

function ReleaseInstance()

       core.host:execute("deleteFont", font1); 
      
  end
  
  
  
-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)

local j;
local FLAG=false; 
local Num=0;
 
    for j = 1, COUNT, 1 do
		     
			  if cookie == (1000 + j) then
			  loading[j]  = true;
		      elseif  cookie == (2000 + j ) then
			  loading[j]  = false;         
			  end
		 
		       
                 if loading[j] then
				 FLAG= true;
				 Num=Num+1;
				 end
	end    
 
		
 
	 
	
	if FLAG then
	 core.host:execute ("setStatus", "  Loading "..((COUNT) - Num) .. " / " .. (COUNT) );	 
	else
	core.host:execute ("setStatus", "Loaded");
	  instance:updateFrom(0);
	end
	
 
   
        
    return core.ASYNC_REDRAW ;
	
	
end

