-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=3367
-- Id: 3089

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                   Paypal: https://goo.gl/9Rj74e  |
--|                    Patreon : https://www.patreon.com/mariojemic  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

 function Init()
    indicator:name("Rollover");
    indicator:description("Rollover");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);	
	
	indicator.parameters:addInteger("size", "Font Size", "", 13,10,15);
	indicator.parameters:addInteger("spacing", "Spacing", "", 15,10,100);
	indicator.parameters:addColor("color", "Color of Label", "", core.rgb(0, 0, 0));
	
end

local Plus={};
local Minus={};
local Zero={};
local IndexP={};
local IndexM={};
local TempP={};
local TempM={};

local size;
local SPACE;

local MAX, MIN;

local first;
local source = nil;
local font,bold;

-- Routine
function Prepare(nameOnly)
     
	host=   core.host;
    source = instance.source;
    first = source:first();	
	size=instance.parameters.size;
	SPACE=instance.parameters.spacing;
   
    local name = profile:id() ;
	instance:name(name);
	if nameOnly then
		return;
	end
	
	 font = core.host:execute("createFont", "Courier", size, false, false);
	 bold = core.host:execute("createFont", "Courier", size, false, true);
					   
end



-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)

	if period ~= source:size() -1 then
	return;
	end	

  
	DATA();
	SORT();
	DRAW();
end

function SORT()

SP();
SM();

end

function SP()

local i;

		for  i= 1 , #Plus, 1 do
		TempP[i] = Plus[i][2]; 
		end
		 

	
		for  i= 1 , #TempP, 1 do
		 
		 
		  PMAX();
		 
		 
		 TempP[MAX]= 0;	 
		 IndexP[i]={};
		 IndexP[i][1] =   Plus[MAX][1]; 
		  IndexP[i][2] =   Plus[MAX][2]; 
		   IndexP[i][3] =   Plus[MAX][3]; 
		
	
		end

end


function SM()

local i;

		for  i= 1 , #Minus, 1 do
		TempM[i] = Minus[i][2]; 
		end
		 

	
		for  i= 1 , #TempM, 1 do
		 
		 
		  PMIN();
		 
		 
		 TempM[MIN]= 0;	 
		 IndexM[i]={};
		 IndexM[i][1] =   Minus[MIN][1]; 
		  IndexM[i][2] =   Minus[MIN][2]; 
		   IndexM[i][3] =   Minus[MIN][3]; 
		
	
		end

end


function PMAX()
 
 
    MAX=1;
	 local i;
	 
      for  i= 1 , #TempP, 1 do
		  if TempP[i] >=  TempP[MAX] and  TempP[i]~= 0	then
		  MAX=i;
		  end	  
	  end
	  
	
	 
end

function PMIN()
 
 
    MIN=1;
	 local i;
	 
      for  i= 1 , #TempM, 1 do
		  if TempM[i] <=  TempM[MIN] and  TempM[i]~= 0	then
		  MIN=i;
		  end	  
	  end
	  
	
	 
end



function DRAW()
    P();
	Z();
	M();
end


function ReleaseInstance()
       core.host:execute("deleteFont", font); 
end

local color;

function Z() 

    
     local i;
	 
	 core.host:execute("drawLabel1", 3,510, core.CR_LEFT,  SPACE, core.CR_TOP, core.H_Left, core.V_Center,
									  bold, instance.parameters.color, "Zero"  );
    
   
   for i= 1 , #Zero, 1  do
   
      if Zero[i][3]== true then  
	  color= core.rgb(0, 255, 0);
	  elseif Zero[i][3]== false then  
	   color= core.rgb(255, 0, 0);
	  else
	  color= core.rgb(0, 0, 255);
	  end
	 
  	core.host:execute("drawLabel1", 500+i,500, core.CR_LEFT, 15+ SPACE*i, core.CR_TOP, core.H_Center, core.V_Center,
									  font, color, tostring(Zero[i][1])  );
	 core.host:execute("drawLabel1", 600+i,600, core.CR_LEFT, 15+ SPACE*i, core.CR_TOP, core.H_Center, core.V_Center,
									   font, color, tostring(Zero[i][2])  );
									  
	end		   

