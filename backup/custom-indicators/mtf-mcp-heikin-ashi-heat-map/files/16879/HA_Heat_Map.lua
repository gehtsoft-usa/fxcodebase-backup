
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=7610


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

 function Add(id, TF,Flag )
   
    indicator.parameters:addGroup(id..". Slot" );
	indicator.parameters:addBoolean("On".. id , "Show This Slot", "",Flag);	    
    indicator.parameters:addString("TF" .. id, "Time Frame ", "", TF);
    indicator.parameters:setFlag("TF" .. id, core.FLAG_PERIODS);
	
	indicator.parameters:addString("Instrument" .. id, "Instrument", "", "EUR/USD");
    indicator.parameters:setFlag("Instrument" .. id, core.FLAG_INSTRUMENTS);
	
  
end

 
 
function Init()
    indicator:name("MTF MCP HA Heat Map");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	
	indicator.parameters:addGroup("Override" );
	
	indicator.parameters:addString("Method", "Override Method", "Method" , "Independent");
    indicator.parameters:addStringAlternative("Method", "Independent", "Independent" , "Independent");
    indicator.parameters:addStringAlternative("Method", "Chart Time Frame", "Chart Time Frame" , "Chart Time Frame");
	indicator.parameters:addStringAlternative("Method", "Chart Instrument", "Chart Instrument" , "Chart Instrument"); 

    indicator.parameters:addString("Type", "Source Type", "Type" , "HA");
    indicator.parameters:addStringAlternative("Type", "HA", "HA" , "HA");
    indicator.parameters:addStringAlternative("Type", "Regular Candles", "Regular Candles" , "Regular");	
 
    Add(1, "m1", true); 
    Add(2, "m5", true); 
    Add(3, "m15", true); 
    Add(4, "m30", true); 
    Add(5, "H1", true); 
    Add(6, "H2", true); 
    Add(7, "H3", true); 
    Add(8, "H4", true); 
    Add(9, "H6", true); 
    Add(10, "H8", true); 
    Add(11, "D1", true); 
    Add(12, "W1", true); 
    Add(13, "M1", true);

    indicator.parameters:addGroup("Calculation");
     indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Color", "Label Color","", core.rgb(0, 0, 0));
	indicator.parameters:addColor("Up", "Up Color","", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Color","", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutal Color","", core.rgb(128, 128, 128));
	 indicator.parameters:addDouble("Size", "Font Size (%)","",90, 50, 200);
   indicator.parameters:addDouble("VSpace", "Vertical Spacing (%)","",5, 0, 100);
   indicator.parameters:addDouble("HSpace", "Horizontal Spacing (%)","",5, 0, 30);
end
local On={};
local Method;
local source;
local day_offset, week_offset;
local Label = {"First", "Second", "Third", "Fourth"};
local first;
local VSpace,HSpace;
local Color;
--local size;
local SourceData={};
local TF={};
local loading={};
local Number=5;
local host;
local HA={}; 
local Up, Down, Neutral;
local Instrument={};
local Size;
local Type;
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	
    source = instance.source;	
	VSpace=(instance.parameters.VSpace/100);
	HSpace=(instance.parameters.HSpace/100);
	Size=instance.parameters.Size;
	Method=instance.parameters.Method;
	Up=instance.parameters.Up;
	Down=instance.parameters.Down;
	Neutral=instance.parameters.Neutral;
	
	Type=instance.parameters.Type;
	
	oPair=instance.parameters.oPair;
	oTime=instance.parameters.oTime;
	
	
	 host = core.host;
	--size=instance.parameters.size;
    Color=instance.parameters.Color;
    first=source:first();
	
   instance:setLabelColor(Color);
   instance:ownerDrawn(true);
    
     day_offset = host:execute("getTradingDayOffset");
    week_offset = host:execute("getTradingWeekOffset");
    local Id=0;
    Number=0;
   
	
	 local s1, e1, s2, e2;
	  s1, e1 = core.getcandle(source:barSize(), 0, 0, 0);
	 
	 local iTF={};
	 for i = 1, 13, 1 do
		       if   Method== "Chart Time Frame" then
	            iTF[i]=source:barSize();
				else
				iTF[i]=  instance.parameters:getString("TF" .. i);	
                		
				end
		 		
	end
	
	
	  for i = 1, 13, 1 do
	s2, e2 = core.getcandle(iTF[i], 0, 0, 0);
	
	 if  instance.parameters:getBoolean("On" .. i) and (e1 - s1) <= (e2 - s2)  then
	  
	 
	 Number=Number+1;
	 Label[Number]="";
	            On[Number]=instance.parameters:getBoolean("On" .. i);
				 
				if  Method== "Chart Instrument" then
	            Instrument[Number]=source:instrument();
				Label[Number]="";
	            else			
				Instrument[Number]=  instance.parameters:getString("Instrument" .. i);	 
				Label[Number]=Instrument[Number];
				end
				
				 
				 
				if   Method== "Chart Time Frame" then 
				TF[Number]=iTF[i];
				else
				TF[Number]=iTF[i];
                Label[Number]=Label[Number] .. "  -  " ..  TF[Number];				
				end
				
				
				
			  	Temp1= core.indicators:create("HA",source );  				
				first= Temp1.DATA:first();
			
				
				   Id=Id+1;
				 SourceData[Number]  = core.host:execute("getSyncHistory",  Instrument[Number],  TF[Number], source:isBid(),first, 2000 + Id , 1000 +Id);	 	 
				 loading[Number]  = true;  	 
				 if Type == "HA" then
				 HA[Number] = core.indicators:create("HA", SourceData[Number]);
 				 else
				 HA[Number] =SourceData[Number];
				 end
				   
       end
    end
  
	
	  
 
        core.host:execute ("setTimer", 1, 1);
