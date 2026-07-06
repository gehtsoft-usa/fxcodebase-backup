-- Id: 19786
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=608

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Historical MurreyLines");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

  
    indicator.parameters:addGroup("Calculation"); 
 
   indicator.parameters:addBoolean("Historical", "Show Historical", "", false);

    indicator.parameters:addString("TF", "Bar Size to display High/Low", "", "D1");
	indicator.parameters:setFlag("TF", core.FLAG_PERIODS);
 
    
	indicator.parameters:addInteger("P", "Number of periods", "", 64, 2, 10000);
    indicator.parameters:addInteger("N", "Size of the period in minutes", "", 60, 2, 10000);
   
    indicator.parameters:addBoolean("EL", "Exended labels", "", false);
	indicator.parameters:addBoolean("ON", "Show Price Levels", "", false);
	
	indicator.parameters:addGroup("Line Selector");
	indicator.parameters:addBoolean("Show" .. 1, "Show [-2/8] Line ", "", true);
	indicator.parameters:addBoolean("Show" .. 2, "Show [-1/8] Line ", "", true);
	indicator.parameters:addBoolean("Show" .. 3, "Show [0/8] Line ", "", true);
	indicator.parameters:addBoolean("Show" .. 4, "Show [1/8] Line ", "", true);
	indicator.parameters:addBoolean("Show" .. 5, "Show [2/8] Line ", "", true);
	indicator.parameters:addBoolean("Show" .. 6, "Show [3/8] Line ", "", true);
	indicator.parameters:addBoolean("Show" .. 7, "Show [4/8] Line ", "", true);
	indicator.parameters:addBoolean("Show" .. 8, "Show [5/8] Line ", "", true);
	indicator.parameters:addBoolean("Show" .. 9, "Show [6/8] Line ", "", true);
	indicator.parameters:addBoolean("Show" .. 10, "Show [7/8] Line ", "", true);
	indicator.parameters:addBoolean("Show" .. 11, "Show [8/8] Line ", "", true);
	indicator.parameters:addBoolean("Show" .. 12, "Show [+1/8] Line ", "", true);
	indicator.parameters:addBoolean("Show" .. 13, "Show [+2/8] Line ", "", true);

	local Label={"[-2/8]","[-1/8]", "[0/8]", "[1/8]", "[2/8]", "[3/8]", "[4/8]", "[5/8]", "[6/8]", "[7/8]", "[8/8]", "[+1/8]", "[+2/8]"};
	
	
	
 local Color={core.rgb(128, 128, 128), core.rgb(255, 0, 255),core.rgb(0, 128, 192)  , core.rgb(255, 255, 0), core.rgb(255, 128, 0), core.rgb(0, 255, 0), core.rgb(0, 255, 255), core.rgb(0, 255, 0), core.rgb(255, 128, 0), core.rgb(255, 255, 0), core.rgb(0, 128, 192), core.rgb(255, 0, 255), core.rgb(128, 128, 128)};
	
	for i=1, 13, 1 do	
	
	 indicator.parameters:addGroup((Label[i].." Line Style")); 
	
	indicator.parameters:addColor("Color"..i, "Line Color", "", Color[i]);  
    indicator.parameters:addInteger("Width"..i, "Line width", "Line width", 1, 1, 5);
    indicator.parameters:addInteger("Style"..i, "Line style", "Line style", core.LINE_SOLID);
    indicator.parameters:setFlag("Style"..i, core.FLAG_LINE_STYLE);
	end
 
	indicator.parameters:addColor("LabelColor", "Label Color", "Label", core.COLOR_LABEL );
	indicator.parameters:addInteger("Size", "Font Size", "", 20);		

	


	
end 

function ReleaseInstance()
       core.host:execute("deleteFont", font);      
 end

	local Historical;
	local source;    
	 
     local Color={};
     local Style={};
     local Width={};	
     local Histogram={};	 
      local TF;
	  local Source;
	  local loading = false;
 
	  local LabelColor;
	  local Label;
	  local Size;
	  local day_offset, week_offset;
	  local labels = {};  -- line labels
	  local Show={};
	 local P,N,EL,ON;
	 local depth;
	 local barsize;      -- the size of the bar in minutes 
	 
	    local LabelText={"-2", "-1", "0", "1", "2",  "3", "4", "5", "6", "7", "8", "1",  "2"  } ;
	 local font;	
