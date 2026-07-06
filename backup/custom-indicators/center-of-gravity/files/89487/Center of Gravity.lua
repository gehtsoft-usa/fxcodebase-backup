-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=17&t=59509
-- Id: 9994

--+------------------------------------------------------------------+
--|                               Copyright © 2018, Gehtsoft USA LLC |
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |
--|                                          mario.jemic@gmail.com   |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  |
--|                                  Paypal : https://goo.gl/9Rj74e  |
--|                                 Patreon : https://goo.gl/GdXWeN  |
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
--+------------------------------------------------------------------+

function Init()
    indicator:name("Center of Gravity");
    indicator:description("Center of Gravity");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);

	
 
    indicator.parameters:addGroup("Calculation");	
    indicator.parameters:addInteger("bars_back", "Start Bars Back", "Bars Back", 125);
	indicator.parameters:addInteger("i", "End Bars Back", "End Bars Back", 0);	
	indicator.parameters:addInteger("m", "Order", "Order", 2);
	
	indicator.parameters:addDouble("kstd", "Multiplier", "Multiplier", 2);
	
	
 
	indicator.parameters:addGroup("Style");
    indicator.parameters:addColor("fx", "Color of Cental Line", "Color of Central", core.rgb(0, 0, 288));	
	indicator.parameters:addInteger("fxwidth", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("fxstyle", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("fxstyle", core.FLAG_LINE_STYLE);
	
	indicator.parameters:addColor("sqh", "Color of Top Sqh  Line" , "Color of Top Sqh", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("sqhwidth", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("sqhstyle", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("sqhstyle", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addColor("sql", "Color of Bottom Sql Line", "Color of Bottom Sql", core.rgb(0, 255, 0));
	indicator.parameters:addInteger("sqlwidth", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("sqlstyle", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("sqlstyle", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addColor("stdh", "Color of Top Std  Line" , "Color of Top Std", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("stdhwidth", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("stdhstyle", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("stdhstyle", core.FLAG_LINE_STYLE);
	
	
	indicator.parameters:addColor("stdl", "Color of Bottom Std Line", "Color of Bottom Std", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("stdlwidth", "Line width", "", 1, 1, 5);
    indicator.parameters:addInteger("stdlstyle", "Line style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("stdlstyle", core.FLAG_LINE_STYLE);
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- TODO: Refine the first period calculation for each of the output streams.
-- TODO: Calculate all constants, create instances all subsequent indicators and load all required libraries
-- Parameters block
 

local first;
local source = nil;
local bars_back;
-- Streams block
local fx, sqh, sql, stdh, stdl;
local kstd, m, i, nn, p;
local sx={};
local b={};
local ai={};
local x={};
local fx={};
-- Routine
function Prepare(nameOnly)
    bars_back = instance.parameters.bars_back;
	kstd = instance.parameters.kstd;
	m = instance.parameters.m;
	i = instance.parameters.i;
	
	nn = m + 1;
	p = bars_back; 
    source = instance.source;
    first = source:first();

    local name = profile:id() .. "(" .. source:name() .. ", " .. tostring(bars_back)  .. ", " .. tostring(kstd) .. ", " .. tostring(m).. ", " .. tostring(i).. ")";
    instance:name(name);

    if (not (nameOnly)) then
        fx = instance:addStream("fx", core.Line, name, "fx", instance.parameters.fx, first);
		fx:setWidth(instance.parameters.fxwidth);
        fx:setStyle(instance.parameters.fxstyle);
		sqh = instance:addStream("sqh", core.Line, name, "sqh", instance.parameters.sqh, first);
		sqh:setWidth(instance.parameters.sqhwidth);
        sqh:setStyle(instance.parameters.sqhstyle);
		sql = instance:addStream("sql", core.Line, name, "sql", instance.parameters.sql, first);
		sql:setWidth(instance.parameters.sqlwidth);
        sql:setStyle(instance.parameters.sqlstyle);
		
		stdh = instance:addStream("stdh", core.Line, name, "stdh", instance.parameters.stdh, first);
		stdh:setWidth(instance.parameters.stdhwidth);
        stdh:setStyle(instance.parameters.stdhstyle);
		stdl = instance:addStream("stdl", core.Line, name, "stdl", instance.parameters.stdl, first);
		stdl:setWidth(instance.parameters.stdlwidth);
        stdl:setStyle(instance.parameters.stdlstyle);
    end
end

-- Indicator calculation routine
-- TODO: Add your code for calculation output values

local prevCandle = nil;

function Update(period)

   	if period < source:size() -1  - bars_back  then
	 fx[period] = nil;
	 sqh[period] = nil;
      sql[period] =nil;
      stdh[period] = nil;
      stdl[period] = nil;
    return
	 end	

    if period < first
	or not  source:hasData(period)	
	then
	return;
	end
	
    
	
	
	if prevCandle ~= nil and source:serial(period) == prevCandle then
        return ;
    else
        prevCandle = source:serial(period);
    end
	sx[1] = p + 1;
	
	local  mi,n, jj, ii,kk, mm,tt,qq;
	
	-----------------------sx-------------------------------------------------------------------
	local sum=0;
	
   for mi = 1,  nn * 2 - 2, 1 do
    
      sum = 0;
      for n = i,  i + p , 1 do
       
         sum = sum + math.pow(n, mi);
       end
      sx[mi + 1] = sum;
    end
	
	
	----------------------syx-----------
   for mi = 1,  nn, 1 do
   
      sum = 00;
	  
      for n = i,   i + p,  1 do
      
         if(mi == 1) then
            sum = sum + source[period- n];
         else
            sum = sum + source[period-n] * math.pow(n, mi - 1);
		 end	
      end
      b[mi] = sum;
   end
	
		
	--===============Matrix=======================================================================================================
	for jj = 1, nn, 1 do
            ai[jj] = {};
     end
	
	
   for jj = 1,  nn, 1  do
   
      for ii = 1,  nn, 1 do
      
         kk = ii + jj - 1;
         ai[ii][jj] = sx[kk];
      end
    end  	
	
	
	
	--===============Gauss========================================================================================================
   for kk = 1,   nn - 1, 1 do
    
      ll = 0; mm = 0;
      for ii = kk, nn, 1  do
      
         if math.abs(ai[ii][ kk]) > mm then
         
            mm = math.abs(ai[ii][ kk]);
            ll = ii;
         end
      end
	  
	  
      if(ll == 0) then
      return;
	  end

      --if(ll != kk)
	  if(ll ~= kk) then
      
         for jj = 1,  nn, 1 do
         
            tt = ai[kk] [jj];
            ai[kk][jj] = ai[ll][ jj];
            ai[ll][ jj] = tt;
         end
         tt = b[kk];
		 b[kk] = b[ll];
		 b[ll] = tt;
      end  
	  
	  
      for ii = kk + 1,  nn , 1  do
      
         qq = ai[ii][kk] / ai[kk][ kk];
         for jj = 1, nn, 1 do
         
            if(jj == kk) then
               ai[ii][ jj] = 0;
            else
               ai[ii][ jj] = ai[ii][ jj] - qq * ai[kk][ jj];
             end
		end	 
         b[ii] = b[ii] - qq * b[kk];
         end
      end  
	  
   x[nn] = b[nn] / ai[nn][ nn];
   for ii = nn - 1, 1 , -1 do
   
      tt = 0;
      for jj = 1,  nn - ii,  1  do
      
         tt = tt + ai[ii][ ii + jj] * x[ii + jj];
         x[ii] = (1 / ai[ii][ ii]) * (b[ii] - tt);
       end
   end 
		
 if period <  source:size()-1  then  
 return;
 end
 
 period = source:size()-1;
 
   --===========================================================================================================================
   for n = i,  i + p , 1 do
   
      sum = 0;
      for kk = 1,   m, 1 do
       
         sum  = sum+  x[kk + 1] * math.pow(n, kk);
       end
      fx[period-n] =   x[1] + sum;		
   end		
   
   
   local sq = 0;
   local std=0;
  
   for n = i,   i + p, 1 do
      sq =sq+  math.pow(source[period -n] - fx[period -n], 2);
	  
   end
   
   sq = math.sqrt(sq / (p + 1)) * kstd;   
   std =core.stdev(source, core.rangeTo(period, p))* kstd 
   for n = i,  i + p, 1 do
   
      sqh[period -n] = fx[period -n] + sq;
      sql[period -n] = fx[period -n] - sq;
      stdh[period -n] = fx[period -n] + std;
      stdl[period -n] = fx[period -n] - std;
	
   end 
      fx[period -i-bars_back] = nil;
      sqh[period -i-bars_back] = nil;
      sql[period -i-bars_back] = nil;
      stdh[period -i -bars_back] = nil;
      stdl[period -i-bars_back] = nil;
    
end

