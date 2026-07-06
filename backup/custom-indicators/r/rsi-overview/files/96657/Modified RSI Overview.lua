-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=61356

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
 
function Init()
    indicator:name("Modified RSI Overview");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);	

	
	indicator.parameters:addGroup("Selector");		 
	indicator.parameters:addBoolean("Show".. 1 , "Show RSI/OB/OS Filter"  , "", true); 
	indicator.parameters:addBoolean("Show".. 2 , "Show RSI/50 Filter"  , "", true); 
    indicator.parameters:addBoolean("Show".. 3 , "Show RSI/MA Filter"  , "", true); 	 
	
	indicator.parameters:addString("Y", " Y Placement","" , "Bottom");
    indicator.parameters:addStringAlternative("Y", "Top", "Top" , "Top");
    indicator.parameters:addStringAlternative("Y", "Bottom", "Bottom" , "Bottom"); 
	
	indicator.parameters:addString("X", " X Placement","" , "Right");
    indicator.parameters:addStringAlternative("X", "Right", "Right" , "Right");
    indicator.parameters:addStringAlternative("X", "Left", "Left" , "Left"); 
	
	Parameters (1 , "m1" , false ); 
	Parameters (2 , "m5" , false  );
	Parameters (3 , "m15",false   );
    Parameters (4 , "m30", false   );
	Parameters (5 , "H1" , true  );
	Parameters (6 , "H2" , false  ); 
	Parameters (7 , "H3" , false  );
	Parameters (8 , "H4" , false  );
    Parameters (9 , "H6" , false  );
	Parameters (10 , "H8", false   );
	Parameters (11 , "D1", true   ); 
	Parameters (12 , "W1", true   );
	Parameters (13 , "M1", true   );
 
 
	
	indicator.parameters:addGroup("Common Parameters");		 
	
	indicator.parameters:addDouble("xSize", "Cell Height as % of Screen Height", "", 5, 0, 100);
	indicator.parameters:addDouble("ySize", "Cell Width as % of Screen Width", "", 5, 0,100);
	
	indicator.parameters:addColor("BuyZone", "Buy Zone Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("SellZone", "Sell Zone Color", "", core.rgb(255, 0, 0));
 
 	indicator.parameters:addColor("UpTrend", "Up Trend Color", "", core.rgb(0, 255, 0));
 	indicator.parameters:addColor("DownTrend", "Down Trend Color", "", core.rgb(255, 0, 0));
	
	indicator.parameters:addColor("OBColor", "OB Color", "", core.rgb(255, 255, 0));
	indicator.parameters:addColor("OSColor", "OS Color", "", core.rgb(255, 128, 64));

	indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0));
	
end


function Parameters (id, Frame , On )
   
     indicator.parameters:addGroup(id..".  Time Frame"); 
    indicator.parameters:addBoolean("On"..id , "Show " .. Frame .. " time Frame"  , "", On); 
  
	indicator.parameters:addString("TF" .. id, id.. ". Time frame", "", Frame);
    indicator.parameters:setFlag("TF" .. id, core.FLAG_PERIODS);
    indicator.parameters:addInteger("Period"..id, "Period", "", 14);
	 indicator.parameters:addInteger("MAPeriod"..id, "MA Period", "", 5);
	  
end
 
 
local TF={};
local source; 
local day_offset, week_offset;
local host;
local first={}; 
local Show={};
local SourceData={};
local loading={};
local MAPeriod={};
local ma={};
local rsi={};
local Period={};

local SourceData = {};
local loading= {}; 
local ID;
local UpTrend, DownTrend, OBColor,OBColor, UpSlope,DownSlope, Label,NeutralSlope;
local Num;
local xSize, ySize;
local Y,X;
local xGap, yGap;
function Prepare(nameOnly) 

  	
    source = instance.source;	

     local name =  "(" .. profile:id() .. ","  .. instance.source:name().. ","  .. source:barSize().. ")"
	instance:name(name);
	if   (nameOnly) then
        return;
    end
	
    host = core.host;
	day_offset = host:execute("getTradingDayOffset");
    week_offset = host:execute("getTradingWeekOffset");
    UpTrend=instance.parameters.UpTrend;
	DownTrend=instance.parameters.DownTrend;
	OBColor=instance.parameters.OBColor;
	OSColor=instance.parameters.OSColor;
	BuyZone=instance.parameters.BuyZone;
	SellZone=instance.parameters.SellZone; 
	
	Y=instance.parameters.Y;
	X=instance.parameters.X;
	
	xSize=(instance.parameters.xSize/100);
	ySize=(instance.parameters.ySize/100);
	
	Label=instance.parameters.Label;
    Num=0;
	ID=0;
	
	Show[1]=  instance.parameters:getBoolean("Show".. 1);	   
	Show[2]=  instance.parameters:getBoolean ("Show".. 2);	   
	Show[3]=  instance.parameters:getBoolean ("Show".. 3);	   
	for i= 1, 13 ,  1 do
	  
	   
	    if  instance.parameters:getBoolean("On" .. i) then
	    Num=Num+1;
		Period[Num]=  instance.parameters:getInteger ("Period"..i);	    
		TF[Num]=  instance.parameters:getString ("TF"..i);	 
		MAPeriod[Num]=  instance.parameters:getString ("MAPeriod"..i);	 
		 ID=ID+1; 
      
        SourceData[Num] = core.host:execute("getSyncHistory", source:instrument(), TF[Num], source:isBid(),  math.min(300,    Period[Num]+MAPeriod[Num])   , 2000 + ID , 1000+ID);
        loading[Num] = true;  
		
		rsi[Num] = core.indicators:create("RSI", SourceData[Num].close ,Period[Num]);
		ma[Num] = core.indicators:create("MVA", rsi[Num].DATA ,MAPeriod[Num]); 
		end 
	   	
		
	end
		
   
	
	 instance:ownerDrawn(true); 
	      core.host:execute ("setTimer", 1, 1);