function Prepare(nameOnly)
    source = instance.source;
	first=source:first();  
    local name = profile:id() ;
    instance:name(name); 
    if nameOnly then
        return;
    end
	
	P=instance.parameters.P;
	N=instance.parameters.N;
	EL=instance.parameters.EL;
	ON=instance.parameters.ON;
	
	 if EL then
        labels[1]  = "[-2/8] (Extreme Overshoot)";
        labels[2]  = "[-1/8] (Overshoot)";
        labels[3]  = "[0/8] (Ultimate Support - Extremely Oversold)";
        labels[4]  = "[1/8] (Weak, Place to Stop and Reverse)";
        labels[5]  = "[2/8] (Strong, Pivot, Reverse)";
        labels[6]  = "[3/8] (Bottom of Trading Range)";
        labels[7]  = "[4/8] (Major Support/Resistance Pivotal Point)";
        labels[8]  = "[5/8] (Top of Trading Range)";
        labels[9]  = "[6/8] (Strong, Pivot, Reverse)";
        labels[10]  = "[7/8] (Weak, Place to Stop and Reverse)";
        labels[11]  = "[8/8] (Ultimate Resistance - Extremely Overbought)";
        labels[12]  = "[+1/8] (Overshoot)";
        labels[13]  = "[+2/8] (Extreme Overshoot)";
    else
        labels[1]  = "[-2/8]";
        labels[2]  = "[-1/8]";
        labels[3]  = "[0/8]";
        labels[4]  = "[1/8]";
        labels[5]  = "[2/8]";
        labels[6]  = "[3/8]";
        labels[7]  = "[4/8]";
        labels[8]  = "[5/8]";
        labels[9]  = "[6/8]";
        labels[10]  = "[7/8]";
        labels[11]  = "[8/8]";
        labels[12]  = "[+1/8]";
        labels[13]  = "[+2/8]";
    end
	
	
	Show[1] = instance.parameters.Show1;
	Show[2] = instance.parameters.Show2;
	Show[3] = instance.parameters.Show3;
	Show[4] = instance.parameters.Show4;
	Show[5] = instance.parameters.Show5;
	Show[6] = instance.parameters.Show6;
	Show[7] = instance.parameters.Show7;
	Show[8] = instance.parameters.Show8;
	Show[9] = instance.parameters.Show9;
	Show[10] = instance.parameters.Show10;
	Show[11] = instance.parameters.Show11;
	Show[12] = instance.parameters.Show12;
	Show[13] = instance.parameters.Show13;

	s, e = core.getcandle(source:barSize(), core.now(), 0);
    barsize = math.floor(((e - s) * 1440) + 0.5);

    depth = P * math.ceil(N / barsize);
    if (depth == 0) then
        depth = P;
    end
	
	day_offset = core.host:execute("getTradingDayOffset");
    week_offset = core.host:execute("getTradingWeekOffset");
	 
	Size=instance.parameters.Size;
	Historical=instance.parameters.Historical;
	
	font = core.host:execute("createFont", "Ariel", Size, false, false);
	 
 
    TF = instance.parameters.TF; 
	LabelColor = instance.parameters.LabelColor;
	Size = instance.parameters.Size;
	
	 local s1, e1, s2, e2;
    s1, e1 = core.getcandle(source:barSize(),0, 0, 0);
    s2, e2 = core.getcandle(TF, 0, 0, 0);
    assert ((e1 - s1) <= (e2 - s2), "The chosen time frame must be equal to or bigger than the chart time frame!");
	
	--Source = core.host:execute("getSyncHistory", source:instrument(), TF, source:isBid(), 0, 100, 101);
