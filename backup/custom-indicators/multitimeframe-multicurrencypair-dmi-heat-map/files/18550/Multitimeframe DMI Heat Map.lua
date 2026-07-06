
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=8388

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


 function Add(id, TF,Flag, Instrument )
   
    indicator.parameters:addGroup(id..". Slot" );
	indicator.parameters:addBoolean("On".. id , "Show This Slot", "",Flag);	    
    indicator.parameters:addString("TF" .. id, "Time Frame ", "", TF);
    indicator.parameters:setFlag("TF" .. id, core.FLAG_PERIODS);
	
	indicator.parameters:addString("Instrument" .. id, "Instrument", "", Instrument);
    indicator.parameters:setFlag("Instrument" .. id, core.FLAG_INSTRUMENTS);
	
	indicator.parameters:addInteger("Period".. id, "Number of periods for DMI", "", 14, 1, 200);
    
end

 
 
function Init()
    indicator:name("MTF MCP DMI Heat Map");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	
	indicator.parameters:addGroup("Override" );
	
	indicator.parameters:addString("Method", "Override Method", "Method" , "Chart Instrument");
    indicator.parameters:addStringAlternative("Method", "Independent", "Independent" , "Independent");
    indicator.parameters:addStringAlternative("Method", "Chart Time Frame", "Chart Time Frame" , "Chart Time Frame");
	indicator.parameters:addStringAlternative("Method", "Chart Instrument", "Chart Instrument" , "Chart Instrument"); 	 
  
    Add(1, "m1", true, "EUR/USD"); 
    Add(2, "m5", true, "USD/JPY"); 
    Add(3, "m15", true, "GBP/USD"); 
    Add(4, "m30", true, "USD/CHF"); 
    Add(5, "H1", true, "EUR/CHF"); 
    Add(6, "H2", true, "AUD/USD"); 
    Add(7, "H3", true, "USD/CAD"); 
    Add(8, "H4", true, "NZD/USD" ); 
    Add(9, "H6", true, "NZD/USD" ); 
    Add(10, "H8", true, "EUR/JPY"); 
    Add(11, "D1", true, "GBP/JPY"); 
    Add(12, "W1", true, "CHF/JPY"); 
    Add(13, "M1", true, "GBP/CHF");

 
     indicator.parameters:addGroup("Style");
	indicator.parameters:addColor("Color", "Label Color","", core.rgb(0, 0, 0));
	indicator.parameters:addColor("UpUp", "Up in Up Trend Color","", core.rgb(0, 255, 0));
	indicator.parameters:addColor("UpDown", "Down in Up Trend Color","", core.rgb(0, 200, 0));
	indicator.parameters:addColor("DownUp", "Up in Down Trend Color","", core.rgb(200, 0, 0));
	indicator.parameters:addColor("DownDown", "Down in Down Trend Color","", core.rgb(255, 0, 0));

	
	
   indicator.parameters:addDouble("VSpace", "Vertical Spacing (%)","",0, 0, 50);
   indicator.parameters:addDouble("HSpace", "Horizontal Spacing (%)","",0, 0, 50);
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
local Instrument={};

local Period= {} ;
local Indicator = {} ;
  

