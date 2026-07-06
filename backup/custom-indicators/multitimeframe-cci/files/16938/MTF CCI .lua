-- Id: 4870
--+------------------------------------------------------------------+
--|                               Copyright © 2017, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+

 function Add(id, TF,Flag, Instrument )
   
    indicator.parameters:addGroup(id..". Slot" );
	indicator.parameters:addBoolean("On".. id , "Show This Slot", "",true);	  
 
    indicator.parameters:addString("TF" .. id, "Time Frame ", "", TF);
    indicator.parameters:setFlag("TF" .. id, core.FLAG_PERIODS);
	
	indicator.parameters:addString("Instrument" .. id, "Instrument", "", Instrument);
    indicator.parameters:setFlag("Instrument" .. id, core.FLAG_INSTRUMENTS);
	
	indicator.parameters:addInteger("Period".. id, "Number of periods for CCI", "", 14, 1, 200);
    
end

 
 
function Init()
    indicator:name("Multitimeframe CCI");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	
	indicator.parameters:addGroup("Override" );
	
	indicator.parameters:addString("Method", "Override Method", "Method" , "Chart Instrument");
    indicator.parameters:addStringAlternative("Method", "Independent", "Independent" , "Independent");
    indicator.parameters:addStringAlternative("Method", "Chart Time Frame", "Chart Time Frame" , "Chart Time Frame");
	indicator.parameters:addStringAlternative("Method", "Chart Instrument", "Chart Instrument" , "Chart Instrument"); 	 
  
    Add(1, "m1",  "Off", "EUR/USD"); 
    Add(2, "m5",  "Off", "USD/JPY"); 
    Add(3, "m15",  "Off", "GBP/USD"); 
    Add(4, "m30",  "Off", "USD/CHF"); 
    Add(5, "H1",  "Off", "EUR/CHF"); 
    Add(6, "H2", "View", "AUD/USD"); 
    Add(7, "H3",  "Off", "USD/CAD"); 
    Add(8, "H4", "View", "NZD/USD" ); 
    Add(9, "H6",  "Off", "NZD/USD" ); 
    Add(10, "H8", "View", "EUR/JPY"); 
    Add(11, "D1",  "Off", "GBP/JPY"); 
    Add(12, "W1",  "Off", "CHF/JPY"); 
    Add(13, "M1",  "Off", "GBP/CHF");

 
     indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Color", "Label Color","", core.rgb(0, 0, 0));
	indicator.parameters:addColor("UpUp", "Up in Up Trend Color","", core.rgb(0, 255, 0));
	indicator.parameters:addColor("UpDown", "Down in Up Trend Color","", core.rgb(0, 200, 0));
	indicator.parameters:addColor("DownUp", "Up in Down Trend Color","", core.rgb(200, 0, 0));
	indicator.parameters:addColor("DownDown", "Down in Down Trend Color","", core.rgb(255, 0, 0));
	
	indicator.parameters:addColor("OBUp", "Up in OB Zone Color","", core.rgb(0, 128, 255));
	indicator.parameters:addColor("OBDown", "Down in OB Zone  Color","", core.rgb(0, 128, 200));
	
	indicator.parameters:addColor("OSUp", "Up in OS Zone Color","", core.rgb(128, 0, 255));
	indicator.parameters:addColor("OSDown", "Down in OS Zone Color","", core.rgb(128, 0, 200));

   indicator.parameters:addDouble("VSpace", "Vertical Spacing (%)","",5, 0, 50);
   indicator.parameters:addDouble("HSpace", "Horizontal Spacing (%)","",5, 0, 50);
   indicator.parameters:addDouble("Size", "Font Size (%)","",90, 50, 200);
   
   
end
local On={};
local Method;
local source;
local day_offset, week_offset;
local Label = {"First", "Second", "Third", "Fourth"};

local VSpace,HSpace;
local Color;
local Size;
local SourceData={};
local TF={};
local loading={};
local Number;
local host;
local RSI={}; 
local UpUp, DownDown ;
local UpDown, DownUp ;
local OBUp, OBDown;
local OSUp, OSDown;
local Instrument={};

local Period= {} ;
local Indicator = {} ;
 
local Last; 


