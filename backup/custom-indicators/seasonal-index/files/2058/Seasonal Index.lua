-- Id: 726

-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=1084

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
    indicator:name("Seasonal Index");
    indicator:description("Seasonal Index");
    indicator:requiredSource(core.Bar);
    indicator:type(core.Oscillator);

    indicator.parameters:addColor("Yearly_Index", "Color of Yearly Indexes", "Color of Yearly Indexes", core.rgb(255, 0, 0));
	indicator.parameters:addColor("Seasonal_Index", "Color of Seasonal Index", "Color of Seasonal Index", core.rgb(0, 0, 255));
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
local Frame;

local first;
local source = nil;

local ARRAY={};
local ARRAYMAX={};
local MAX=0;
local INDEXES={};
local TMP={};
local label=1;

local YEAR={};
local nold=-1;
local OUT={};

local INDEXAVG=nil;
local MaxArray=0;

-- Streams block
local SI = nil;

-- Routine
function Prepare(nameOnly)

    source = instance.source;
    first = source:first();
	host = core.host; 

	
    local name = profile:id() .. "(" .. source:name()  .. ")";
    instance:name(name);
	
	if   (nameOnly) then
        return;
    end
	
	SI = instance:addStream("BOY", core.Line, name, "BOY", instance.parameters.Yearly_Index, first);
    SI:setPrecision(math.max(2, instance.source:getPrecision()));
	INDEXAVG = instance:addStream("Seasonal", core.Bar, name, "Seasonal", instance.parameters.Seasonal_Index, first);
    INDEXAVG:setPrecision(math.max(2, instance.source:getPrecision()));
    
	
end

local last_period = nil;
local last_size = nil;
-- Indicator calculation routine
-- TODO: Add your code for calculation output values
function Update(period)

     
		if last_period ~= period or last_size~=source:size()-1 then
		
		last_period = period; 
		last_size=source:size()-1;
      
        core.host:execute("removeAll");
        end
        
    
			if period >= first  then
			
			
			local i,j,k;
	
			if period == first then
			MAX=Arrays(period);			
			end
						
			Save(period);	
			
			
			calculate(period);	
			
			
									
			if period == (source:size()-1) then
					
					for k = 0 , period do
					j=position(k);
					i=index(k);
					
					if j== 1 then 
					host:execute ("drawLabel", label, source:date(k),0, "X");
					label=label+1;
					end
						    SI[k] = INDEXES[i][j];
							
														
							if k== period then
							findmax(period);
							averege(k); 
							draw(k);
							end
						
					end		
							
				
			end
			
			end
	
end

function position(p)


local i;
if i~=0 then
i= index(p);
return p-YEAR[i];
else 
return 0;
end
    
end

function index(p)

 local now;
 local data;
  
 data= core.dateToTable (source:date(p));
 now= core.dateToTable(core.now());

 return math.abs( data.year-now.year); 
    
end

function Arrays(p)
local l;
 
 l =  index(p);
 
		 for l = 0, l , 1 do
		 ARRAY[l]={}; 
		 INDEXES[l]={};
		 end
		 
	return l;	 
    
end

function Save(p)
local n;
local m;
   
                n=index(p);

                 if n~=nold and n~= nil then
                   YEAR[n]= p; 
				   nold=n;
                 end
 				
				m=position(p);	
				
				ARRAY[n][m]=source.close[p];
				
				ARRAYMAX[n]=m;
				
				if  m== 1  then
				TMP[n]=source.close[p];
				end
						    
end

function calculate(p)
local i,j;
	
	       i=index(p);
	       j=position(p);
		
            if j== 0 then 		
			INDEXES[i][j]=0;
			else
			INDEXES[i][j]=  ((ARRAY[i][j] /TMP[i])-1)*100; 
			end
		
end

function averege(p)
	 
	 local i,j,k,l,SUM=0;
	 local test;
	 local temp=0;
			 
			 for j = 0 , MaxArray ,1  do
				  
				   SUM=0;
		           count=0;
				   
						
				   for i= 0 , MAX-1, 1 do
				   			
					
					        if INDEXES[i][j] ~=nil  and  ARRAYMAX[i+1] > 0 then   
							count=count+1;
							SUM= SUM+ INDEXES[i][j];
							
							OUT[j] = SUM/count;
								
					        end
				   
				   
				   end
     end
			 
			
   	
end

function draw(p)

local i;

	for i = YEAR[0], p, 1 do
	INDEXAVG[i]=  OUT[position(i)] ;
	end 

end

function findmax(p)

local i;

	  for i = 0, MAX, 1 do
			
				if MaxArray <  ARRAYMAX[i] then
				MaxArray=  ARRAYMAX[i];
				end
				
            end	
end



