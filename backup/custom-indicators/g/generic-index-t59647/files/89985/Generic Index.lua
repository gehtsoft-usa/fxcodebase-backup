-- Id: 10220
-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59647

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
    indicator:name("Generic Index");
    indicator:description("Generic Index");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);	   

	
	indicator.parameters:addGroup("Selektor");	
    local i;
	local Default={"USD", "EUR", "GBP","JPY", "CHF",  "AUD", "NZD", "CAD"};
	indicator.parameters:addString("Default", "Index  Default", "", "USD");
	for i= 1, 8, 1 do
    indicator.parameters:addStringAlternative("Default", Default[i], Default[i],Default[i]);
    end
	
		indicator.parameters:addBoolean("Inverse" , "Inverse", "", false);	

	
	
	Parameters (1 , "EUR/USD" );
	Parameters (2 , "USD/JPY" );
	Parameters (3, "GBP/USD");
	Parameters (4 ,"USD/CHF");
	Parameters (5 , "USD/CAD");
	Parameters (6 , "NZD/USD" );
	Parameters (7 , "AUD/USD" );
	Parameters (8, "USD/SEK");
	Parameters (9 ,"USD/RUB");
	Parameters (10 , "XAU/USD");	 
	
	
	indicator.parameters:addGroup("Style");		
	indicator.parameters:addColor("Color", "Line Color", "", core.rgb(0, 0, 255));
end


function Parameters (id , Instrument )
    indicator.parameters:addGroup(id ..". Instruments");
	indicator.parameters:addBoolean("On"..id , "Use This Instrument", "", true);	

	indicator.parameters:addString("Instrument"..id, "Instruments", "", Instrument);
    indicator.parameters:setFlag("Instrument"..id, core.FLAG_INSTRUMENTS );
	
end

local loading={};
local SourceData={};
local Instrument={};
local Color;
local Num;
local Index;
local On={};
local ScaleFactor;
local Default;
local pdate = "(%a%a%a)/(%a%a%a)";
local Weight={};
local Inverse;
function Prepare(nameOnly)      
	
    source = instance.source;
	Default = instance.parameters.Default;
	Inverse = instance.parameters.Inverse;
	
    local name =  "(" .. profile:id() .. ","  .. instance.source:name().. ","  .. source:barSize().. ")"
	instance:name(name);
	
	if   (nameOnly) then
        return;
    end
		
	Color = instance.parameters.Color;	
	Num=0;
	local First, Second;
	for i = 1 , 10 , 1 do   
	
	   On[i]=  instance.parameters:getBoolean ("On"..i);
	   
	    First, Second= string.match( instance.parameters:getString ("Instrument"..i), pdate);
	   
	   if On[i]  then
			  if First== Default or Second== Default then
			  Num = Num+1;	  			  
			  Instrument[Num]=  instance.parameters:getString ("Instrument"..i);  
			 			  			  
			  else
			  error( i.. ". Instrument " ..instance.parameters:getString ("Instrument"..i) .. " does not contain ".. Default); 	
			  end
	  end
	end	
	
	
	
		
	local i;
			 
		 for i = 1, Num, 1 do	
		 
			   SourceData[i] = core.host:execute("getSyncHistory", Instrument[i], source:barSize(), source:isBid(), 0  ,20000 +i , 10000 + i);
			   loading[i] = true;  
			  
			  

		end
		local X=1;
		for j = 1, Num, 1 do		

		First, Second= string.match( Instrument[j], pdate);
		
              if First== Default then
			   Weight[j]=1/Num;
			  else
			  Weight[j]=-1/Num;
			  end
		if Inverse then
		Weight[j]=Weight[j]*-1;
        end		
		X= X*(( 1)^(Weight[j])) ;
		end							  
		
		ScaleFactor=100/X;							  
	
		Index = instance:addStream("Index", core.Line, Default .. " Index",  Default.." Index", Color, source:first());
    Index:setPrecision(math.max(2, instance.source:getPrecision()));

end




function Update(period)

 if period < source:first() then
 return
 end
 
     
    local FLAG=false;	
	local i;
	
		 for i = 1, Num, 1 do	

                 if loading[i] then
				 FLAG= true;				
				 end         	
         end
	
	if FLAG then 
	return;
	end
	
	local X=1;
	local j;
	
						
			
             			
			 
							  for j = 1, Num, 1 do
									 if  SourceData[j].close:hasData(period) then
									  X= X*((  SourceData[j].close[period]/SourceData[j].close[SourceData[j]:first()])^Weight[j]) ;	                                     
									  end
							  end
							  
							  
							
							  Index[period]= X*ScaleFactor;	
                              							  
			             					 
					
	
end


-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)


 local i;
 

		 for i = 1, Num, 1 do	
			  if cookie == ( 10000 +  i) then
			  loading[i] = true;
		      elseif  cookie == (20000+ i) then
			  loading[i] = false;   
			  
			  end
		       
          end
	
	
	
    local FLAG=false; 
	local Number=0;
	
	
		 for i = 1, Num, 1 do	

                 if loading[i] then
				 FLAG= true;
				 Number=Number+1;
				 end
		 
         end  	
    
	
	if FLAG then
	 core.host:execute ("setStatus", "  Loading "..((Num - Number) .. " / " .. (Num) ));	 
	else
	core.host:execute ("setStatus", "Loaded")
	instance:updateFrom(0);
	end
   
        
    return core.ASYNC_REDRAW ;
end