end

function ReleaseInstance()
core.host:execute ("killTimer", 1);
end 


function Update(period)

 
	  
end

 -- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)

    local ID=0;
	 
		 for i = 1, Num, 1 do
              ID=ID+1;
			   
			  if cookie == (1000 + ID) then
			  loading[i] = true;		
		      elseif  cookie == (2000 +ID) then 
			  loading[i] = false;    
			  end
		 
	end    
	
	
	local iNumber=0;
	local FLAG=true;
 
		 for i = 1, Num, 1 do
		 

                 if loading[i] then
				 FLAG= false;
				 iNumber=iNumber+1;
				 end
		 
       
    end
	
	if FLAG and cookie==1 then
	    for i = 1, Num, 1 do 
		
	 	 rsi[i]:update(core.UpdateLast);
 	 ma[i]:update(core.UpdateLast);
       end
   end
	
	if not FLAG then
	core.host:execute ("setStatus", "  Loading "..(  Num  - iNumber) .. " / " ..  Num );
    return;	
	else
	core.host:execute ("setStatus", "Loaded");	
	 instance:updateFrom(0);
	end
	 
	
 
	return core.ASYNC_REDRAW;
  
    
end


function iX(context,x, width)

	if X== "Left" then
	return  context:left()+xGap*(x)+width
	else
	return context:right()-xGap*(x)+width
	end
end



function iY(context,x, height)

	if Y== "Top" then
	return context:top()+yGap*(x)+height
	else
	return context:bottom()-yGap*(x)+height
	end
end


local init = false;
 
function Draw(stage, context)
    if stage~= 2 then
	 return;
	end
	
	 
	
	 local Loading=false; 
 
	
 
	    for i = 1, Num, 1 do 
		
	--	 rsi[i]:update(core.UpdateLast);
--		 ma[i]:update(core.UpdateLast);
                 if loading [i]   then
				 Loading= true; 
				 end
	 	 
     end
	
	
	 if Loading then
           return;
     end
	 
	 
	
        if not init then 
            init = true;
        end
		
	    
		
    	top, bottom = context:top(), context:bottom();
		left, right = context:left(), context:right();
		 
		 
		xGap=  (right-left)*xSize;	 
		yGap=  (bottom-top)*ySize;
		context:createFont (1, "Arial",xGap/12, yGap , context.ITALIC); 
		
		for i= 1, Num ,1 do
		 
		 if  rsi[i].DATA:hasData(rsi[i].DATA:size()-1)
		 and ma[i].DATA:hasData(ma[i].DATA:size()-1) 
		 then
		 width, height = context:measureText (1, TF[i] , context.ITALIC);   
		 context:drawText (1,  TF[i], Label, -1,  iX(context,i,0) , iY(context,1,0),  iX(context,i,width)  , iY(context,1, height), 0 );	
		  Shift=0;
		 if Show[1] then
			 if rsi[i].DATA[rsi[i].DATA:size()-1] > 70 then 
			 iLabel=  "Overbought";
			 Color=OBColor;
			 elseif rsi[i].DATA[rsi[i].DATA:size()-1] < 30 then
			 iLabel=  "Oversold"; 
			 Color=OSColor;
			 else
			 Color=Label;
			 iLabel=  ""; 
			 end
			 
			 
			 Shift=Shift+1;
		  width, height = context:measureText (1, iLabel , context.ITALIC);  
		  context:drawText (1,  iLabel, Color, -1,  iX(context,i,0) ,  iY(context,1+Shift,0)  , iX(context,i,width),   iY(context,1+Shift,height) , 0 );	
		  
		 end

         if  Show[2]	 then	 
		     if rsi[i].DATA[rsi[i].DATA:size()-1] > 50 then 
			 iLabel=  "Buy Zone";
			 Color=BuyZone;
			 elseif rsi[i].DATA[rsi[i].DATA:size()-1] < 50 then
			 Color=SellZone;
			 iLabel=  "Sell Zone"; 
			 else
			 Color=Label;
			 iLabel=  ""; 
			 end
			 
			 
			 Shift=Shift+1;
		  width, height = context:measureText (1, iLabel , context.ITALIC);  
		  context:drawText (1,  iLabel, Color, -1,  iX(context,i,0) ,  iY(context,1+Shift,0) , iX(context,i,width),iY(context,1+Shift,height), 0 );	
	
            end
			
			if Show[3] then
			
			 if rsi[i].DATA[rsi[i].DATA:size()-1] > ma[i].DATA[ma[i].DATA:size()-1] then 
			 iLabel=  "Up Trend";
			 Color=BuyZone;
			 elseif rsi[i].DATA[rsi[i].DATA:size()-1] <   ma[i].DATA[ma[i].DATA:size()-1] then
			 Color=SellZone;
			 iLabel=  "Down Trend"; 
			 else
			 Color=Label;
			 iLabel=  ""; 
			 end
			 
			 
			 Shift=Shift+1;
		  width, height = context:measureText (1, iLabel , context.ITALIC);  
		  context:drawText (1,  iLabel, Color, -1,  iX(context,i,0) ,  iY(context,1+Shift,0) ,iX(context,i,width),iY(context,1+Shift,height), 0 );	
		  end
		  end
		end		
end
