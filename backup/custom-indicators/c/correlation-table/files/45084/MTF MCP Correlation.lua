-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=26274

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
    indicator:name("MTF MCP Correlation");
    indicator:description("MTF MCP Correlation");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Indicator);
    indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period", "Period", "Period", 10);
	 
 
	 
    indicator.parameters:addString("Reference",  "Reference Currency pair", "", "EUR/USD");
    indicator.parameters:setFlag("Reference", core.FLAG_INSTRUMENTS );
 
   for i= 1 , 13, 1 do
    Add(i);
   end
	
	indicator.parameters:addGroup("Style");
	indicator.parameters:addInteger("FSize", "Font Size", "", 10);
	indicator.parameters:addInteger("Shift", "Vertical Shift", "", 0, 0 , 10000);
    indicator.parameters:addColor("Label", "Label Color", "Label Color", core.rgb(0, 0, 0));
	indicator.parameters:addColor("Positiv", "Positiv Correlation Color", "", core.rgb(0, 255, 0));
	indicator.parameters:addColor("Negativ", "Negativ Correlation Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Neutral", "Neutral Correlation Color", "", core.rgb(128, 128, 128));
end

function Add(id )
 local iTF={"m1", "m5","m15","m30","H1","H2","H3","H4","H6", "H8", "D1","W1","M1"};
     indicator.parameters:addGroup(id ..". Time Frame ");
	 
	 if id==5 or id > 10 then
	indicator.parameters:addBoolean("On"..id , "Show " .. iTF[id ].. " Time Frame", "", true);	
	else
	indicator.parameters:addBoolean("On"..id , "Show " .. iTF[id ].. " Time Frame", "", false);	
	end
	
end


-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local On={};
local Period;
local Pair;
local Reference;
local first;
local source = nil;
local loading={};
local  List,  Size;
local Count;
local iTF={"m1", "m5","m15","m30","H1","H2","H3","H4","H6", "H8", "D1","W1","M1"};
local TF={};
local Label;
local SourceData={};
local Shift, FSize;
local host;
local offset;
local weekoffset;
local font;
local id;  
local Data={};
local Num;
local Ref={};
-- Routine
function Prepare(nameOnly)
     
	Reference = instance.parameters.Reference; 
	Shift = instance.parameters.Shift;
	FSize = instance.parameters.FSize;
	Label = instance.parameters.Label;
    Period = instance.parameters.Period;
    source = instance.source;
    first = source:first();
	
	if Reference== "Chart" then
	Reference= source:instrument();
	end
	
	
	local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(Period) .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	
	 
	host = core.host;
    offset = host:execute("getTradingDayOffset");
    weekoffset = host:execute("getTradingWeekOffset");
		
	 
	 	 Pair, Count = getInstrumentList();
	 

	Num=0;
	
	
	
	for i = 1 , 13 , 1 do   
	
	   On[i]=  instance.parameters:getBoolean ("On"..i);
	   
	   if On[i] then
	   Num = Num+1;
	   TF[Num]=  iTF[i]; 	
	  end
	end	
	
	local X=1 ;
	local Id=0;
	
	for j = 1, Count, 1 do
	
	           if Pair[j] == Reference then		     
		        X= j;
	            end  
	
	         SourceData[j] = {};			 
             loading[j] = {};	
	         Data[j]={};
	   
		 for i = 1, Num, 1 do	
			   
			  Id=Id+1;
		 					 
			   SourceData[j][i] = core.host:execute("getSyncHistory", Pair[j], TF[i], source:isBid(), math.min(300,Period*2) , 2000 + Id , 1000 + Id);
			   loading[j][i] = true;  
			   			   
		end
		
		
		  
	end
	
	 
      
	for i= 1, Num, 1 do
    Ref[i]= SourceData[X][i];
    end	
      
	 
    
	
	font = core.host:execute("createFont", "Courier", FSize , false, true);
   
end

function ReleaseInstance()
       core.host:execute("deleteFont", font);	
 end  

