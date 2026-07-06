-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71483

--+------------------------------------------------------------------------------------------------+
--|                                                            Copyright © 2021, Gehtsoft USA LLC  | 
--|                                                                         http://fxcodebase.com  |
--+------------------------------------------------------------------------------------------------+
--|                                                              Support our efforts by donating   | 
--|                                                                 Paypal: https://goo.gl/9Rj74e  |
--+------------------------------------------------------------------------------------------------+
--|                                                                   Developed by : Mario Jemic   |                    
--|                                                                       mario.jemic@gmail.com    |
--|                                                        https://AppliedMachineLearning.systems  |
--|                                                             Patreon :  https://goo.gl/GdXWeN   |  
--+------------------------------------------------------------------------------------------------+

--+------------------------------------------------------------------------------------------------+
--|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |
--|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |
--|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
--|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C                                 |
--|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |                                                  |   
--+------------------------------------------------------------------------------------------------+
 
function Init()
    indicator:name("Inner Candle");
    indicator:description("");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
 
	
   
    
    indicator.parameters:addGroup("Style");	
	
	indicator.parameters:addInteger("width", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("style", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LINE_STYLE);
    indicator.parameters:addBoolean("Connect", "Connect Lines", "", false);	
  
	indicator.parameters:addColor("UpColor", "Up Color", "Up Color", core.rgb(0, 0, 255)); 
	indicator.parameters:addColor("DownColor", "Down Color", "Down Color", core.rgb(0, 0, 255)); 

 	
	 
end 

 
 
local Connect; 
local Source={};
local loading={};
local Number; 
local Loading=false; 
local DataOpen={};
local DataClose={};
function Prepare(nameOnly)   
 
 
 
    local name = profile:id() .. "(" ..  instance.source:name()    .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end
	
	Connect= instance.parameters.Connect;

    day_offset = core.host:execute("getTradingDayOffset");
    week_offset = core.host:execute("getTradingWeekOffset");
	
	source = instance.source;
     local TF={"m1", "m5", "m15", "m30", "H1", "H2", "H3", "H4", "H6", "H8", "D1", "W1", "M1"};
	 
	Number=0;
	local s, e = core.getcandle(source:barSize(), core.now(), 0, 0);
	local s1, e1;
	
    for i = 1, 13  ,  1 do  
    s1, e1 = core.getcandle(TF[i], core.now(), 0, 0);  
    
 
		if (e-s) >= (e1-s1) then
		 
			 Number=Number+1;	 
			 Source[Number]  = core.host:execute("getSyncHistory",  source:instrument(),  TF[i], source:isBid(),300, 2000 + Number , 1000 +Number);	 	 
			 loading[Number]  = true;
			 DataClose[Number]= instance:addInternalStream(0, 0);
			 DataOpen[Number]= instance:addInternalStream(0, 0);			 
        end  	 
 
	 end	
	 
	  
     instance:ownerDrawn(true); 
	 
	
	core.host:execute ("setTimer", 1, 1);	
end

function ReleaseInstance()
core.host:execute ("killTimer", 1);
end 

function   Initialization(period,id)

    local Candle;
    Candle = core.getcandle(source:barSize(), source:date(period), day_offset, week_offset);
  
    if loading[id] or Source[id]:size() == 0  then
        return false;
    end

    
    if period < source:first() then
        return false;
    end

    local P = core.findDate(Source[id], Candle, false);
	 

    -- candle is not found
    if P < 0    then
        return false;
	else return P;	
    end
			
end	

-- the function is called when the async operation is finished
-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)

 

local j;
local FLAG=false; 
local Num=0;
 
    for j = 1, Number, 1 do
		   
			  if cookie == (1000 + j) then
			  loading[j]  = true;
		      elseif  cookie == (2000 + j ) then
			  loading[j]  = false;
			  end
		 
		       
                 if loading[j] then
				 FLAG= true;
				 Num=Num+1;
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





function Update(period, mode)


local FLAG=false;


    for j = 1, Number, 1 do
		     
		       
                 if loading[j] then
				 FLAG= true; 
				 end
	end   

    if 	FLAG then
	return;
	end
	
   
    for j = 1, Number, 1 do
	p = Initialization(period, j);	


		if p~= false then
		DataClose[j][period]= Source[j].close[p];
		DataOpen[j][period]= Source[j].open[p];
		end
    end	
			
				
		 
					
	
end

local init = false;

function Draw (stage, context)

    if stage  ~= 2 then
	return;
	end
	 
	 
 
local FLAG=false;


    for j = 1, Number, 1 do
		     
		       
                 if loading[j] then
				 FLAG= true; 
				 end
	end   

    if 	FLAG then
	return;
	end
	
	 
 
   
        if not init then
		
 
	 
   			   
			   context:createPen (1, context:convertPenStyle (instance.parameters.style), context:pointsToPixels(instance.parameters.width), instance.parameters.UpColor)     
		       context:createPen (2, context:convertPenStyle (instance.parameters.style), context:pointsToPixels(instance.parameters.width), instance.parameters.DownColor)    
 	
			   
		     
            init = true;
        end
     
	 
	 
    local first = math.max(source:first(), context:firstBar ());
    local last = math.min (context:lastBar (), source:size()-1);
 
    
 

			    for i= first, last, 1 do	
            				
						
                AddCandle(context, i );      
	            end
				
	
end


function AddCandle(context, period)

 	
		
		if source.close[period]>source.open[period] then 
        Color=1;
		else
        Color=2;		
        end
		 
		
    	x0, x1, x2 = context:positionOfBar (period);



        local Min=math.huge;
        local Max=0;
		
        for i= 1, Number, 1 do	


  		 if DataClose[i][period]~= 0 then		 
		 Min= math.min(Min,DataClose[i][period] );
		 end
		 Max= math.max(Max,DataClose[i][period] );
		 
		 if DataOpen[i][period]~= 0 then
		 Min= math.min(Min,DataOpen[i][period] );
		 end
		 Max= math.max(Max,DataOpen[i][period] );		 
 
		 
		 visible, y =context:pointOfPrice (DataClose[i][period]);
	     context:drawLine (Color, x0,  y ,x0+((x2-x1)/(Number+1))*i, y );
 
		 
		 if Connect and i>1 then
		 		 visible, y1 =context:pointOfPrice (DataClose[i-1][period]);
				 visible, y2 =context:pointOfPrice (DataClose[i][period]);
		         Shift1=x0+((x2-x0)/(Number))*(i-1);
				 Shift2=x0+((x2-x0)/(Number))*(i);
				 context:drawLine (Color, Shift1 ,  y1 , Shift2, y2 );
		 end

		 visible, y =context:pointOfPrice (DataOpen[i][period]);
	     context:drawLine (Color, x0-((x2-x1)/(Number+1))*i,  y ,x0, y );
		 
		 		 if Connect and i>1 then
		 		 visible, y1 =context:pointOfPrice (DataOpen[i-1][period]);
				 visible, y2 =context:pointOfPrice (DataOpen[i][period]);
		         Shift1=x0-((x2-x0)/(Number))*(i-1);
				 Shift2=x0-((x2-x0)/(Number))*(i);
				 context:drawLine (Color, Shift1 ,  y1 , Shift2, y2 );
		 end
		 
		 

        if  i==  Number then    
		visible, y1 =context:pointOfPrice (Min);
        visible, y2 =context:pointOfPrice (Max);	
	     context:drawLine (Color, x0,  y1 ,x0, y2 );	
        end		 
		 
		end
		
		
	   
		   
		   
end