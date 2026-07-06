-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=277

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
    indicator:name("MTF VORTEX");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);	

	
	Parameters (1 , "H1" );
	Parameters (2 , "H4" );
	Parameters (3 , "H8" );
    Parameters (4 , "D1" );
	Parameters (5 , "W1" );
	
	indicator.parameters:addGroup("Common Parameters");		 
	indicator.parameters:addInteger("Size", "Size", "", 10);
	indicator.parameters:addInteger("Shift", "Vertical Shift", "", 0, 0 , 10000);
	indicator.parameters:addColor("Up", "Up Trend Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Down", "Down Trend Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "No Trend Color", "", core.rgb(0, 0, 255));
	indicator.parameters:addColor("Label", "Label Color", "", core.rgb(0, 0, 0));
	
	--Style (1 );
	--Style (2 );
	--Style (3 );
	--Style (4 );
	--Style (5 );
	
	
end

function Style (id)
    
  	indicator.parameters:addGroup(id.. ".  Time Frame Style Options"); 
    indicator.parameters:addInteger("widht"..id, "Line widht", "", 1, 1, 5);
    indicator.parameters:addInteger("style"..id, "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style"..id, core.FLAG_LINE_STYLE);
	

end


function Parameters (id , FRAME )


  	indicator.parameters:addGroup(id..".  Time Frame"); 
        indicator.parameters:addInteger("N"..id, "Length of the vortex", "", 14);

  
    indicator.parameters:addString("B"..id, "Time frame", "", FRAME);
    indicator.parameters:setFlag("B"..id, core.FLAG_PERIODS);
end


local N={};

local B={};
--local color={};
local widht={};
local style={};
local Shift;
local  Size;
local source;
local Indicator={};
local Source={};
local loading={};
local day_offset, week_offset;
 
local host;
--local alive;
local first;
local Up, Down, Neutral, Label;

 local font;
 local font2;
 function Prepare(nameOnly)   
 
    local name = profile:id() .. "(" ..  instance.source:name()  .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end 
    Shift=instance.parameters.Shift;
    Up=instance.parameters.Up;
	Down=instance.parameters.Down;
	Neutral=instance.parameters.Neutral;
	Label=instance.parameters.Label;

	
	assert(core.indicators:findIndicator("VORTEX") ~= nil, "Please, download and install VORTEX.LUA indicator");	
	
    	local i;
    for i= 1, 5, 1 do	
	 -- color[i]= instance.parameters:getColor ("color"..i);

	-- style[i]= instance.parameters:getDouble ("style"..i);
	-- widht[i]= instance.parameters:getDouble ("widht"..i);
	 N[i]= instance.parameters:getDouble ("N"..i);
     B[i]= instance.parameters:getString ("B"..i);
	end
      
    Size=instance.parameters.Size; 
	
   
	
    source = instance.source;
	first= source:first();
    host = core.host;

    
 
	
	--Arial
	  font = core.host:execute("createFont", "Arial", Size, true, false);
       font2 = core.host:execute("createFont", "Wingdings", Size, false, false);
	
	

	
		for i = 1, 5 , 1 do	 
			Source[i] =  core.host:execute("getSyncHistory", source:instrument(), B[i], source:isBid(),math.min(300,N[i]*2) , 2000 + i , 1000 + i);
			Indicator[i] = core.indicators:create("VORTEX", Source[i],N[i]);
			loading[i]=true;
		end

		
	
	
	 core.host:execute("setTimer", 1, 1);
end


function Update(period, mode)
 
 
 
 if  period <  source:size() - 1 then	
                            return;
	end
 
	local i;
	

	
	
	
			for i = 1, 5, 1  do
		     
			 
			    local VIP= nil;
				local VIM= nil;
				local fromDate, toDate; 
				local color;
				local symbol;
 

						
						
                              
                     							
							 
							      core.host:execute("drawLabel1", i+200, -i*Size*5*1.1, core.CR_RIGHT,Size*3*1.1+Shift, core.CR_TOP, core.H_Right, core.V_Bottom,
                             font, Label, instance.parameters:getString ("B"..i));
							 
						       
											   if Indicator[i].VIP:hasData(Indicator[i].VIP:size()-1)   then
											   
											       VIM=  Indicator[i].VIM[Indicator[i].VIM:size()-1];
												    VIP=  Indicator[i].VIP[Indicator[i].VIP:size()-1];
													
													
													if VIP > VIM then
													color=Up;
													symbol = "\225"; 
													else
													color=Down;
													symbol = "\226"; 
													end
									
												
														core.host:execute("drawLabel1", i, -i*Size*5*1.1, core.CR_RIGHT, Size*4*1.1+Shift, core.CR_TOP, core.H_Right, core.V_Bottom,
														font2, color , symbol);
														
															core.host:execute("drawLabel1", i+100, -i*Size*5*1.1, core.CR_RIGHT, Size*5*1.1+Shift, core.CR_TOP, core.H_Right, core.V_Bottom,
														font, Up,  string.format("%." .. 5 .. "f", Indicator[i].VIP[Indicator[i].VIP:size()-1] ));
														
															core.host:execute("drawLabel1", i+300, -i*Size*5*1.1, core.CR_RIGHT, Size*6*1.1+Shift, core.CR_TOP, core.H_Right, core.V_Bottom,
														font, Down,  string.format("%." .. 5 .. "f", Indicator[i].VIM[Indicator[i].VIM:size()-1] ));
														
														
														
													
												
												end
												
											 
						end					
					 
				
end
	 


function ReleaseInstance()
       core.host:execute("deleteFont", font);
       core.host:execute("deleteFont", font2);
	   	core.host:execute ("killTimer", 1);
   end


   
-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)




		 for i = 1, 5, 1 do	
		     
			  if cookie == (1000 + i) then
			  loading[i] = true;
		      elseif  cookie == (2000 + i) then
			  loading[i] = false;  
			  end
		       
        
	end    
	
	
	
    local FLAG=false;
			

	
			local Number=0;
			

				 for i = 1, 5, 1 do	

						 if loading[i] then
						 FLAG= true;
						 Number=Number+1;
						 end
				 
				 end  	
			
			
	
           if cookie == 1 and not FLAG then
	

				 for i = 1,5, 1 do	

						  
						  Indicator[i]:update(core.UpdateLast);
					 
				 
				 end  	


		   
		    
		   end
	  
			
			if FLAG then
			 core.host:execute ("setStatus", "  Loading "..((5) - Number) .. " / " .. (5) );
			else
			 core.host:execute ("setStatus", " " );
			 instance:updateFrom(0);
			end
			
          
 
   
        
    return core.ASYNC_REDRAW ;
end
