-- Id: 16918
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=64034&p=108827#p108827

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
    indicator:name("Top 8 Trenders Indicator");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);

	
	indicator.parameters:addGroup("Time Frame Selector");
    Add(1, "Chart");
	Add(2, "D1");
	
	indicator.parameters:addGroup("Currency Pair Selector");
	for i= 1 , 8 , 1 do
	AddPair(i);
	end
	
	 
	indicator.parameters:addGroup("Placement");
	indicator.parameters:addString("Y", " Y Placement","" , "Top");
    indicator.parameters:addStringAlternative("Y", "Top", "Top" , "Top");
    indicator.parameters:addStringAlternative("Y", "Bottom", "Bottom" , "Bottom"); 
	
	indicator.parameters:addString("X", " X Placement","" , "Left");
    indicator.parameters:addStringAlternative("X", "Right", "Right" , "Right");
    indicator.parameters:addStringAlternative("X", "Left", "Left" , "Left"); 
    indicator.parameters:addInteger("ShiftY", "Shift","" , 0);
 
	
	indicator.parameters:addGroup("Style");
   indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0)); 
 --  indicator.parameters:addInteger("Size", "Font Size", "", 20);
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
    
	
end

function AddPair(id)

    local PairInit={"EUR/USD","USD/JPY", "GBP/USD","USD/CHF", "EUR/CHF"
	          , "AUD/USD","USD/CAD", "NZD/USD", "EUR/GBP", "EUR/JPY"
			  , "GBP/JPY", "CHF/JPY","GBP/CHF", "EUR/AUD", "EUR/CAD"	
              , "AUD/CAD", "AUD/JPY","CAD/JPY", "NZD/JPY", "GBP/CAD"					  
			  };
	
    
    indicator.parameters:addString("Pair" .. id, id.. ". Pair", "", PairInit[id]);
    indicator.parameters:setFlag("Pair" .. id, core.FLAG_INSTRUMENTS);
	
	
end



function Add(id, TF)

    
    indicator.parameters:addGroup(id .. ". Time Frame");	
    indicator.parameters:addBoolean("On"..id, "Use Time Frame", "", true);
	indicator.parameters:addString("TF"..id, "Time frame", "", TF);
	local iTF={"Chart", "m1", "m5", "m15", "m30", "H1", "H2", "H3", "H4", "H6", "H8", "D1","W1", "M1"};
	for i= 1, 14, 1  do
	indicator.parameters:addStringAlternative("TF"..id, iTF[i], iTF[i] , iTF[i]);
	end 
	 
	 

	  indicator.parameters:addString("Price"..id, "Price Source", "", "close");
    indicator.parameters:addStringAlternative("Price"..id, "OPEN", "", "open");
    indicator.parameters:addStringAlternative("Price"..id, "HIGH", "", "high");
    indicator.parameters:addStringAlternative("Price"..id, "LOW", "", "low");
    indicator.parameters:addStringAlternative("Price"..id,"CLOSE", "", "close");
    indicator.parameters:addStringAlternative("Price"..id, "MEDIAN", "", "median");
    indicator.parameters:addStringAlternative("Price"..id, "TYPICAL", "", "typical");
    indicator.parameters:addStringAlternative("Price"..id, "WEIGHTED", "", "weighted");	
  
  
    indicator.parameters:addInteger("Period"..id, "Period", "Period", 20); 
	
	indicator.parameters:addString("Method"..id, "MA Method", "Method" , "MVA");
    indicator.parameters:addStringAlternative("Method"..id, "MVA", "MVA" , "MVA");
    indicator.parameters:addStringAlternative("Method"..id, "EMA", "EMA" , "EMA");
     indicator.parameters:addStringAlternative("Method"..id, "LWMA", "LWMA" , "LWMA");
    indicator.parameters:addStringAlternative("Method"..id, "TMA", "TMA" , "TMA");
    indicator.parameters:addStringAlternative("Method"..id, "SMMA", "SMMA" , "SMMA");
    indicator.parameters:addStringAlternative("Method"..id, "KAMA", "KAMA" , "KAMA");
    indicator.parameters:addStringAlternative("Method"..id, "VIDYA", "VIDYA" , "VIDYA");
    indicator.parameters:addStringAlternative("Method"..id, "WMA", "WMA" , "WMA");
  
	indicator.parameters:addBoolean("Use_ATR"..id, "Use ATR", "", false);
	indicator.parameters:addInteger("ATR_Period"..id, "ATR Period", "Period", 20); 
	
	indicator.parameters:addInteger("Lookback"..id, "Lookback Period", "Period", 20); 
 
   
