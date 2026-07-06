
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=27184

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


-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("MTF MCP Consensus of Five");
    indicator:description("MTF MCP Consensus of Five");
     indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
  
    indicator.parameters:addGroup("Calculation");
	indicator.parameters:addGroup("Selector");
    indicator.parameters:addBoolean("One", "Use DMI Filter", "", true);
	indicator.parameters:addBoolean("Two", "Use ADX Filter", "", true);
	indicator.parameters:addBoolean("Three", "Use CCI Filter", "", true);
	indicator.parameters:addBoolean("Four", "Use MACD Filter", "", true);
	indicator.parameters:addBoolean("Five", "Use Stochastic Filter", "", true);
	
	indicator.parameters:addGroup("DMI Calculation");
	indicator.parameters:addInteger("DMI", "Period", "", 14);
	
	indicator.parameters:addGroup("ADX Calculation");
	indicator.parameters:addInteger("ADX", "Period", "", 14);
	indicator.parameters:addDouble("ADX_Entry", "Entry Level", "", 20);
	indicator.parameters:addDouble("ADX_Exit", "Exit Level", "", 40);
	
	indicator.parameters:addGroup("CCI Calculation");
	indicator.parameters:addInteger("CCI", "Period", "", 14);
	indicator.parameters:addDouble("CCI_Buy", "Buy Level", "", 0);
	indicator.parameters:addDouble("CCI_Sell", "Sell Level", "", 0);
	
	
	indicator.parameters:addGroup("MACD Calculation");
	indicator.parameters:addInteger("MACD_Short", "Short Period", "", 12);
	indicator.parameters:addInteger("MACD_Long", "Long Period", "", 26);
	indicator.parameters:addDouble("MACD_Buy", "Buy Level", "", 0);
	indicator.parameters:addDouble("MACD_Sell", "Sell Level", "", 0);
	
	indicator.parameters:addString("MACD_Price", "Price Source", "", "close");
    indicator.parameters:addStringAlternative("MACD_Price", "OPEN", "", "open");
    indicator.parameters:addStringAlternative("MACD_Price", "HIGH", "", "high");
    indicator.parameters:addStringAlternative("MACD_Price", "LOW", "", "low");
    indicator.parameters:addStringAlternative("MACD_Price","CLOSE", "", "close");
    indicator.parameters:addStringAlternative("MACD_Price", "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("MACD_Price", "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("MACD_Price", "WEIGHTED", "", "weighted");	
	
	    indicator.parameters:addGroup("Stochastic Calculation");
	
	indicator.parameters:addInteger("K", "Number of periods for %K", "The number of periods for %K.", 5, 2, 1000);
    indicator.parameters:addInteger("SD", "%D slowing periods", "The number of periods for slow %D.", 3, 2, 1000);
    indicator.parameters:addInteger("D", "Number of periods for %D", "The number of periods for %D.", 3, 2, 1000);

    indicator.parameters:addString("MVAT_K", "Smoothing type for %K", "The type of smoothing algorithm for %K.", "MVA");
    indicator.parameters:addStringAlternative("MVAT_K", "MVA", "MVA", "MVA");
    indicator.parameters:addStringAlternative("MVAT_K", "EMA", "EMA", "EMA");
    indicator.parameters:addStringAlternative("MVAT_K", "MetaTrader", "The MetaTrader algorithm.", "MT");
	indicator.parameters:addStringAlternative("MVAT_K" , "LWMA", "", "LWMA");	
	indicator.parameters:addStringAlternative("MVAT_K" , "KAMA", "", "KAMA");	
	indicator.parameters:addStringAlternative("MVAT_K" , "SMMA", "", "SMMA");	
	indicator.parameters:addStringAlternative("MVAT_K" , "TMA", "", "TMA");	
	indicator.parameters:addStringAlternative("MVAT_K" , "VIDYA", "", "VIDYA");	
	indicator.parameters:addStringAlternative("MVAT_K" , "WMA", "", "WMA");	
    
    indicator.parameters:addString("MVAT_D", "Smoothing type for %D", "The type of smoothing algorithm for %D.", "MVA");
    indicator.parameters:addStringAlternative("MVAT_D", "MVA", "MVA", "MVA");
    indicator.parameters:addStringAlternative("MVAT_D", "EMA", "EMA", "EMA");
	indicator.parameters:addStringAlternative("MVAT_D" , "LWMA", "", "LWMA");	
	indicator.parameters:addStringAlternative("MVAT_D" , "KAMA", "", "KAMA");	
	indicator.parameters:addStringAlternative("MVAT_D" , "SMMA", "", "SMMA");	
	indicator.parameters:addStringAlternative("MVAT_D" , "TMA", "", "TMA");	
	indicator.parameters:addStringAlternative("MVAT_D" , "VIDYA", "", "VIDYA");	
	indicator.parameters:addStringAlternative("MVAT_D" , "WMA", "", "WMA");	
	
	indicator.parameters:addDouble("OB", "OB Level", "", 80);
    indicator.parameters:addDouble("OS", "OS Level", "", 20);
	

	
	indicator.parameters:addString("Type", "Currency pair Selector", "Currency pair Selector" ,"Multiple currency pair");
    indicator.parameters:addStringAlternative("Type", "Chart", "Chart" , "Chart");
    indicator.parameters:addStringAlternative("Type", "Multiple currency pair", "Multiple currency pair" , "Multiple currency pair");
	indicator.parameters:addStringAlternative("Type", "All currency pair", "All currency pair" , "All currency pair");
 
	
	

	for i= 1 ,20, 1 do
	indicator.parameters:addGroup(i..". Currency Pair ");
	Add(i);
	end
	
	
	
	AddTimeFrame (1 , "m1",false);
	AddTimeFrame (2 , "m5",false );
	AddTimeFrame (3 , "m15",false  );
	AddTimeFrame (4 , "m30",false   );
	AddTimeFrame (5 , "H1" ,true );
	AddTimeFrame (6 , "H2" ,false );
	AddTimeFrame (7 , "H3" ,false   );
	AddTimeFrame (8 , "H4" ,false );
	AddTimeFrame (9 , "H6" ,false   );
	AddTimeFrame (10 , "H8",true   );
    AddTimeFrame (11 , "D1" ,true  );
	AddTimeFrame (12 , "W1" ,true  );
	AddTimeFrame (13 , "M1" ,true );
 
	
	indicator.parameters:addGroup("Style");	 
	indicator.parameters:addColor("Color", "Label Color", "Label Color", core.rgb(0, 0, 0));
	indicator.parameters:addColor("Up", "Up Trend Color","", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Trend Color","", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral Trend Color","", core.rgb(0, 0, 255));  
 
	indicator.parameters:addInteger("transparency", "Fill Transparency", "0 - opaque, 100 - transparent", 70, 0, 100);
	indicator.parameters:addInteger("Size", "Font Size (As % of Cell)", "", 70 , 0, 100);
 
	


end

function AddTimeFrame(id , FRAME , DEFAULT ,Period1,Period2,Period3 )


    indicator.parameters:addGroup(id..". Time Frame Selector");	
 
	indicator.parameters:addBoolean("Use"..id , "Show "..  FRAME  , "", DEFAULT); 
	
	indicator.parameters:addString("TF"..id, "Time frame", "", FRAME);
    indicator.parameters:setFlag("TF"..id, core.FLAG_PERIODS);
	
 
end


function getInstrumentList()
    local list={};
	local point={};
	
    local count = 0;	
    local row, enum;	
	
    enum = core.host:findTable("offers"):enumerator();
    row = enum:next();
    while row ~= nil do
        count = count + 1;
        list[count] = row.Instrument;
		point[count] = row.PointSize;
        row = enum:next();
    end
	
	 
    return list, count,point;
end

 
function Add(id)

    local Init={"EUR/USD","USD/JPY", "GBP/USD","USD/CHF", "EUR/CHF"
	          , "AUD/USD","USD/CAD", "NZD/USD", "EUR/GBP", "EUR/JPY"
			  , "GBP/JPY", "CHF/JPY","GBP/CHF", "EUR/AUD", "EUR/CAD"	
              , "AUD/CAD", "AUD/JPY","CAD/JPY", "NZD/JPY", "GBP/CAD"					  
			  };
	
    if id <= 5 then	
	indicator.parameters:addBoolean("Dodaj"..id, "Use This Slot", "", true);		
    else
	indicator.parameters:addBoolean("Dodaj"..id, "Use This Slot", "", false);		
    end	
    indicator.parameters:addString("Pair" .. id, "Pair", "", Init[id]);
    indicator.parameters:setFlag("Pair" .. id, core.FLAG_INSTRUMENTS);
	
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Filter;
local Show; 
local iTF={"m1", "m5", "m15", "m30", "H1", "H2", "H3", "H4", "H6", "H8", "D1", "W1", "M1"}; 
local TF={};
local Period; 
local pauto =  "(%a%a%a)/(%a%a%a)";
local Color;
local Source={};
local Size;
local transparency; 
local loading={}; 
local source;
local Pair={};
local  Count; 
local Type;  
local Dodaj={};   
local Point={};
local Use={};
local Num;
local ShowCells;
local Up,  Down, Neutral;

local Indicator={}  


local Parameters={}; 
local Indicator={};
local One, Two, Three, Four, Five;

local k;
local d;
local sd;
local averageTypeK = nil;
local averageTypeD = nil;
local OB, OS;

-- Routine
function Prepare(nameOnly)
   
	Size= instance.parameters.Size;
	Type= instance.parameters.Type; 
	Up= instance.parameters.Up;
	Down= instance.parameters.Down;
	Neutral= instance.parameters.Neutral; 
	source = instance.source; 
	
	local name = profile:id() .. "("  .. tostring(source:barSize())  .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	One= instance.parameters.One;
	Two= instance.parameters.Two;
	Three= instance.parameters.Three;
	Four= instance.parameters.Four;
	Five= instance.parameters.Five;
	
	Parameters["DMI"] = instance.parameters.DMI;
	Parameters["ADX"] = instance.parameters.ADX;
	Parameters["ADX_Entry"] = instance.parameters.ADX_Entry;
	Parameters["ADX_Exit"] = instance.parameters.ADX_Exit;
	
	Parameters["CCI"] = instance.parameters.CCI;
	Parameters["CCI_Buy"] = instance.parameters.CCI_Buy;
	Parameters["CCI_Sell"] = instance.parameters.CCI_Sell;
	
	Parameters["MACD_Short"] = instance.parameters.MACD_Short;
	Parameters["MACD_Long"] = instance.parameters.MACD_Long;
	Parameters["MACD_Buy"] = instance.parameters.MACD_Buy;
	Parameters["MACD_Sell"] = instance.parameters.MACD_Sell;
	Parameters["MACD_Price"] = instance.parameters.MACD_Price;
	
	k = instance.parameters.K;
    d = instance.parameters.D;
    sd = instance.parameters.SD;
	
	averageTypeK = instance.parameters.MVAT_K;
    averageTypeD = instance.parameters.MVAT_D;
	
    OB = instance.parameters.OB;
    OS = instance.parameters.OS;
   
   
	
	if Type== "Multiple currency pair" then 
	
	Count=0;
				 for i= 1, 20 , 1 do	 
					 Dodaj[i]=instance.parameters:getBoolean("Dodaj" .. i);
					 if Dodaj[i] then					
					 Count=Count+1;
					 Pair[Count]=   instance.parameters:getString ("Pair"..i);	
					 Point[Count]= core.host:findTable("offers"):find("Instrument", Pair[Count]).PointSize;
					 end
				   
				 end
				 
	elseif Type== "All currency pair" then 
	
	
	          Pair, Count,Point = getInstrumentList();
				 
	else

	           Pair[1]=source:instrument();
			   Point[1]=source:pipSize ();
			   Count=1;
	end
	
	Num=0;
		for i = 1 , 13 , 1 do  
	
		   Use[i]=instance.parameters:getBoolean("Use" .. i);
		
		   if Use[i] then
			Num=Num+1;
			 
			TF[Num]=  iTF[i]; 
		   end
	   end
	   
	  assert(core.indicators:findIndicator("CONSENSUS OF FIVE") ~= nil, "Please, download and install CONSENSUS OF FIVE.LUA indicator"); 
 
	local ID=0;
	Color= instance.parameters.Color; 
	
	 
	  
	 for i = 1, Count, 1 do	
	 
	  Source[i] ={};
	  loading[i] ={};  
      Indicator[i]={};

      	  	  
		   for j = 1, Num, 1 do	
		    ID=ID+1;  
			
			Test1 =   core.indicators:create("CONSENSUS OF FIVE", source, One, Two, Three, Four, Five, Parameters["DMI"], Parameters["ADX"],Parameters["ADX_Entry"], Parameters["ADX_Exit"]
			,Parameters["CCI"], Parameters["CCI_Buy"],Parameters["CCI_Sell"], Parameters["MACD_Short"],Parameters["MACD_Long"],Parameters["MACD_Buy"],Parameters["MACD_Sell"],Parameters["MACD_Price"]
			, k, sd, d, averageTypeK,averageTypeD, OB, OS);
			first = (Test1.DATA:first() )*2;  
			
		   Source[i][j]= core.host:execute("getSyncHistory", Pair[i], TF[j], source:isBid(),math.min(300,first),20000 + ID , 10000 +ID);
		   loading [i][j]=true; 
		   Indicator[i][j] =   core.indicators:create("CONSENSUS OF FIVE", Source[i][j], One, Two, Three, Four, Five, Parameters["DMI"], Parameters["ADX"],Parameters["ADX_Entry"], Parameters["ADX_Exit"]
		   , Parameters["CCI"], Parameters["CCI_Buy"],Parameters["CCI_Sell"], Parameters["MACD_Short"],Parameters["MACD_Long"],Parameters["MACD_Buy"],Parameters["MACD_Sell"],Parameters["MACD_Price"]
		   , k, sd, d, averageTypeK,averageTypeD, OB, OS, Up, Down,Neutral);
		   end
	 end 
	  

    
	
	 
	 instance:ownerDrawn(true); 
	 core.host:execute ("setTimer", 1, 1);
   
end


function ReleaseInstance()
core.host:execute ("killTimer", 1);
end 



-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)


 local i ;
 local ID=0;
 
		 for i = 1, Count, 1 do	
		     for j = 1, Num, 1 do	
			  ID=ID+1;
			  if cookie == ( 10000 +  ID) then
			  loading[i][j] = true;
		      elseif  cookie == (20000+ ID) then
			  loading[i][j] = false;  
			  end
			  
		       end
          end

	
	
    local FLAG=false; 
	local Number=0;
	
	for i = 1, Count, 1 do
		 for j = 1, Num, 1 do

                 if loading [i][j] then
				 FLAG= true;
				 Number=Number+1;
				 end
		 
         end
    end
	
	if not FLAG and cookie== 1 then
		
		for i = 1, Count, 1 do 
			for j = 1, Num, 1 do 
			
			
					 if loading [i][j] then
					 Loading= true; 
					 else
					 Indicator[i][j]:update(core.UpdateLast);   
					 end
			end		 
		end
	end
	
	
	if FLAG then
	 core.host:execute ("setStatus", "  Loading "..(Count*Num - Number) .. " / " ..  Count*Num );	 
	else
	core.host:execute ("setStatus", "Loaded") 
	 instance:updateFrom(0);	
	end
   
        
    return core.ASYNC_REDRAW ;