end




function   Initialization(period,id)

    local Candle;
    Candle = core.getcandle(source:barSize(), source:date(period), day_offset, week_offset);
  
    if loading[id] or SourceData[id]:size() == 0  then
        return false;
    end

    
    if period < source:first() then
        return false;
    end

    local P = core.findDate(SourceData[id], Candle, false);
	 

    -- candle is not found
    if P < 0    then
        return false;
	else return P;	
    end
			
end	


-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)

local j;
local FLAG=false; 
local Num=0;
local Id=0;
    for j = 1, Number, 1 do
		      Id=Id+1;
			  if cookie == (1000 + Id) then
			  loading[j]  = true;
		      elseif  cookie == (2000 + Id ) then
			  loading[j]  = false;   
			  end
		 
		       
                 if loading[j] then
				 FLAG= true;
				 Num=Num+1;
				 end
	end    
   
     
    if not FLAG and cookie== 1 and Type == "HA" then
		for i= 1, Number , 1 do
			  HA[i]:update(core.UpdateLast );
		end
		
	end	 
	
	if FLAG then
	 core.host:execute ("setStatus", "  Loading "..((Number) - Num) .. " / " .. (Number) );	 
	else
	core.host:execute ("setStatus", "Loaded")
	instance:updateFrom(0);
	end
   
        
    return core.ASYNC_REDRAW ;
	
	
end





function Update(period, mode)
 
 
 
end

local init = false;

function Draw (stage, context)

    if stage  ~= 0 then
	return;
	end
	
	
	local FLAG=false; 

    for j = 1, Number, 1 do 
		       
                 if loading[j] then
				 FLAG= true; 
				 end
	end    
	 
	 if  FLAG then
	 return;
	 end
	 
	
	  
	local CellSize = math.floor(Size * 0.9);
   context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());
   
        if not init then
		    context:createPen (1, context.SOLID, 1, Color)       
			context:createSolidBrush(2, Color);
			
			context:createPen (11, context.SOLID, 1, Up)       
			context:createSolidBrush(12, Up);
			
			context:createPen (21, context.SOLID, 1, Down)       
			context:createSolidBrush(22, Down);
			
			
			context:createPen (31, context.SOLID, 1, Neutral)       
			context:createSolidBrush(32, Neutral);
			
			
            init = true;
        end
		
		
	
 
 
    
        local first = math.max(first, context:firstBar ());
        local last = math.min (context:lastBar (), source:size()-1);
        local p;
      
       local i,j;
	   local x0, x1, x2;
	   local style = context.SINGLELINE + context.CENTER + context.VCENTER;
	   
	   
	     X0, X1, X2 = context:positionOfBar (source:size()-1); 
		 HCellSize =((X2-X1))*HSpace;
		 VCellSize =((context:bottom() -context:top())/ (Number+1)); 
		 
		context:createFont(3, "Arial", ((X2-X1)/100)*Size, (VCellSize/100)*Size, context.NORMAL);
		
	 local VSize =((context:bottom() -context:top())/ (Number+1)); 
      
		 
		 
       for i= first, last, 1 do	   
	   
	   
	  
	   
	   x0, x1, x2 = context:positionOfBar (i);
	        
			 local HS= HSpace;
			 if x2-x1 <= VSize then
			 HS=0;
			 end
			 for j= 1, Number , 1 do
			 
			 				
				
				  p=Initialization(i,j);
				  if p~= false and HA[j].close:hasData(p) then
					  if HA[j].close[p]>HA[j].open[p] then
					  context:drawRectangle (11, 12, x1+HCellSize, context:top()+VCellSize * (j) +VCellSize* VSpace, x2-HCellSize,context:top() + VCellSize * (j+1)-VCellSize* VSpace);
					  elseif HA[j].close[p]<HA[j].open[p] then
					  context:drawRectangle (21, 22, x1+HCellSize,context:top()+VCellSize * (j) +VCellSize* VSpace,  x2-HCellSize, context:top() + VCellSize * (j+1)-VCellSize* VSpace);
					  else
					  context:drawRectangle (31, 32, x1+HCellSize, context:top()+VCellSize * (j) +VCellSize* VSpace,  x2-HCellSize, context:top() + VCellSize * (j+1)-VCellSize* VSpace);
					  end
				  else
				  context:drawRectangle (1, 2,x1+HCellSize, context:top()+VCellSize * (j) +VCellSize* VSpace,  x2-HCellSize, context:top() + VCellSize * (j+1)-VCellSize* VSpace);
				  end
			 end
	   end
     
      x0, x1, x2 = context:positionOfBar (source:size()-1);
	 
	 local width, height;
     for j= 1, Number , 1 do 
     width, height = context:measureText (3, Label[j], style)	 
	 context:drawText(3, Label[j], Color, -1, x2, context:top()+VCellSize * (j) +VCellSize* VSpace ,x2+width,context:top()+VCellSize * (j+1) -VCellSize* VSpace , style);
	 end
 
 
end


