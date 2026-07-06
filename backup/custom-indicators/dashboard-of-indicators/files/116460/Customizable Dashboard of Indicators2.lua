-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61967

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
--|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
--+------------------------------------------------------------------+


-- Indicator profile initialization routine
-- Defines indicator profile properties and indicator parameters
-- TODO: Add minimal and maximal value of numeric parameters and default color of the streams
function Init()
    indicator:name("Dashboard of indicators");
    indicator:description("Dashboard of indicators");
     indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
  
  
    indicator.parameters:addGroup("Calculation"); 
	indicator.parameters:addString("Type", "Currency pair Selector", "Currency pair Selector" , "Chart");
    indicator.parameters:addStringAlternative("Type", "Chart", "Chart" , "Chart");
    indicator.parameters:addStringAlternative("Type", "Multiple currency pair", "Multiple currency pair" , "Multiple currency pair");
	indicator.parameters:addStringAlternative("Type", "All currency pair", "All currency pair" , "All currency pair");
 
	

	for i= 1 ,20, 1 do
	indicator.parameters:addGroup(i..". Currency Pair ");
	Add(i);
	end
	
	
	indicator.parameters:addGroup( "Indicator Selection");
	for i= 1 ,10, 1 do
	AddIndicator(i);
	end
	
	indicator.parameters:addGroup("Style");	 
	indicator.parameters:addColor("Color", "Label Color", "Label Color", core.rgb(0, 0, 0));
	indicator.parameters:addColor("Up", "Up Color","", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Color","", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral Color","", core.rgb(0, 0, 255));


    indicator.parameters:addDouble("minusX", "Vertical spacing", "", 10 , 0, 50);
	indicator.parameters:addDouble("minusY", "Horizontal spacing", "", 10 , 0, 50);
 
 
	indicator.parameters:addInteger("Size", "Font Size (As % of Cell)", "", 70 , 0, 100);
 


end

function GetShortPriceName(Str)
	return string.sub(Str, 1, 2);
end

function AddIndicator (id)
    indicator.parameters:addGroup(id.. ". Slot");	 
    indicator.parameters:addBoolean("On"..id , "Use this slot", "", true);	
    indicator.parameters:addString("Method"..id, "Indicator", "", "MVA");
    indicator.parameters:setFlag("Method"..id,core.FLAG_INDICATOR);  
    indicator.parameters:addString("Price"..id, "Price", "", "close");
    indicator.parameters:addStringAlternative("Price"..id, "close", "", "close");
    indicator.parameters:addStringAlternative("Price"..id, "open", "", "open");
    indicator.parameters:addStringAlternative("Price"..id, "high", "", "high");
    indicator.parameters:addStringAlternative("Price"..id, "low", "", "low");
    indicator.parameters:addStringAlternative("Price"..id, "median", "", "median");
    indicator.parameters:addStringAlternative("Price"..id, "typical", "", "typical");
    indicator.parameters:addStringAlternative("Price"..id, "weighted", "", "weighted");
end

function getInstrumentList()
    local list={};
	local point={};
	local precision={};
	
    local count = 0;	
    local row, enum;	
	
    enum = core.host:findTable("offers"):enumerator();
    row = enum:next();
    while row ~= nil do
        count = count + 1;
        list[count] = row.Instrument;
		point[count] = row.PointSize;
		precision[count] = row.Digits;
        row = enum:next();
    end
	
	 
    return list, count,point,precision;
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

local Method={};   
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
local Num; 
local Up,  Down,Neutral ;
local minusX, minusY;   

local Indicator={}; 
local iprofile = {};	
local iparams= {}; 