end 



-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block

local first;
local source = nil;
local X,Y;
local font;
local Label;
--local Size;
local ShiftY;


 
local Source ={};

local  TF={}; 
local first;
local source = nil;
local loading={}; 
local Indicator={};
   
local Count=8;
local Number;
local Point={};
local Pair={};
local ATR_Period={};
local Data1={};
local Data2={};
local Lookback={};
local Period={};
local Method={};
local Price={};
local ATR={};
local Index1, Index2;
local Precision={};
-- Routine
function Prepare(nameOnly)
    Y=instance.parameters.Y;
	X=instance.parameters.X;  
	ShiftY=instance.parameters.ShiftY;
    Label=instance.parameters.Label;
	--Size=instance.parameters.Size;   
    source = instance.source;
    first=source:first();
	
	 
	
    local name = profile:id() .. "(" .. source:name() .. ")";
	instance:name(name);
	if nameOnly then
		return;
	end
   	
    instance:ownerDrawn(true);
	
	
	Number=0;
	
	local i;
	
	   
		       for  i = 1, 2, 1 do
				 if instance.parameters:getBoolean ("On"..i) then
				 Number=Number+1; 
				 TF[Number]= instance.parameters:getString("TF" .. i);
				 
				 if TF[Number]=="Chart" then
				 TF[Number]=source:barSize();
				 end
			 
				   Period[Number]=   instance.parameters:getInteger("Period" .. i);
	               Method[Number]=  instance.parameters:getString("Method" .. i);
	               Price[Number]=   instance.parameters:getString("Price" .. i);
                   ATR_Period[Number]=  instance.parameters:getInteger("ATR_Period" .. i);
				   Lookback[Number]=  instance.parameters:getInteger("Lookback" .. i);
				   
		       end
	end
	
 
	
	for i= 1,Count , 1 do
	 Pair[i]=   instance.parameters:getString ("Pair"..i);	
	 Point[i]= core.host:findTable("offers"):find("Instrument", Pair[i]).PointSize;
	 
     end
	 
	 
	 	
	local ID=0;	  
	 for i = 1, Count, 1 do	
	 
	  Source[i] ={};
	  loading[i] ={};  
      Indicator[i]={};
      ATR[i]={};
      	  	  
		   for j = 1, Number, 1 do	
		    ID=ID+1;  
			
			Temp= core.indicators:create("MVA", source.close ,Period[j] );
			first =  Temp.DATA:first()*2;  
		   Source[i][j]= core.host:execute("getSyncHistory", Pair[i], TF[j], source:isBid(),math.max(first+ Lookback[j], 300),20000 + ID , 10000 +ID);
		   Precision[i]=  Source[i][j]:getPrecision ();
		   loading [i][j]=true;
		   
    assert(core.indicators:findIndicator(Method[j]) ~= nil, Method[j] .. " indicator must be installed");
		   Indicator [i][j]= core.indicators:create(Method[j], Source[i][j][Price[j]], Period[j]);
		   ATR [i][j]= core.indicators:create("ATR", Source[i][j], ATR_Period[j]);
		    		  
		   end
	 end 
	 
end

 function ReleaseInstance()
core.host:execute ("killTimer", 3000);
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
 
function Update(period)   



  
end
 
 
 