end

local top, bottom;
local left, right;
local xGap;	 
local yGap;




-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period) 
	 
end


local init = false;
 
function Draw(stage, context)
    if stage~= 2 then
	 return;
	end
	
	 
	
	 local Loading=false; 
 
	
	for i = 1, Count, 1 do 
	    for j = 1, Num, 1 do 
		
		
                 if loading [i][j] then
				 Loading= true; 
				
				 end
		end		 
    end
	
	
	 if Loading then
           return;
     end
	 
	 
	
        if not init then
		
		    context:createPen(1, context.SOLID, 1, Color); 
            context:createSolidBrush(2, Color);           
            transparency = context:convertTransparency(instance.parameters.transparency);
						
            init = true;
        end
		
	    
		
    	
		left, right = context:left(), context:right();
		
	
		
		xGap=  (right-left)/(Num+1);	 
		yGap=  (context:bottom()-context:top())/(Count+2);
		
		top=context:top()+yGap;
		bottom=context:bottom();
 
				
 
		if xGap> 250 then
		xGap= 250;
		end
			   
		
		
		for i= 1, Count,1 do 	
			for j= 1, Num,1 do 	
			 Calculate (context,i, j);
		 
			end
		end
 
end	

 function Calculate (context,i, j )
   
        y1=bottom -(i)*yGap;		
		x1=left +(j-1)*xGap+xGap/2;
		 
		
		    iwidth = ((xGap/7)/100)*Size ;
			iheight=  (yGap/100)*Size;
			
			context:createFont (7, "Arial",iwidth, iheight , context.ITALIC);
			
	   	if j== 1 then 
		width, height = context:measureText (7, Pair[i], context.LEFT  ); 
		context:drawText (7,Pair[i], Color, -1, x1 -xGap/2, y1, x1+width-xGap/2,y1+height, context.LEFT   );	
		end
		
		
 	  
	    if i== Count then 
		width, height = context:measureText (7, TF[j], 0); 
		context:drawText (7,  TF[j], Color, -1, x1+xGap , y1-yGap,x1+xGap+width,  y1+height-yGap, context.CENTER   );	
		end
		
	 
     
	local Style=nil;
	period=Indicator[i][j].DATA:size()-1;
	
	if not Indicator[i][j].DATA:hasData(period) then
	return;
	end
	
    local SymbolColor=Indicator[i][j].DATA:colorI(period);	
	
	      	   if Indicator[i][j].DATA:colorI(period) == Up
			   then
			   	                         
											Style= "\225";
			   elseif Indicator[i][j].DATA:colorI(period) == Up 
			   and Indicator[i][j].DATA:colorI(period-1) ~= Up 
			   then					 
											Style= "\225" .. "\167";
				 elseif Indicator[i][j].DATA:colorI(period) == Down
				 then
											  							
												Style= "\226";	
				 elseif Indicator[i][j].DATA:colorI(period) == Down
				 and Indicator[i][j].DATA:colorI(period-1) ~= Down
				 then
											 								
												Style= "\226" .. "\167"; 									
												
						 else				
                                              Style= "\158";							 
								 
						 end 			
 
	
		context:createFont (8, "Wingdings",iwidth, iheight , context.CENTER  ); 
		if Style~= nil then
		 width, height = context:measureText (8, Style , context.CENTER  );  
		  context:drawText (8,  Style, SymbolColor, -1, x1+xGap , y1, x1+xGap+width  , y1+height, context.CENTER   );	
		end
 
	  
 end
 
 