local Test={};
local tprofile = {};	
local tparams= {}; 
local Precision={};
local Max={};
-- Routine
function Prepare(nameOnly)   
    Color= instance.parameters.Color; 
	Size= instance.parameters.Size;
	Mode= instance.parameters.Mode;    
	Type= instance.parameters.Type;  
	Up= instance.parameters.Up;
	Down= instance.parameters.Down; 
	Neutral= instance.parameters.Neutral;
	minusX= (instance.parameters.minusX/100);
	minusY= (instance.parameters.minusY/100);
	source = instance.source; 
 
      local name = profile:id() .. "("  .. tostring(source:barSize())  .. ")";
    instance:name(name);
	if   (nameOnly) then
        return;
    end
  
	if Type== "Multiple currency pair" then 
	
	Count=0;
				 for i= 1, 20 , 1 do	 
					 Dodaj[i]=instance.parameters:getBoolean("Dodaj" .. i);
					 if Dodaj[i] then					
					 Count=Count+1;
					 Pair[Count]=   instance.parameters:getString ("Pair"..i);	
					 Point[Count]= core.host:findTable("offers"):find("Instrument", Pair[Count]).PointSize;
					 Precision[Count]= core.host:findTable("offers"):find("Instrument", Pair[Count]).Digits;
					 end
				   

				 end
				 
	elseif Type== "All currency pair" then 
	
	
	          Pair, Count,Point,Precision = getInstrumentList();
				 
	else

	           Pair[1]=source:instrument();
			   Point[1]=source:pipSize ();
			   Precision[1]=source:getPrecision();
			   Count=1;
	end 
	
	
	local first =  source:first(); 
	
	
	
	
	Num=0;
	  
	for i = 1, 10, 1 do	

	            if instance.parameters:getBoolean ("On"..i) then
				
				Num=Num+1;
				
				        Method[Num]=  instance.parameters:getString ("Method"..i);
	
					   tprofile[Num] = core.indicators:findIndicator(instance.parameters:getString("Method"..i));
					   tparams[Num] = instance.parameters:getCustomParameters("Method"..i);
					   
					   if  tprofile[Num]:requiredSource() == core.Tick then
					   Test[Num] = tprofile[Num]:createInstance(source[instance.parameters:getString("Price"..i)], tparams[Num]);
					   else
					   Test[Num] = tprofile[Num]:createInstance(source, tparams[Num]);
					   end  
					   
					   Max[Num] = Test[Num]:getStreamCount ();
					   first= math.max(first, Test[Num]:getStream(Max[Num]-1):first());	
					   
	            end
	end
		
	
	 for i = 1, Count, 1 do	
	  
	  Indicator[i]={};
	  iprofile[i]={};
	  iparams[i]={};
	  
	  
	  Source[i]= core.host:execute("getSyncHistory", Pair[i], source:barSize(), source:isBid(),first*2+1,20000 + i , 10000 +i);
	  loading [i]=true;
	  
	         iNum =0;
			 
			    for j= 1 , 10, 1 do
					  if instance.parameters:getBoolean ("On"..j) then						
						iNum=iNum+1;						 
			
							   iprofile[i][iNum] = core.indicators:findIndicator(instance.parameters:getString("Method"..j));
							   iparams[i][iNum] = instance.parameters:getCustomParameters("Method"..j);
							   
							   if  iprofile[i][iNum]:requiredSource() == core.Tick then
							   Indicator[i][iNum] = iprofile[i][iNum]:createInstance(Source[i][instance.parameters:getString("Price"..i)], iparams[i][iNum]);
							   else
							   Indicator[i][iNum] = iprofile[i][iNum]:createInstance(Source[i], iparams[i][iNum]);
							   end  
							   
							   
							   
						end
	  	    
		   	 end	   
		
	 end 
	  

 
	 
	 instance:ownerDrawn(true); 
   
end



-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)


 local i ;
 
 
		 for i = 1, Count, 1 do	
		     
			  if cookie == ( 10000 +  i) then
			  loading[i]  = true;
		      elseif  cookie == (20000+ i) then
			  loading[i]  = false;  
			  end
			  
		      
          end

	
	
    local FLAG=false; 
	local Number=0;
	
	for i = 1, Count, 1 do
		 

                 if loading [i] then
				 FLAG= true;
				 Number=Number+1;
				 end
		 
       
    end
	
	if FLAG then
	 core.host:execute ("setStatus", "  Loading "..(Count - Number) .. " / " ..  Count );	 
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
function Update(period,mode) 
	 
 end


