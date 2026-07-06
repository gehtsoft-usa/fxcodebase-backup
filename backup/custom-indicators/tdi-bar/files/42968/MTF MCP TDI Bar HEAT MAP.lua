
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=24940


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

 function Add(id, TF,Flag, Instrument )
   
    indicator.parameters:addGroup(id..". Slot" );
	indicator.parameters:addBoolean("On".. id , "Show This Slot", "",true);	  
 
    indicator.parameters:addString("TF" .. id, "Time Frame ", "", TF);
    indicator.parameters:setFlag("TF" .. id, core.FLAG_PERIODS);
	
	indicator.parameters:addString("Instrument" .. id, "Instrument", "", Instrument);
    indicator.parameters:setFlag("Instrument" .. id, core.FLAG_INSTRUMENTS);
	
	indicator.parameters:addString("Price".. id, "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price".. id, "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price".. id, "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price".. id, "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price".. id,"CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price".. id, "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price".. id, "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price".. id, "WEIGHTED", "", "weighted");	
 
	indicator.parameters:addString("Method"..id, " Method", "Method" , "TDI/SIGNAL");
    indicator.parameters:addStringAlternative("Method"..id, "TDI/SIGNAL", "TDI/SIGNAL" , "TDI/SIGNAL");
    indicator.parameters:addStringAlternative("Method"..id,"TDI/BASE" , "TDI/BASE", "TDI/BASE");
    indicator.parameters:addStringAlternative("Method"..id, "TDI/BAND", "TDI/BAND" , "TDI/BAND");
	indicator.parameters:addStringAlternative("Method"..id, "TDI/SIGNAL/BASE", "TDI/SIGNAL/BASE" , "TDI/SIGNAL/BASE");
	indicator.parameters:addStringAlternative("Method"..id, "OVERBOUGHT LEVEL / OVER SOLD LEVEL", "OVERBOUGHT LEVEL / OVER SOLD LEVEL" , "OVERBOUGHT LEVEL / OVER SOLD LEVEL");
	
	
	 indicator.parameters:addInteger("RSI_N"..id, "RSI Periods", "Recommended values are in 8-25 range", 13, 2, 1000);
    indicator.parameters:addInteger("VB_N"..id, "Volatility Band", "Number of periods to find volatility band. Recommended value is 20-40", 34, 2, 1000);
    indicator.parameters:addDouble("VB_W"..id, "Volatility Band Width", "", 1.6185, 0, 100);

    indicator.parameters:addInteger("RSI_P_N"..id, "RSI Price Line Periods", "", 2, 1, 1000);
    indicator.parameters:addString("RSI_P_M"..id, "RSI Price Line Smoothing Method", "", "MVA");
    indicator.parameters:addStringAlternative("RSI_P_M"..id, "MVA(SMA)", "", "MVA");
    indicator.parameters:addStringAlternative("RSI_P_M"..id, "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("RSI_P_M"..id, "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("RSI_P_M"..id, "LSMA(Regression)", "", "REGRESSION");
    indicator.parameters:addStringAlternative("RSI_P_M"..id, "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("RSI_P_M"..id, "WMA(Wilders)", "", "WMA");
    indicator.parameters:addStringAlternative("RSI_P_M"..id, "KAMA(Kaufman)", "", "KAMA");

    indicator.parameters:addInteger("TS_N"..id, "Trade Signal Line Periods", "", 7, 1, 1000);
    indicator.parameters:addString("TS_M"..id, "Trade Signal Line Smoothing Method", "", "MVA");
    indicator.parameters:addStringAlternative("TS_M"..id, "MVA(SMA)", "", "MVA");
    indicator.parameters:addStringAlternative("TS_M"..id, "EMA", "", "EMA");
    indicator.parameters:addStringAlternative("TS_M"..id, "LWMA", "", "LWMA");
    indicator.parameters:addStringAlternative("TS_M"..id, "LSMA(Regression)", "", "REGRESSION");
    indicator.parameters:addStringAlternative("TS_M"..id, "SMMA", "", "SMMA");
    indicator.parameters:addStringAlternative("TS_M"..id, "WMA(Wilders)", "", "WMA");
    indicator.parameters:addStringAlternative("TS_M"..id, "KAMA(Kaufman)", "", "KAMA");

    indicator.parameters:addDouble("OB"..id, "OB Level" , "",70);
	indicator.parameters:addDouble("OS"..id, "OS Level" , "",30);
	indicator.parameters:addDouble("Buy"..id, "Buy Entry Level" , "",50);
	indicator.parameters:addDouble("Sell"..id, "Sell Entry Level" , "",50);
end


 
function Init()
    indicator:name("MTF MCP TDI Bar HEAT MAP");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	
	indicator.parameters:addGroup("Override" );
	
	indicator.parameters:addString("ChartMethod", "Override Method", "Method" , "Chart Instrument");
    indicator.parameters:addStringAlternative("ChartMethod", "Independent", "Independent" , "Independent");
    indicator.parameters:addStringAlternative("ChartMethod", "Chart Time Frame", "Chart Time Frame" , "Chart Time Frame");
	indicator.parameters:addStringAlternative("ChartMethod", "Chart Instrument", "Chart Instrument" , "Chart Instrument"); 	 
  
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
	indicator.parameters:addColor("DownUp", "Up in Down Trend Color","", core.rgb(255, 0, 0));
	indicator.parameters:addColor("DownDown", "Down in Down Trend Color","", core.rgb(200, 0, 0));
	
	indicator.parameters:addColor("NeutralUp", "Up in Neutral Trend Color","", core.rgb(128, 128, 128));
	indicator.parameters:addColor("NeutralDown", "Down in Neutral Trend Color","", core.rgb(100, 100, 100));

   indicator.parameters:addDouble("VSpace", "Vertical Spacing (%)","",5, 0, 50);
   indicator.parameters:addDouble("HSpace", "Horizontal Spacing (%)","",5, 0, 50);
   indicator.parameters:addDouble("Size", "Font Size (%)","",90, 50, 200);
   
   
end
local On={};
local ChartMethod;
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
local UpUp, DownDown ;
local UpDown, DownUp ;
local NeutralUp, NeutralDown ;
 
    	local Indicator={};
		local Instrument={};
       local Period={};
		local Method={};
		local RSI_N={};
		local VB_N={};
		local VB_W={};
		local RSI_P_N={};
		local RSI_P_M={};
		local TS_N={};
		local TS_M={};
		local Price={};
		 local OB={};
		 local OS={};
		 local Buy={};
		 local Sell={};
 
function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
 
    source = instance.source;	
	VSpace=(instance.parameters.VSpace/100);
	HSpace=(instance.parameters.HSpace/100);
	ChartMethod=instance.parameters.ChartMethod;
	
	UpUp=instance.parameters.UpUp;
	DownDown=instance.parameters.DownDown;
	UpDown=instance.parameters.UpDown;
	DownUp=instance.parameters.DownUp;
	
	NeutralDown=instance.parameters.NeutralDown;
	NeutralUp=instance.parameters.NeutralUp;
	
	 host = core.host;
	Size=instance.parameters.Size;
    Color=instance.parameters.Color;
   instance:setLabelColor(Color);
   instance:ownerDrawn(true);
   

    
     day_offset = host:execute("getTradingDayOffset");
    week_offset = host:execute("getTradingWeekOffset");
    local Id=0;
    Number=0;
   
	local ifirst;
	 local s1, e1, s2, e2;
	  s1, e1 = core.getcandle(source:barSize(), 0, 0, 0);
	 
	 local iTF={};
	 for i = 1, 13, 1 do
		       if   ChartMethod== "Chart Time Frame" then
	            iTF[i]=source:barSize();
				else
				iTF[i]=  instance.parameters:getString("TF" .. i);	
                		
				end
		 		
	end

	
	 assert(core.indicators:findIndicator("TDI BAR") ~= nil, "Please, download and install TDI BAR.LUA indicator");
	 
	AlertNumber=0;
	  for i = 1, 13, 1 do
	s2, e2 = core.getcandle(iTF[i], 0, 0, 0);
	
	 if  instance.parameters:getBoolean("On" .. i) and (e1 - s1) <= (e2 - s2)  then
	 Number=Number+1;
	 
         	RSI_N[Number]= instance.parameters:getString("RSI_N" .. i);	
			VB_N[Number]= instance.parameters:getString("VB_N" .. i);	
			VB_W[Number]= instance.parameters:getString("VB_W" .. i);	
			RSI_P_N[Number]= instance.parameters:getString("RSI_P_N" .. i);	
			RSI_P_M[Number]= instance.parameters:getString("RSI_P_M" .. i);	
			TS_N[Number]= instance.parameters:getString("TS_N" .. i);	
			TS_M[Number]= instance.parameters:getString("TS_M" .. i);	
			
			Price[Number]= instance.parameters:getString("Price" .. i);
			Method[Number]= instance.parameters:getString("Method" .. i);	
		  	 OB[Number]= instance.parameters:getDouble("OB" .. i);	
		     OS[Number]= instance.parameters:getDouble("OS" .. i);	
		     Buy[Number]= instance.parameters:getDouble("Buy" .. i);	
		     Sell[Number]= instance.parameters:getDouble("Sell" .. i);	
		
		  
	 Label[Number]="";
	           
				 
				if  ChartMethod== "Chart Instrument" then
	            Instrument[Number]=source:instrument();
				Label[Number]="";
	            else			
				Instrument[Number]=  instance.parameters:getString("Instrument" .. i);	 
				Label[Number]=Instrument[Number];
				end
				
				 
				 
				if   ChartMethod== "Chart Time Frame" then 
				TF[Number]=iTF[i];
				else
				TF[Number]=iTF[i];
                Label[Number]=Label[Number] .. " - " ..  TF[Number];				
				end
				
				
				
			  	 Test = core.indicators:create("TDI BAR", source[Price[Number]], Method[Number], RSI_N[Number], VB_N[Number], VB_W[Number], RSI_P_N[Number], RSI_P_M[Number], TS_N[Number],TS_M[Number], OB[Number], OS[Number], Buy[Number], Sell[Number]);
	             first= Test.DATA:first()*2 ;
			
				
				   Id=Id+1;
				 SourceData[Number]  = core.host:execute("getSyncHistory",  Instrument[Number],  TF[Number], source:isBid(),math.min(300,first), 2000 + Id , 1000 +Id);	 	 
				 loading[Number]  = true;  	 
				  Indicator[Number] = core.indicators:create("TDI BAR", SourceData[Number][Price[Number]], Method[Number], RSI_N[Number], VB_N[Number], VB_W[Number], RSI_P_N[Number], RSI_P_M[Number], TS_N[Number],TS_M[Number], OB[Number], OS[Number], Buy[Number], Sell[Number], UpUp, UpDown,DownUp,DownDown,NeutralUp,NeutralDown);
			 
				   
       end
    end
  
	
	 
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
	core.host:execute ("setStatus", "Loaded");	 
    instance:updateFrom(0);    
	end
	
	
   
        
    return core.ASYNC_REDRAW ;
	
	
end

function Update(period)
 
     
end

local init = false;

function Draw (stage, context)

    if stage  ~= 0 then
	return;
	end
	 
	 
	local FLAG=false; 

    for j = 1, Number, 1 do
		     
                 if loading[j] 
				 then
				 FLAG= true;
				 end
				 
	end    
    
	
	if FLAG then
	return;	 
	end
   
    local style = context.SINGLELINE + context.CENTER + context.VCENTER;
	 
  
   context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());
   
        if not init then
		   
			
			 context:createPen (1, context.SOLID, 3, Color)       
			context:createSolidBrush(2, Color);
			
			context:createPen (11, context.SOLID, 3, UpUp)       
			context:createSolidBrush(12, UpUp);
			
			context:createPen (21, context.SOLID, 3, UpDown)       
			context:createSolidBrush(22, UpDown);
		
			
			context:createPen (31, context.SOLID, 3, DownUp)       
			context:createSolidBrush(32, DownUp);
			
			context:createPen (41, context.SOLID, 3, DownDown)       
			context:createSolidBrush(42, DownDown);
			
			
			context:createPen (51, context.SOLID, 3, NeutralUp)       
			context:createSolidBrush(52, NeutralUp);
			
			context:createPen (61, context.SOLID, 3, NeutralDown)       
			context:createSolidBrush(62, NeutralDown);
		 
		  
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
				   
						
								
										if Indicator[j].DATA:hasData(p)   then 
										
												    if Indicator[j].DATA:colorI(p) == UpUp then		 
															 
															C2=12;
															C1=11;
													 elseif Indicator[j].DATA:colorI(p) == UpDown then		 
															C2=22;
															C1=21;
															 
												 
												    elseif Indicator[j].DATA:colorI(p) == DownUp then		  
													        
															C2=32;
															C1=31;
													 elseif Indicator[j].DATA:colorI(p) == DownDown then		  
															C2=42;
															C1=41;
														 
													   elseif Indicator[j].DATA:colorI(p) == NeutralUp then		  
													        
															C2=52;
															C1=51;
													 elseif Indicator[j].DATA:colorI(p) == NeutralDown then		  
															C2=62;
															C1=61;
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
 