end
function M() 

     local i;
	 
	 core.host:execute("drawLabel1", 2,310, core.CR_LEFT,  SPACE, core.CR_TOP, core.H_Center, core.V_Center,
									  bold, instance.parameters.color, "Negative"  ); 
   
   for i= 1 , #Minus, 1  do
   
  
   
			 if IndexM[i][3] then  
			  color= core.rgb(0, 255, 0);
			  else
			   color= core.rgb(255, 0, 0);
			  end
	  
   
   	 core.host:execute("drawLabel1", 300+i,300, core.CR_LEFT,15+  SPACE*i, core.CR_TOP, core.H_Center, core.V_Center,
									  font, color, tostring(IndexM[i][1])  );
	 core.host:execute("drawLabel1", 400+i,400, core.CR_LEFT, 15+ SPACE*i, core.CR_TOP, core.H_Center, core.V_Center,
									   font, color, tostring(IndexM[i][2])  );
									  
	end		   
	   
end

function P() 
   
   
   local i;
   
   	 core.host:execute("drawLabel1", 1,110, core.CR_LEFT,  SPACE, core.CR_TOP, core.H_Center, core.V_Center,
									  bold, instance.parameters.color, "Positive"  ); 
   
   for i= 1 , #Plus, 1  do
   
    
		   
			 if IndexP[i][3] then  
			  color= core.rgb(0, 255, 0);
			  else
		   color= core.rgb(255, 0, 0);
			  end
		   
			 core.host:execute("drawLabel1", 100+i,100, core.CR_LEFT, 15+ SPACE*i, core.CR_TOP, core.H_Center, core.V_Center,
											  font, color, tostring(IndexP[i][1])  );
			 core.host:execute("drawLabel1", 200+i,200, core.CR_LEFT, 15+ SPACE*i, core.CR_TOP, core.H_Center, core.V_Center,
											   font, color, tostring(IndexP[i][2])  );
											  
			end		
	
end


function DATA()

		local Table=core.host:findTable("offers");
		local enum = Table:enumerator();
	   
	    local i=0;
		local j=0;
		local k=0;
		
	    while true do
		
	    local row = enum:next();	
	    
		if row == nil then
		break;
		end   
		
		
        
		
						
		local instrument = row.Instrument;	
		local IntrS  = row.IntrS;
		local IntrB  = row.IntrB;
		
				if IntrB > 0 then
				i=i+1;
				Plus[i]={};	
				Plus[i][1]=instrument;
				Plus[i][2]=IntrB;
				Plus[i][3]=true;				
				elseif IntrB < 0 then
				j=j+1;
				Minus[j]={};
				Minus[j][1]=instrument;
				Minus[j][2]=IntrB;
				Minus[j][3]=true;
				elseif IntrB == 0  and IntrS == 0 then		
				k=k+1;
				Zero[k]={};
				Zero[k][1]=instrument;
				Zero[k][2]=0;
				Zero[k][3]="BOTH";
				end
				
				if IntrS > 0 then	
				i=i+1;
				Plus[i]={};		
				Plus[i][1]=instrument;
				Plus[i][2]=IntrS;
				Plus[i][3]=false;
				elseif IntrS < 0 then
				j=j+1;
				Minus[j]={};
				Minus[j][1]=instrument;
				Minus[j][2]=IntrS;
				Minus[j][3]=false;
				elseif IntrS == 0 and IntrB ~= 0  then	 
				k=k+1;
				Zero[k]={};
				Zero[k][1]=instrument;
				Zero[k][2]=0;
				Zero[k][3]=true;
				elseif  IntrS ~= 0 and IntrB == 0 then
				k=k+1;
				Zero[k]={};
				Zero[k][1]=instrument;
				Zero[k][2]=0;
				Zero[k][3]=false;
				end
		
		
		end
end