local init = false;
 
function Draw(stage, context)
    if stage~= 2 then
	 return;
	end
	
	 local Loading=false; 
	
	 
	 for i= 1, Count,1 do 		
                 if loading [i] then
				 Loading= true; 
				 end		  
    end
	
	
	 if Loading then
           return;
     end
	 
	 
	
        if not init then
	
			
			 context:createPen(11, context.SOLID, 1, Up); 
            context:createSolidBrush(12, Up);
			
			 context:createPen(21, context.SOLID, 1, Down); 
            context:createSolidBrush(22, Down);
		 		 			
            init = true;
        end
		
	    
		
    	top, bottom = context:top(), context:bottom();
		left, right = context:left(), context:right();
		
	
		
		xGap=  (right-left)/(Num+1);	 
		yGap=  (bottom-top)/(Count+1);
				
 
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
   
     
	Indicator[i][j]:update(core.UpdateLast); 
	  
     if    not   Indicator[i][j]:getStream(Max[j]-1):hasData(Indicator[i][j]:getStream(Max[j]-1):size()-2)  
     then
     return;
     end
	 
	
	     y1=bottom -(i+1)*yGap;
		y2=bottom -(i )*yGap;
	 
		
		x1=right -(j+1)*xGap;
		x2=right -(j )*xGap;
		
		iwidth = ((xGap/10)/100)*Size ;
		iheight= ((yGap/100)*Size);
		
		context:createFont (8, "Arial",iwidth, iheight , 0);
	
	 
		
		if j== Num then 
		width, height = context:measureText (8, Pair[i] .. "(" .. GetShortPriceName(instance.parameters:getString("Price"..i)) .. ")", context.CENTER  ); 
		context:drawText (8, Pair[i] .. "(" .. GetShortPriceName(instance.parameters:getString("Price"..i)) .. ")", Color, -1, x1, y1+yGap , x2, y1+height+yGap, context.CENTER, 0);
		end
		
		
 	  
	    if i== Count then 
		width, height = context:measureText (8, Method[j], 0); 
		context:drawText (8,  Method[j], Color, -1, x1+xGap , y1,x2+xGap,  y2, context.CENTER   );	
		end
        
		
		 iwidth = ((xGap/10)/100)*Size ;
		iheight= ((yGap/100)*Size)/Max[j];
		
	
		context:createFont (7, "Arial",iwidth, iheight , 0);

		
		
			   for k=1, Max[j], 1 do
			   
					Value = Indicator[i][j]:getStream(k-1)[Indicator[i][j]:getStream(k-1):size()-1]
					
					if  Max[j] == 1 then
					Value=   string.format("%." .. Precision[i] .. "f", Value); 
					else
					Value= tostring(k) .. ":".. string.format("%." .. Precision[i] .. "f", Value); 
					end
					
						width, height = context:measureText (7, Value, context.CENTER  ); 
					 
					if  Indicator[i][j]:getStream(k-1)[Indicator[i][j]:getStream(k-1):size()-1] > Indicator[i][j]:getStream(k-1)[Indicator[i][j]:getStream(k-1):size()-2] then					  
					context:drawText (7, Value, Up, -1, x1+xGap, y1+iheight*(k-1)+yGap, x1+xGap+width,  y1+iheight*(k-1)+yGap +height, context.CENTER); 
					elseif  Indicator[i][j]:getStream(k-1)[Indicator[i][j]:getStream(k-1):size()-1] < Indicator[i][j]:getStream(k-1)[Indicator[i][j]:getStream(k-1):size()-2] then
					context:drawText (7, Value, Down,  -1, x1+xGap, y1+iheight*(k-1)+yGap, x1+xGap+width,  y1+iheight*(k-1)+yGap +height, context.CENTER); 
					else		
					context:drawText (7, Value, Neutral,  -1, x1+xGap, y1+iheight*(k-1)+yGap, x1+xGap+width,  y1+iheight*(k-1)+yGap +height, context.CENTER); 
					end		
			   
			   end

 end
 
 
 