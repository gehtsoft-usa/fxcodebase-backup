
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=60550

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



 
 function Add(id, TF )
   
	indicator.parameters:addBoolean("On".. id , "Show This TIme Frame", "", true);	    
    indicator.parameters:addString("TF" .. id, "Time Frame ", "", TF);
    indicator.parameters:setFlag("TF" .. id, core.FLAG_PERIODS);
	
	indicator.parameters:addString("Instrument" .. id, "Instrument", "", "EUR/USD");
    indicator.parameters:setFlag("Instrument" .. id, core.FLAG_INSTRUMENTS);
	
	
 
    indicator.parameters:addInteger("Period".. id, "Period", "Period", 10);
	indicator.parameters:addString("Type".. id ,"Triger", "", "Close");
    indicator.parameters:addStringAlternative("Type".. id, "Close", "", "Close");
    indicator.parameters:addStringAlternative("Type".. id, "High/Low", "", "High");
	 
end

 
 
function Init()
    indicator:name("MTF MCP Trend Stop Heat Map");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	
	indicator.parameters:addGroup("Override" );
	indicator.parameters:addBoolean("oPair"  , "Use Chart Currency pair", "", true );	
	indicator.parameters:addBoolean("oTime"  , "Use Chart Time Frame", "", false );	
	 	 
	 indicator.parameters:addGroup("1. Time Frame" );
    Add(1, "H1", 10, 20);
	indicator.parameters:addGroup("2. Time Frame" );
    Add(2, "H2", 10, 20);
	indicator.parameters:addGroup("3. Time Frame" );
    Add(3, "H4", 10, 20);
	indicator.parameters:addGroup("4. Time Frame" );
    Add(4, "H6",10, 20);
	indicator.parameters:addGroup("5. Time Frame" );
    Add(5, "H8", 10, 20);

    indicator.parameters:addGroup("Calculation");
     indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Color", "Label Color","", core.rgb(0, 0, 0));
	indicator.parameters:addColor("Up", "Up Color","", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Color","", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutal Color","", core.rgb(128, 128, 128));
	indicator.parameters:addDouble("size", "Font Size (%)","",90, 0, 100);
   indicator.parameters:addDouble("VSpace", "Vertical Spacing (%)","",5, 0, 50);
   indicator.parameters:addDouble("HSpace", "Horizontal Spacing (%)","",5, 0, 50);
end
local On={};
local oPair;
local oTime ;

local source;
local day_offset, week_offset;
local Label = {"First", "Second", "Third", "Fourth"};
local first;
local VSpace,HSpace;
local Color;
local Size;
local SourceData={};
local TF={};
local loading={};
local Number=5;
local host;
local TS={};
local Type={};
local Period={};
local Up, Down, Neutral;
local Instrument={};
function Prepare(nameOnly)
    source = instance.source;	
	VSpace=(instance.parameters.VSpace/100);
	HSpace=(instance.parameters.HSpace/100);
	Up=instance.parameters.Up;
	Down=instance.parameters.Down;
	Neutral=instance.parameters.Neutral;
	
	oPair=instance.parameters.oPair;
	oTime=instance.parameters.oTime;
	
	
	 host = core.host;
	Size=instance.parameters.size;
    Color=instance.parameters.Color;
    first=source:first();
    local name = profile:id() .. "(" .. source:name() .. ")"; 
    instance:name(name);

    if   (nameOnly) then
        return;
    end
	
  
   assert(core.indicators:findIndicator("TRENDSTOP") ~= nil, "Please, download and install TRENDSTOP.BIN indicator");
     day_offset = host:execute("getTradingDayOffset");
    week_offset = host:execute("getTradingWeekOffset");
    local Id=0;
    Number=0;
   
    for i = 1, 5, 1 do
	 if  instance.parameters:getBoolean("On" .. i) then
	 
	 Number=Number+1;
	 Label[Number]="";
	            On[Number]=instance.parameters:getBoolean("On" .. i);
				Type[Number]=  instance.parameters:getString("Type" .. i);
				Period[Number]=  instance.parameters:getInteger("Period" .. i);
				if  oPair then
	            Instrument[Number]=source:instrument();
	            else			
				Instrument[Number]=  instance.parameters:getString("Instrument" .. i);				
				end
				
				
				Label[Number]=Instrument[Number];
				
				if  oTime then
	            TF[Number]=source:barSize();
				else
				TF[Number]=  instance.parameters:getString("TF" .. i);				
				end
				
				Label[Number]=Label[Number] .. "  -  " ..  TF[Number];
				
				Temp1= core.indicators:create("TRENDSTOP",source, Period[Number], Type[Number]);  				
				first= Temp1.DATA:first();
				
				   Id=Id+1;
				 SourceData[Number]  = core.host:execute("getSyncHistory",  Instrument[Number],  TF[Number], source:isBid(),first*2, 2000 + Id , 1000 +Id);	 	 
				 loading[Number]  = true;  	 
				 TS[Number] = core.indicators:create("TRENDSTOP", SourceData[Number],Period[Number], Type[Number]);         
			 
				  
					 
       end
    end
	
    core.host:execute ("setTimer", 1, 1);
	instance:setLabelColor(Color);
   instance:ownerDrawn(true);