--	loading=true;
	

	 
	 for i=1, 13 , 1 do
		  
		 
		 Color[i]=instance.parameters:getColor("Color" ..i)
         Style[i]=instance.parameters:getInteger("Style" ..i)
         Width[i]=instance.parameters:getInteger("Width" ..i)
 
	 end
 
  
  
    if Historical then
	   for i=1, 13 , 1 do
	   
	       if Show[i]then
	       Histogram[i]= instance:addStream(LabelText[i], core.Line, name .. LabelText[i], LabelText[i], Color[i], source:first()); 
	       Histogram[i]:setWidth(Width[i]);
           Histogram[i]:setStyle(Style[i]);  
	       else
		   Histogram[i]=instance:addInternalStream(source:first(), 0);
		   end
		   
		   
	 
	   end
	   
	   
	
	end
	
end

function Calculate(period)
    if period  <source:first()+ depth then
	return nil;
	end
	
	local Levels={};
        local min, max, minp, maxp, fractal, range, octave, sum, mn, mx;
        min, max, minp, maxp = core.minmax(source, core.rangeTo(period, depth));
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

        local dmml, i, d1, d2 , pricel;
        dmml = (finalH - finalL) / 8;

        price = finalL - dmml * 2;
       
      
       
        if not Historical then
		
	       d1 = source:date(source:first());
         d2 = source:date( source:size()-1);
				
				for i = 1, 13, 1 do
				
				
						 if Show[i] then
						 
						 
							core.host:execute("drawLine", i, d1, price, d2, price, Color[i], Style[i], Width[i]); 
							
							if not ON then
							core.host:execute("drawLabel1", i, d2+((barsize*2)/1440), core.CR_CHART, price, core.CR_CHART, core.H_Right, core.V_Bottom, font, LabelColor, labels[i]	);	
							else
							core.host:execute("drawLabel1", i, d2+((barsize*2)/1440), core.CR_CHART, price, core.CR_CHART, core.H_Right, core.V_Bottom, font, LabelColor, labels[i] .. " (" .. string.format("%." .. source:getPrecision() .. "f", price ) ..")"	);	
							end
						 end    
						 price = price + dmml; 
						end
						
       else 
	   
	   for i = 1, 13, 1 do
	   
			   if i== 1 then
			   Levels[i]=finalL - dmml * 2;
			   else
			   Levels[i]=Levels[i-1]+dmml;
			   end
	   
	   end
	   
	  return Levels;
	  end
	 
end		

--[[
-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    if cookie == 100 then
        loading = false;
        instance:updateFrom(0);
    elseif cookie == 101 then
        loading = true;
    end
end
]]


-- the function which is called to calculate the period
function Update(period  ) 	 

	--if loading then
	--return;
	--end

  -- local Last;
   --local p;
 
      if not Historical then
	     if period < source:size()-1  then
		 return;
		 end
	  
        -- Last= Source:size()-1;
	  --else	  
         --  p= core.findDate (Source, source:date(period), false);
		  --if p==-1 then
		--  return;
		 -- end 
	      --Last= p;
	  end
	  
	  local Levels= Calculate(period);
	  
	  
	  if Levels== nil then
	  return;
	  end
	  

	  
	 if Historical then 
		 for i= 1, 13, 1 do
		    
		                if  Levels[i]~= nil then
			               
						 S1,S2 = core.getcandle(TF, source:date(period), day_offset, week_offset);
						 prev= core.findDate (source, S1, false); 
						 current= core.findDate (source, S2, false); 
						 if prev~= -1 
						 and current~=-1
						 and period<=current
						 then
							 core.drawLine(Histogram[i], core.range(prev, period), Levels[i], prev, Levels[i], period, Color[i]);	 
							 	
						 end
						 end
			 if period == source:size()-1 then	
			                 d2 = source:date( source:size()-1);
			    	        if not ON then
							core.host:execute("drawLabel1", i, d2+((barsize*2)/1440), core.CR_CHART,  Levels[i], core.CR_CHART, core.H_Right, core.V_Bottom, font, LabelColor, labels[i]	);	
							else
							core.host:execute("drawLabel1", i, d2+((barsize*2)/1440), core.CR_CHART,  Levels[i], core.CR_CHART, core.H_Right, core.V_Bottom, font, LabelColor, labels[i] .. " (" .. string.format("%." .. source:getPrecision() .. "f",  Levels[i] ) ..")"	);	
							end
							
			 end
			 
		 end
	 
	 end
end