function Prepare(nameOnly)
 
    source = instance.source;	
	VSpace=(instance.parameters.VSpace/100);
	HSpace=(instance.parameters.HSpace/100);
	Method=instance.parameters.Method;
	
	UpUp=instance.parameters.UpUp;
	DownDown=instance.parameters.DownDown;
	UpDown=instance.parameters.UpDown;
	DownUp=instance.parameters.DownUp;
	
	OBUp=instance.parameters.OBUp;
	OBDown =instance.parameters.OBDown;
    OSUp=instance.parameters.OSUp;
	OSDown=instance.parameters.OSDown;
	
	 host = core.host;
	Size=instance.parameters.Size;
    Color=instance.parameters.Color;
  
   
   Last=nil;
    
     day_offset = host:execute("getTradingDayOffset");
    week_offset = host:execute("getTradingWeekOffset");
    local Id=0;
    Number=0;
    local name = profile:id() .. " " .. source:name()  .. " : " .. source:barSize();
	
	instance:name(name ..   " : "  ..  Method.. " ");
		
		if   (nameOnly) then
        return;
         end
		 
	
	local ifirst;
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

	AlertNumber=0;
	  for i = 1, 13, 1 do
	s2, e2 = core.getcandle(iTF[i], 0, 0, 0);
	
	 if  instance.parameters:getBoolean("On" .. i) and (e1 - s1) <= (e2 - s2)  then
	 Number=Number+1;
	 
	      Period[Number]= instance.parameters:getInteger("Period" .. i);
		  
		
		  
	 Label[Number]="";
	           
				 
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
                Label[Number]=Label[Number] .. " - " ..  TF[Number];				
				end
				
				
				
			  	Temp1= core.indicators:create("CCI", source ,  Period[Number]);  				
				ifirst= Temp1.DATA:first()*2;
			
				
				   Id=Id+1;
				 SourceData[Number]  = core.host:execute("getSyncHistory",  Instrument[Number],  TF[Number], source:isBid(),math.min(300,ifirst), 2000 + Id , 1000 +Id);	 	 
				 loading[Number]  = true;  	 
				 Indicator[Number] = core.indicators:create("CCI", SourceData[Number] ,  Period[Number]);   
			 
				   
       end
    end
  
	
   instance:setLabelColor(Color);
   instance:ownerDrawn(true); 
		
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
   
           
	
	if FLAG then
	 core.host:execute ("setStatus", "  Loading "..((Number) - Num) .. " / " .. (Number) );	 
	else
	core.host:execute ("setStatus", "Loaded");	            
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
    
	
	if FLAG then
	return;
	else
	   for i= 1, Number , 1 do
	  Indicator[i]:update(core.UpdateLast );
	  end
	 
	end
   
    local style = context.SINGLELINE + context.CENTER + context.VCENTER;
	 
  
   context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());
   
        if not init then
		   
			
			 context:createPen (1, context.SOLID, 1, Color)       
			context:createSolidBrush(2, Color);
			
			context:createPen (11, context.SOLID, 1, UpUp)       
			context:createSolidBrush(12, UpUp);
			
			context:createPen (21, context.SOLID, 1, UpDown)       
			context:createSolidBrush(22, UpDown);
		
			
			context:createPen (31, context.SOLID, 1, DownUp)       
			context:createSolidBrush(32, DownUp);
			
			context:createPen (41, context.SOLID, 1, DownDown)       
			context:createSolidBrush(42, DownDown);
			
			
			context:createPen (51, context.SOLID, 1, OBUp)       
			context:createSolidBrush(52, OBUp);
			
			context:createPen (53, context.SOLID, 1, OBDown)       
			context:createSolidBrush(54, OBDown);
			
			
			context:createPen (55, context.SOLID, 1, OSUp)       
			context:createSolidBrush(56, OSUp);
			
			context:createPen (57, context.SOLID, 1, OSDown)       
			context:createSolidBrush(58, OSDown);
		 
		  
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
				  
				 
				  
				  if p~= false then
				   
						
								
										if Indicator[j].DATA:hasData(p) and Indicator[j].DATA:hasData(p-1) then 
										
												    if Indicator[j].DATA[p] > 0 then		 
															if Indicator[j].DATA[p] > Indicator[j].DATA[p-1] then	
															C2=12;
															C1=11;
															else
															C2=22;
															C1=21;
															end		
												 
												    else  
													        if Indicator[j].DATA[p] > Indicator[j].DATA[p-1] then	
															C2=32;
															C1=31;
															else
															C2=42;
															C1=41;
															end														
													 
													end
										
													if Indicator[j].DATA[p] > 100 then		 
															if Indicator[j].DATA[p] > Indicator[j].DATA[p-1] then	
															C2=52;
															C1=51;
															else
															C2=54;
															C1=53;
															end		
												 
												    elseif Indicator[j].DATA[p] < -100 then		   
													        if Indicator[j].DATA[p] > Indicator[j].DATA[p-1] then	
															C2=56;
															C1=55;
															else
															C2=58;
															C1=57;
															end														
													 
													end												
												
											 
												 
												     
									   else		
									   C1=1; C2=2;										   
									   end 
									   
						 
				 else
                   
					 C1=1; C2=2;		
										
				end						
				   context:drawRectangle (C1, C2, x1+HCellSize, context:top()+VCellSize/2+VCellSize * (j-1) +VCellSize* VSpace, x2-HCellSize, context:top() +VCellSize/2+ VCellSize * (j)-VCellSize* VSpace);
				   
				   
					 if i== first then			 	 
					 local width, height; 
					 context:createFont(3, "Arial", ((X2-X1)/100)*Size, (VCellSize/100)*Size, context.NORMAL);
					 Value= tostring( Label[j]);
					 width, height = context:measureText (3,  Value , style)	 
					 context:drawText(3,  Value , Color, -1, X2 +(X2-X1), context:top()+VCellSize/2+VCellSize * (j-1) +VCellSize* VSpace ,X2+(X2-X1)+width, context:top()+VCellSize/2 + VCellSize * (j)-VCellSize* VSpace, style);
					 
					 
									

					 end  				 
				 
				 
			 
			 end
			 
	   end
	   
	
end