end

function ReleaseInstance()
core.host:execute ("killTimer", 1);
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
   
   
   if not FLAG and cookie== 1 then
             for i = 1, Number, 1 do 
			 TS[i]:update(core.UpdateAll);
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
	 
   local style = context.SINGLELINE + context.CENTER + context.VCENTER;  
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
 
      
        local first = math.max(source:first(), context:firstBar ());
        local last = math.min (context:lastBar (), source:size()-1);
		
    
	    X0, X1, X2 = context:positionOfBar (source:size()-1); 
		 HCellSize =(X2-X1)*HSpace;
		 VCellSize =((context:bottom() -context:top())/ (Number+1)); 
	
	
	
	
	
       for i= first, last, 1 do	   
	    
	   
	   x0, x1, x2 = context:positionOfBar (i);
	        
			 
			 for j= 1, Number , 1 do
			 
				  p=Initialization(i,j);
				  if p~= false and TS[j].DATA:hasData(p) then
					  if SourceData[j].close[p]>TS[j].DATA[p] then
					  C1=11;C2=12;
					  elseif SourceData[j].close[p]<TS[j].DATA[p] then
					   C1=21;C2=22;
					  else
					   C1=31;C2=32;
					  end
				  else
				  C1=1;C2=2;
				  end
				  
				  
				  --///////////////////////////////////////////////////////////////////////////////////////////
				  
				  	 
	                context:drawRectangle (C1, C2, x1+HCellSize, context:top()+VCellSize/2+VCellSize * (j-1) +VCellSize* VSpace, x2-HCellSize, context:top()+VCellSize/2 + VCellSize * (j )-VCellSize* VSpace);
				   
				   
					 if i== first then			 	 
					 local width, height; 
					 context:createFont(3, "Arial", ((X2-X1)/100)*Size, (VCellSize/100)*Size, context.NORMAL);
					 Value= tostring( Label[j]);
					 width, height = context:measureText (3,  Value , style)	 
					 context:drawText(3,  Value , Color, -1, X2 +(X2-X1), context:top()+VCellSize/2+VCellSize * (j-1) +VCellSize* VSpace ,X2+(X2-X1)+width, context:top()+VCellSize/2 + VCellSize * (j )-VCellSize* VSpace, style);
                     end
				  
				  --\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
				  
				  
			 end
	   end
     
     --[[ x0, x1, x2 = context:positionOfBar (source:size()-1);
	 
	 local width, height;
     for j= 1, Number , 1 do 
     width, height = context:measureText (3, Label[j], style)	 
	 context:drawText(3, Label[j], Color, -1, x2, 2*Size + Size*j+j*VS,x2+width, 2*Size + Size*(j+1)+j*VS, style);
	 end]]
	 

 
end