-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)
    if period < source:size()-1 then
	return;
	end
	
	--core.host:execute ("setStatus", "")


	
	local i,j; 
	local FLAG=false; 
	local Number=0;
    id=0;
 	
	
	

	
	for j = 1, Count, 1 do
		 for i = 1, Num, 1 do	

                 if loading[j][i] then
				 FLAG= true;
				 Number=Number+1;
				 end
		 
         end  	
    end
	
	if FLAG then
	return;
	end
	
	
	for j = 1, Count, 1 do--130- j*FSize*2+Shift
	
	    core.host:execute("drawLabel1", id, FSize*1.1*10  ,  core.CR_LEFT, FSize*1.1*5 + j*FSize*1.1+ Shift    , core.CR_TOP, core.H_Left, core.V_Center, font, Label,   Pair[j]);			  
        id = id+1;	
	
		 for i = 1, Num, 1 do	
		 
		      
		       core.host:execute("drawLabel1", id,FSize*1.1*10+i*FSize*1.1*10 ,  core.CR_LEFT,FSize*1.1*5+Shift , core.CR_TOP, core.H_Left, core.V_Center, font, Label, TF[i])		  
               id = id+1;
			  
		 
	          Calculate(j, i);
			  Draw (j,i)
	     end 
	end
	
	


end

function Draw (j,i)

  local Txt;  
local Color=   instance.parameters.Neutral;

if  Data[j][i] == nil then
Txt= "No Data";
else
Txt=string.format("%." .. 2 .. "f", Data[j][i]);


	if Data[j][i]> 50 then
	Color=   instance.parameters.Positiv;
	elseif  Data[j][i] < - 50 then
	Color=   instance.parameters.Negativ;
	end
	
	
end


 



 
 
   core.host:execute("drawLabel1", id,FSize*1.1*10+i*FSize*1.1*10 ,  core.CR_LEFT,FSize*1.1*5 + j *FSize*1.1+ Shift  , core.CR_TOP, core.H_Left, core.V_Center, font, Color,  Txt)	
  id=id+1;
end

function Calculate(j,i)

 Data[j][i] =nil;
		 
if not SourceData[j][i].close:hasData( SourceData[j][i].close:size()-1)	
or     ((SourceData[j][i].close:size())-1< Period)
or not  Ref[i].close:hasData(Ref[i].close:size()-1)	
or   ((Ref[i].close:size()-1)< Period)

then
return;
end
 
  
  Data[j][i] = mathex.correl(Ref [i].close,SourceData[j][i].close, Ref [i].close:size()-1 -Period, Ref [i].close:size()-1, SourceData[j][i].close:size()-1 -Period, SourceData[j][i].close:size()-1);
  
   Data[j][i]=Data[j][i]*100;
 
 

end



function getInstrumentList()
    local list={};
	
    local count = 0;	
    local row, enum;	
	
    enum = core.host:findTable("offers"):enumerator();
    row = enum:next();
    while row ~= nil do
        count = count + 1;
        list[count] = row.Instrument;
        row = enum:next();
    end

    return list, count;
end



-- the function is called when the async operation is finished
function AsyncOperationFinished(cookie)

	
	local i,j;
    local Id=0;
    for j = 1, Count, 1 do
		 for i = 1, Num, 1 do	
		      Id=Id+1;
			  if cookie == (1000 + Id) then
			  loading[j][i] = true;
		      elseif  cookie == (2000 + Id) then
			  loading[j][i] = false;    
			  
			  end
		       
          end
	end    
	
	
	
    local FLAG=false; 
	local Number=0;
	
	for j = 1, Count, 1 do
		 for i = 1, Num, 1 do	

                 if loading[j][i] then
				 FLAG= true;
				 Number=Number+1;
				 end
		 
         end  	
    end
	
	if FLAG then
	 core.host:execute ("setStatus", "  Loading "..((Count*Num) - Number) .. " / " .. (Count*Num) );	
    else
	 core.host:execute ("setStatus", "  Loaded" );	
	         
			--  instance:updateFrom(0);
	end
   
        
    return core.ASYNC_REDRAW ;
end