function Prepare(nameOnly)  
    source = instance.source;	
	VSpace=(instance.parameters.VSpace/100);
	HSpace=(instance.parameters.HSpace/100);
	Method=instance.parameters.Method;
	
	UpUp=instance.parameters.UpUp;
	DownDown=instance.parameters.DownDown;
	UpDown=instance.parameters.UpDown;
	DownUp=instance.parameters.DownUp;
	
	 host = core.host;
	Size=instance.parameters.Size;
    Color=instance.parameters.Color;

    
     day_offset = host:execute("getTradingDayOffset");
    week_offset = host:execute("getTradingWeekOffset");
    local Id=0;
    Number=0;
    local name = profile:id() .. " " .. source:name()  .. " : " .. source:barSize();
	instance:name(name ..   " : "  ..  Method);	
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

	
	  for i = 1, 13, 1 do
	s2, e2 = core.getcandle(iTF[i], 0, 0, 0);
	
	 if  instance.parameters:getBoolean("On" .. i) and (e1 - s1) <= (e2 - s2)  then
	  
	 
	 Number=Number+1;
	 
	      Period[Number]= instance.parameters:getInteger("Period" .. i);
		  
		
		  
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
                Label[Number]=Label[Number] .. " - " ..  TF[Number];				
				end
				
				
				
			  	Temp1= core.indicators:create("DMI", source ,  Period[Number]);  				
				ifirst= Temp1.DATA:first();
			
				
				   Id=Id+1;
				 SourceData[Number]  = core.host:execute("getSyncHistory",  Instrument[Number],  TF[Number], source:isBid(),math.min(300,ifirst), 2000 + Id , 1000 +Id);	 	 
				 loading[Number]  = true;  	 
				 Indicator[Number] = core.indicators:create("DMI", SourceData[Number] ,  Period[Number]);   
			 
				   
       end
    end
  
	   instance:setLabelColor(Color);
       instance:ownerDrawn(true);
	    	
		core.host:execute ("setTimer", 1, 1);
 
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
			  instance:updateFrom(0);
			  end
		 
		       
                 if loading[j] then
				 FLAG= true;
				 Num=Num+1;
				 end
	end    
	
	
	 if not FLAG and cookie== 1 then
		for i= 1, Number , 1 do
			  Indicator[i]:update(core.UpdateLast );
		end
		
	end
	
   
           
	
	if FLAG then
	 core.host:execute ("setStatus", "  Loading "..((Number) - Num) .. " / " .. (Number) );	 
	else
	core.host:execute ("setStatus", "Loaded")
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
	end
   
    local style = context.SINGLELINE + context.CENTER + context.VCENTER;
	 
  
   context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());
   
        if not init then
		     context:createPen (1, context.SOLID, 1, Color)       
			context:createSolidBrush(2, Color);
			
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
		 
		  
            init = true;
        end
     
        
        local first = math.max(source:first(), context:firstBar ());
        local last = math.min (context:lastBar (), source:size()-1);
		
    
	    X0, X1, X2 = context:positionOfBar (source:size()-1); 
		 HCellSize =((X2-X1)/100)*HSpace;
		 VCellSize =((context:bottom() -context:top())/ (Number+1)); 
	
      
	    	
	          			
			
			 
			    for i= first, last, 1 do	 
			   x0, x1, x2 = context:positionOfBar (i);
			   
			    for j= 1, Number , 1 do
				  p=Initialization(i,j);
				  if p~= false then
				   
								 
								
										if Indicator[j].DIP:hasData(p) and Indicator[j].DIP:hasData(p-1) then 
										
												    if Indicator[j].DIP[p] > Indicator[j].DIM[p] then		 
															if Indicator[j].DIP[p] > Indicator[j].DIP[p-1] then	
															C2=12;
															C1=11;
															else
															C2=22;
															C1=21;
															end														
													
												    else  
													        if Indicator[j].DIP[p] > Indicator[j].DIP[p-1] then	
															C2=32;
															C1=31;
															else
															C2=42;
															C1=41;
															end														
													
													end
										
																									
												
											 
												 
												     
									   else		
									   C1=1; C2=2;										   
									   end 
									   
						 
				 else
                   
					 C1=1; C2=2;		
										
				end						
				   context:drawRectangle (C1, C2, x1+HCellSize, context:top()+VCellSize * (j) +VCellSize* VSpace, x2-HCellSize, context:top() + VCellSize * (j+1)-VCellSize* VSpace);
				   
				   
				 if i== first then			 	 
				 local width, height; 
				 context:createFont(3, "Arial", ((X2-X1)/100)*Size, (VCellSize/100)*Size, context.NORMAL);
				 Value= tostring( Label[j]);
				 width, height = context:measureText (3,  Value , style)	 
				 context:drawText(3,  Value , Color, -1, X2 +(X2-X1), context:top()+VCellSize * (j) +VCellSize* VSpace ,X2+(X2-X1)+width, context:top() + VCellSize * (j+1)-VCellSize* VSpace, style);
				 end
			 
			 end
			 
	   end
     
end


