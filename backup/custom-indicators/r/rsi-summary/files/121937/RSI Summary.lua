-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=28&t=61403&p=121938#p121938

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
 
function Init()
    indicator:name("RSI Summary");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);
	
	
   indicator.parameters:addGroup("Calulation");
   indicator.parameters:addInteger("Period", "Period","", 14);
    indicator.parameters:addInteger("Delta", "Delta","", 10);
	indicator.parameters:addDouble("OBL", "OB Level","", 70);
	indicator.parameters:addDouble("OSL", "OS Level","", 30);
   
   
   indicator.parameters:addString("Type", "Currency pair Selector", "Currency pair Selector" , "Multiple currency pair");
    indicator.parameters:addStringAlternative("Type", "Chart", "Chart" , "Chart");
    indicator.parameters:addStringAlternative("Type", "Multiple currency pair", "Multiple currency pair" , "Multiple currency pair");

	
	for i= 1 ,10, 1 do
	indicator.parameters:addGroup(i..". Currency Pair ");
	Add(i);
	end
	
	
    indicator.parameters:addGroup("Style");	 
	indicator.parameters:addColor("Color", "Label Color", "Label Color", core.rgb(0, 0, 0)); 
	indicator.parameters:addInteger("LabelHeight", "Label Height ", "", 20);
	
	 
    
    indicator.parameters:addGroup("OB/OS Style");	
	
	indicator.parameters:addInteger("width1", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style1", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style1", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("OB", "OB Color", "OB Color", core.rgb(0, 0, 255)); 
	indicator.parameters:addColor("OS", "OS Color", "OS Color", core.rgb(0, 0, 255)); 
	indicator.parameters:addColor("CL", "Central Line Color", "Down Color", core.rgb(0, 0, 255)); 	
    indicator.parameters:addGroup("RSI Style");	
	
	indicator.parameters:addInteger("width2", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style2", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style2", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("UpColor", "Up Color", "Up Color", core.rgb(0, 255, 0)); 
	indicator.parameters:addColor("DownColor", "Down Color", "Down Color", core.rgb(255, 0, 0)); 

	
	 
end 

function Add(id)

    local Init={"EUR/USD","USD/JPY", "GBP/USD","USD/CHF", "EUR/CHF"
	          , "AUD/USD","USD/CAD", "NZD/USD", "EUR/GBP", "EUR/JPY"
			  , "GBP/JPY", "CHF/JPY","GBP/CHF", "EUR/AUD", "EUR/CAD"	
              , "AUD/CAD", "AUD/JPY","CAD/JPY", "NZD/JPY", "GBP/CAD"					  
			  };
	
    if id <= 10 then	
	indicator.parameters:addBoolean("Dodaj"..id, "Use This Slot", "", true);		
    else
	indicator.parameters:addBoolean("Dodaj"..id, "Use This Slot", "", false);		
    end	
    indicator.parameters:addString("Pair" .. id, "Pair", "", Init[id]);
    indicator.parameters:setFlag("Pair" .. id, core.FLAG_INSTRUMENTS);
	

end

 
local Period; 
local Indicator={}
local Source={};
local loading={};
local Type;
local Count;
local Pair={};
local Point={};
local Color, LabelHeight;
local Delta;
local transparency;

local min={};
local max={};

 function Prepare(nameOnly)   
 
 
    Period=instance.parameters.Period;
	Delta=instance.parameters.Delta;
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. "," ..  Period .. "," ..  Delta .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	Type= instance.parameters.Type;
    Color= instance.parameters.Color;
	LabelHeight= instance.parameters.LabelHeight;

    dayoffset = core.host:execute("getTradingDayOffset");
    weekoffset = core.host:execute("getTradingWeekOffset");
	
	source = instance.source;
	
  
	if Type== "Multiple currency pair" then 
	
	Count=0;
				 for i= 1, 20 , 1 do	 
					 
					 if instance.parameters:getBoolean("Dodaj" .. i) then		                     					 
					 Count=Count+1;
					 Pair[Count]=   instance.parameters:getString ("Pair"..i);	
					 Point[Count]= core.host:findTable("offers"):find("Instrument", Pair[Count]).PointSize;		
					 end
				 
				 end
				 
					 
	else 
	
	        

	           Pair[1]=source:instrument();
			   Point[1]=source:pipSize ();
			   Count=1; 
			   
			  
	end

 
    source = instance.source;	
	 
	
  -- UpUp=instance.parameters.UpUp;
 
   
    for i = 1, Count, 1 do	

      Source[i]= core.host:execute("getSyncHistory", Pair[i], source:barSize(), source:isBid(), math.min(300, (Period+Delta)*2) ,20000 + i , 10000 +i);
	  Indicator[i] = core.indicators:create("RSI", Source[i].close ,  Period);
	  loading[i] = true;  
	  

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
 
 
		 for i = 1, Count, 1 do	
			  if cookie == ( 10000 +  i) then
			  loading[i] = true;
		      elseif  cookie == (20000+ i) then
			  loading[i] = false;           
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
	
	
	 if not FLAG and cookie== 1 then
		for i= 1, Count , 1 do
			  Indicator[i]:update(core.UpdateLast );
		end
		
	end
	
	if FLAG then
	 core.host:execute ("setStatus", "  Loading "..(Count  - Number) .. " / " ..  Count  );	 
	else
	core.host:execute ("setStatus", "Loaded");
	 instance:updateFrom(0);		
	end
   
        
    return core.ASYNC_REDRAW ;
end




function Update(period, mode)

    local FLAG=false; 
   	for i = 1, Count, 1 do
		 

                 if loading [i] then
				 FLAG= true; 
				 end
				 
				 
         
    end
	
	
	if FLAG  then
	return;
	end
	
	local p;
	
	for i = 1, Count, 1 do 	

            p=  Indicator[i].DATA:size()-1;
			
            if p > Delta*2
			and Indicator[i].DATA:hasData(p-Delta+1)
			and Indicator[i].DATA:hasData(p)
			then
			 
			    Min, Max= mathex.minmax(Indicator[i].DATA, p-Delta+1, p );
			    min[i] = Min;
			    max[i] = Max;				
			end
		 
	end
	 
	
end

local init = false;

function Draw (stage, context)

    if stage  ~= 0 then
	return;
	end
	 
	 
	  local Loading=false; 
 
	
	for i = 1, Count, 1 do 
		if loading [i] 
		or  not Indicator[i].DATA:hasData(Indicator[i].DATA:size()-1) 
		or not Indicator[i].DATA:hasData(Indicator[i].DATA:size()-1 -Delta+1)
		then
		Loading= true; 
		end 
	
    end
	
	
	 if Loading then
         return;
     end
	 
 

 
	 
    iHeight=((context:bottom()-context:top())/(Count));
    context:setClipRectangle(context:left(), context:top(), context:right(), context:bottom());
   
        if not init then
		
		     transparency=context:convertTransparency (0);
		     context:createPen (12, context:convertPenStyle (instance.parameters.style1),  context:pointsToPixels(instance.parameters.width1), instance.parameters.OB)       
		       context:createPen (13, context:convertPenStyle (instance.parameters.style1), context:pointsToPixels(instance.parameters.width1), instance.parameters.OS)    
		       context:createPen (14, context:convertPenStyle (instance.parameters.style1), context:pointsToPixels(instance.parameters.width1), instance.parameters.CL) 
   			   
			   context:createPen (2, context:convertPenStyle (instance.parameters.style2), context:pointsToPixels(instance.parameters.width2), instance.parameters.UpColor)    
               context:createSolidBrush (3, instance.parameters.UpColor)			   
		       context:createPen (4, context:convertPenStyle (instance.parameters.style2), context:pointsToPixels(instance.parameters.width2), instance.parameters.DownColor)    
               context:createSolidBrush (5, instance.parameters.DownColor)		
			   
		     context:createFont (11, "Arial", context:pointsToPixels( LabelHeight),context:pointsToPixels( LabelHeight) , context.CENTER);
            init = true;
        end
     
	 
	 
        
      
	   for i= 1, Count,1 do
	   
	        width, height = context:measureText (11,  Pair[i], 0);
			 context:drawText (11, Pair[i], Color, -1, context:left() , context:top()+height*(i), context:left() +width ,context:top()+height*(i+1)+ height, context.CENTER );   
									

           X1=context:left() +width;
           X2=context:right();
		   
            if Indicator[i].DATA[Indicator[i].DATA:size()-1] > Indicator[i].DATA[Indicator[i].DATA:size()-1 -Delta+1] then		 
			context:drawRectangle (2, 3, X1+((X2-X1)/100)*Indicator[i].DATA[Indicator[i].DATA:size()-1] , context:top()+height* i, X1+((X2-X1)/100)*Indicator[i].DATA[Indicator[i].DATA:size()-1 -Delta+1], context:top()+height* i+height/2 , transparency)	   
			context:drawLine (2, X1+((X2-X1)/100)*min[i],  context:top()+height* i +height /4 ,X1+((X2-X1)/100)* max[i], context:top()+height* i +height /4 );
			
		   else 
		   context:drawRectangle (4, 5, X1+((X2-X1)/100)*Indicator[i].DATA[Indicator[i].DATA:size()-1] , context:top()+height* i, X1+((X2-X1)/100)*Indicator[i].DATA[Indicator[i].DATA:size()-1 -Delta+1], context:top()+height* i+height/2, transparency )	
	       context:drawLine (4, X1+((X2-X1)/100)*min[i],  context:top()+height* i +height /4 ,X1+((X2-X1)/100)* max[i], context:top()+height* i +height /4 );		   
		   end
		   
 		
           if i == Count then        
          		  
		   
		   context:drawLine (12, X1+((X2-X1)/100)*instance.parameters.OBL,  context:top(),X1+((X2-X1)/100)*instance.parameters.OBL, context:top()+height* i );
		   context:drawLine (13, X1+((X2-X1)/100)*instance.parameters.OSL , context:top(), X1+((X2-X1)/100)*instance.parameters.OSL , context:top()+height* i );
		   context:drawLine (14, X1+((X2-X1)/100)*50 , context:top(), X1+((X2-X1)/100)*50 , context:top()+height* i );
		   
		   
		   
		    width, height = context:measureText (11,  instance.parameters.OBL, 0);
			context:drawText (11, instance.parameters.OBL , Color, -1, X1+((X2-X1)/100)*instance.parameters.OBL , context:top()+height* i , X1+((X2-X1)/100)*instance.parameters.OBL +width ,context:top()+height* i + height, context.CENTER ); 
			
			
			width, height = context:measureText (11,  instance.parameters.OSL, 0);
			context:drawText (11, instance.parameters.OSL , Color, -1, X1+((X2-X1)/100)*instance.parameters.OSL , context:top()+height* i , X1+((X2-X1)/100)*instance.parameters.OSL +width ,context:top()+height* i + height, context.CENTER ); 
		   
		   end		   
	   end
			
				 
				
	
end

