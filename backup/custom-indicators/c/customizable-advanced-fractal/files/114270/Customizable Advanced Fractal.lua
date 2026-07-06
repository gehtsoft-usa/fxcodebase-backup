-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=65002
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
    indicator:name("Customizable Advanced  Fractal");
    indicator:description("Predicts a reversal in the current trend.");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
	
	
	indicator.parameters:addInteger("Left", "Number of fractals on Left", "Number of fractals", 2, 1,1000);
	indicator.parameters:addInteger("Central", "Number of fractal Central", "Number of fractals", 2, 1,1000);
    indicator.parameters:addInteger("Right", "Number of fractals on Right", "Number of fractals", 2, 1,1000);

    indicator.parameters:addColor("UP", "Up fractal color", "Up fractal color", core.rgb(0,255,0));
    indicator.parameters:addColor("DOWN", "Down fractal color", "Down fractal color", core.rgb(255,0,0));
	
	indicator.parameters:addColor("Unconfirmed_Up", "Unconfirmed Up fractal color", "Up fractal color", core.rgb(0,0,255));
    indicator.parameters:addColor("Unconfirmed_Down", "Unconfirmed Down fractal color", "Down fractal color", core.rgb(0,0,255));
	
	indicator.parameters:addInteger("Size", "Font Size", "", 10, 1 , 100);	 
end

local source;
local up, down;
local Left;
local Right;
local Central;
local font1,font2;
local Size;
local Id;
function Prepare(nameOnly)
    source = instance.source;
    Size = instance.parameters.Size;
    up = instance:createTextOutput ("Up", "Up", "Wingdings", Size, core.H_Center, core.V_Top, instance.parameters.UP, 0);
    down = instance:createTextOutput ("Dn", "Dn", "Wingdings", Size, core.H_Center, core.V_Bottom, instance.parameters.DOWN, 0);

	Left=instance.parameters.Left;
  	Right=instance.parameters.Right;
	Central=instance.parameters.Central;
	
	 font1 = core.host:execute("createFont", "Wingdings", Size, false, false);
	 font2 = core.host:execute("createFont", "Arial", Size, false, false);
  
    local name = profile:id() .. " ( " ..Left .. ", " .. Central .. ", " .. Right .. " )";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
end


function ReleaseInstance()
       core.host:execute("deleteFont", font1);
	   core.host:execute("deleteFont", font2);
end
	   

function Update(period)

   

        if period < source:first() + Central+Left then
		return;
		end
		
 
		local Start=period-Central;
		
		up:setNoData (Start);
		down:setNoData (Start);
		
		
        
		 
        local High = source.high[Start];
	    local Low = source.low[Start];
		
		local L=0;
		local R=0;
 
		-- Up Fractal		
         for i= 1, Left, 1 do
		   if   High > source.high[Start-i]  then
		   L=L+1;
		   end		   
		 end
		 
		 for i= 1, Right, 1 do
		 
		    
		     if   High > source.high[Start+i]  then			 
			  R=R+1; 
		      end
		 end
		
	     if R==Right 
		 and L== Left 
		 then
		   up:set(Start, source.high[Start], "\226");
		 end
		 
	  
		 
		 
		L=0;
		R=0;
 
		
		-- Up Fractal		
         for i= 1, Left, 1 do
		   if   Low < source.low[Start-i]  then
		   L=L+1;
		   end		   
		 end
		 
		 for i= 1, Right, 1 do
		 
		
		      if   Low  < source.low[Start+i]   then				 
			  R=R+1; 
		      end
		 end
		
	     if R==Right 
		 and L== Left 
		 then
		   down:set(Start, source.low[Start], "\225");
		 end 
		 
	     if period < source:size()-1 then
		 return;
		 end
		 
		 local ID=0;
		 core.host:execute ("removeAll");
		 
         for i= source:size()-1,  source:size()-1 -Central+1 , -1 do
		     local Top,Bottom = Test(i);
			 local C1, C2= Confirmation(i);
			 
		     if Top   
			 and (Right - ( source:size()-1-  i)) > 0
			 and C1
			 then
			 ID=ID+1;
			 core.host:execute("drawLabel1", ID , source:date(i), core.CR_CHART, source.high[i], core.CR_CHART, core.H_Left, core.V_Top, font2, instance.parameters.Unconfirmed_Up, tostring(Right - ( source:size()-1-  i)) );
			 end
			 if Bottom 
			 and (Right - ( source:size()-1-  i)) > 0
			 and C2
			 then
			  ID=ID+1;
			 core.host:execute("drawLabel1",ID,  source:date(i), core.CR_CHART, source.low[i], core.CR_CHART, core.H_Left, core.V_Bottom, font2, instance.parameters.Unconfirmed_Down, tostring( Right - ( source:size()-1-  i)) );
			 end
		 end
	 
       
end
function Confirmation(period) 
 
local Top=true;
local Bottom=true;


for i= period+1, math.min(period+Right, source:size()-1), 1 do

	if   source.low[period]  >=source.low[i] 
	then
	Bottom=false;
	end
	
	if   source.high[period]  <= source.high[i] 	
	then
	 Top=false;
	end

end 

 return Top, Bottom;

 

end



function Test(period) 
local T=0;
local B=0;

local Top=false;
local Bottom=false;


for i= 1, Left, 1 do

	if   source.low[period]  < source.low[period-i]
	and B~=-1
	then
	B=B+1;
	else
	B=-1
	end
	
	if   source.high[period]  > source.high[period-i] 
	and T~=-1
	then
	T=T+1;
	else
	T=-1;
	end

end

 if T== Left then
 Top=true;
 end
 
  if B== Left then
 Bottom=true;
 end


 return Top, Bottom;

 end
 