function Draw(stage, context)
 
	  if stage~= 2 then
	  return;
	  end
	  
	  
	 local Loading=false; 
 
	
	for i = 1, Count, 1 do 
	    for j = 1, Number, 1 do 
	
                 if loading [i][j] then				 
				 Loading= true; 
				 else
				 Indicator[i][j]:update(core.UpdateLast);
                 ATR[i][j]:update(core.UpdateLast);    
				 end
		end		 
    end
	
	
	 if Loading then
           return;
     end
	 
	  
	  
 
		
					 
				for i = 1, Count, 1 do 
					for j = 1, Number, 1 do 					
					

						if j== 1 then
							if instance.parameters:getBoolean("Use_ATR" .. j) then
							Data1[i]=(Indicator[i][j].DATA[Indicator[i][j].DATA:size()-1]-Indicator[i][j].DATA[Indicator[i][j].DATA:size()-1-Lookback[j]])/ ATR[i][j].DATA[ATR[i][j].DATA:size()-1];
							else
							Data1[i]=(Indicator[i][j].DATA[Indicator[i][j].DATA:size()-1]-Indicator[i][j].DATA[Indicator[i][j].DATA:size()-1-Lookback[j]])/Point[i];
							end
						elseif j== 2 then
						    if  instance.parameters:getBoolean("Use_ATR" .. j) then
							Data2[i]=(Indicator[i][j].DATA[Indicator[i][j].DATA:size()-1]-Indicator[i][j].DATA[Indicator[i][j].DATA:size()-1-Lookback[j]])/ ATR[i][j].DATA[ATR[i][j].DATA:size()-1];
							else
					    	Data2[i]=(Indicator[i][j].DATA[Indicator[i][j].DATA:size()-1]-Indicator[i][j].DATA[Indicator[i][j].DATA:size()-1-Lookback[j]])/Point[i];
							end
						end 
  					
					end		 
					
				end
	 		 
     Index1=AKeyOf(Data1);
	 if Number== 2 then
	 Index2=AKeyOf(Data2);		
     end	 
	
	hSize =( (context:right ()-context:left ())/ (Number*2*2.5))/9;
	vSize =( (context:bottom ()-context:top ())/ (16));
	
       
     context:createFont (1, "Arial", hSize, vSize, 0);
         
       
		
	local Text1;
	local Shift;
	for i= 1, Count, 1 do
	   for j= 1, Number, 1 do
	   
			if j== 1 then
			Master=Index1;
			Raw=Data1;
			Shift=0;
			elseif j== 2 then
			Master=Index2;
			Raw=Data2;
			Shift=2;
			end
		
		Text1=  Pair[Master[i]];
        Text2=  Raw[Master[i]];
		Text2= win32.formatNumber(Text2, false, Precision[Master[i]]); 
		
		width, height = context:measureText (1, Text1, 0);
		Width= (context:right ()-context:left ())/(math.max(Number, 4));
	   context:drawText (1,  Text1, Label, -1,  iX(context,Width,0,1+Shift) ,  iY(context,height,i,0) ,iX(context,Width,0,2+Shift),iY(context,height,i,1), 0 );	
	   
	    width, height = context:measureText (1, Text2, 0);
		context:drawText (1,  Text2, Label, -1,  iX(context,Width,0,2+Shift) ,  iY(context,height,i,0) ,iX(context,Width,0,3+Shift),iY(context,height,i,1), 0 );

        if i== Count then
		Text3= TF[j];
        width, height = context:measureText (1, Text3, 0);
		context:drawText (1,  Text3, Label, -1,  iX(context,Width,0,2+Shift) ,  iY(context,height,i+1,0) ,iX(context,Width,0,3+Shift),iY(context,height,i+1,1), 0 );	  		
        end
		
       end
   end

end		
 
function AKeyOf(Array)

  local Index={1,2,3,4,5,6,7,8};
  
      for j = 1, 8 , 1 do 
        for i = 1, 7 , 1 do 
		
             if Array[Index[i]] < Array[Index[i+1]]   then
			 tempindex= Index[i];
			 Index[i]=Index[i+1];
			 Index[i+1]= tempindex;
			 end  
                         
                   
        end      
      end
 
  
   
   return Index;
end		

function iX(context, width,iShift,x)

	if X== "Left" then
	return  context:left()+ iShift*width +  width*(x-1) ;
	else
	return context:right() - width*iShift -  width*(1-(x-1));
	end
end



function iY(context, height,Index , Line)

	if Y== "Top" then
		return context:top()+Index*height +ShiftY*height + Line *height;
	else
		if Line== 1 then
		return context:bottom()-(Index+1)*height -ShiftY*height + height;
		else
		return context:bottom()-(Index+1)*height -ShiftY*height;
		end
	end
end


-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)
    
	   
					 local i ;
			 local ID=0;
			 
					 for i = 1, Count, 1 do	
						 for j = 1, Number, 1 do	
						  ID=ID+1;
						  if cookie == ( 10000 +  ID) then
						  loading[i][j] = true;
						  elseif  cookie == (20000+ ID) then
						  loading[i][j] = false;  
						  end
						  
						   end
					  end

				
				
				local FLAG=false; 
				local iNumber=0;
				
				for i = 1, Count, 1 do
					 for j = 1, Number, 1 do

							 if loading [i][j] then
							 FLAG= true;
							 iNumber=iNumber+1;
							 end
					 
					 end
				end
				
				if FLAG then
				 core.host:execute ("setStatus", "  Loading "..(Count*Number - iNumber) .. " / " ..  Count*Number );	 
				else
				core.host:execute ("setStatus", "Loaded") 
				 instance:updateFrom(0);	
				end
			    
		
		
		return core.ASYNC_REDRAW ;
	 
end
			  
 



 