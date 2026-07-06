-- More information about this indicator can be found at:
-- https://fxcodebase.com/code/viewtopic.php?f=17&t=71665

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
--|SOL Address            : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                           |
--|Cardano/ADA            : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv             |  
--|Dogecoin Address       : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                     |
--|SHIB Address           : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                             |                                
--+------------------------------------------------------------------------------------------------+


-- Indicator profile initialization routine

function Init()
    indicator:name("FIR Filters");
    indicator:description("");
    indicator:requiredSource(core.Tick);
    indicator:type(core.Indicator);
	
	indicator.parameters:addGroup("Calculation"); 
    indicator.parameters:addInteger("Period", "Period", "", 14, 1, 2000);
    indicator.parameters:addString("Type", "MA Type", "", "1");
    indicator.parameters:addStringAlternative("Type", "Rectangular", "", "1");
    indicator.parameters:addStringAlternative("Type", "Hannig", "", "2");
    indicator.parameters:addStringAlternative("Type", "Hammig", "", "3");
    indicator.parameters:addStringAlternative("Type", "Blackman", "", "4");
    indicator.parameters:addStringAlternative("Type", "Blackman/Harris", "", "5");
    indicator.parameters:addStringAlternative("Type", "Linear weighted", "", "6");	
    indicator.parameters:addStringAlternative("Type", "Triangular", "", "7");		
 
 
	
	indicator.parameters:addGroup("Style"); 	
    indicator.parameters:addColor("color", "Line Color", "", core.rgb(255, 0, 0));
	indicator.parameters:addInteger("style", "Line Style", "", core.LINE_SOLID);
    indicator.parameters:setFlag("style", core.FLAG_LEVEL_STYLE);	
	indicator.parameters:addInteger("width", "Line Width", "", 3, 1, 5);
	
end

-- Indicator instance initialization routine
-- Processes indicator parameters and creates output streams
-- Parameters block

 
local Period,Type; 
local first;
local source = nil;
local Coefficient={}; 
local Line;
local CoefficientArray={};
local CoefficientSum;
						
-- Routine
 function Prepare(nameOnly)   
 
 
    Period= instance.parameters.Period;
	Type= instance.parameters.Type;
	
local _div= Period+1;
	
CoefficientSum=0;

        local i;
		for i= 0, Period, 1 do	
			
			if Type == "1" then Coefficient[i] = 1.0; end
			if Type == "2" then Coefficient[i] = 0.50 - 0.50*math.cos(2.0*math.pi*(i+1)/_div); end
			if Type == "3" then Coefficient[i]= 0.54 - 0.46*math.cos(2.0*math.pi*(i+1)/_div); end
			if Type == "4" then Coefficient[i]= 0.42 - 0.50*math.cos(2.0*math.pi*(i+1)/_div) + 0.08*math.cos(4.0*math.pi*i/_div); end
			if Type == "5" then Coefficient[i]= 0.35875 - 0.48829*math.cos(2.0*math.pi*(i+1)/_div) + 0.14128*math.cos(4.0*math.pi*(i+1)/_div) - 0.01168*math.cos(6.0*math.pi*(i+1)/_div); end
			if Type == "6" then Coefficient[i]= Period-i; end
			if Type == "7" then 
				Coefficient[i]= i+1.0; 	
				if (Coefficient[i]>((_div)/2.0)) then Coefficient[i] = Period-i; end			
			end
			
			CoefficientSum=CoefficientSum+Coefficient[i];

		end							  
 
							  
	
	local Parameters= Period ;
 
    local name = profile:id() .. "(" ..  instance.source:name() ..  ", " ..  Parameters .. ")";
    instance:name(name); 


    if   (nameOnly) then
        return;
    end

    
			
    source = instance.source; 
    first=source:first()+Period ; 
 
	Line = instance:addStream("Line" , core.Line, "Line","Line",instance.parameters.color, first );
	Line:setWidth(instance.parameters.width);
    Line:setStyle(instance.parameters.style);
    Line:setPrecision(math.max(2, source:getPrecision()));
	
	
end

-- Indicator calculation routine
function Update(period, mode)

 
	if period < first
	then
	return;
	end
	
	
	 local dSum = 0; 
	local k;
	 
    for k=0,Period, 1 do
	dSum = dSum + source[period-k]*Coefficient[k];
    end	
 
 
    Line[period]  = dSum/CoefficientSum;
 
				  
end


--[[

//------------------------------------------------------------------
#property copyright   "© mladen, 2021"
#property link        "mladenfx@gmail.com"
#property description "Fir filters"
#property version     "1.00"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers  2
#property indicator_plots    1
#property indicator_label1   "Hann average"
#property indicator_type1    DRAW_COLOR_LINE
#property indicator_color1   clrDarkGray,clrDeepSkyBlue,clrCoral
#property indicator_width1   2

//
//
//

input int                inpPeriod = 14;          // Period
      enum enFirType
         {
            fir_rect, // Rectangular - simple moving average
            fir_hann, // Hannig
            fir_hamm, // Hammig
            fir_blck, // Blackman
            fir_blha, // Blackman/Harris
            fir_lwma, // Linear weighted
            fir_tma,  // Triangular
         };
input enFirType          inpFirType = fir_hann;    // FIR type
input ENUM_APPLIED_PRICE inpPrice   = PRICE_CLOSE; // Price

//
//
//

double val[],valc[];
struct sGlobalStruct
{
   int    period;
   double coeffs[];
   double coeffsSum;
};
sGlobalStruct global;

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//

int OnInit()
{
   SetIndexBuffer(0,val ,INDICATOR_DATA);
   SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
  
      //
      //
      //

            global.period    = MathMax(inpPeriod,1);
            global.coeffsSum = 0;
               double _div   = (global.period+1.0);
               double _coeff = 1;
               ArrayResize(global.coeffs,global.period);
               for (int i=0; i<global.period; i++)
                  {
                     switch(inpFirType)
                        {
                              case fir_rect: _coeff = 1.0; break;
                              case fir_hann: _coeff = 0.50 - 0.50*MathCos(2.0*M_PI*(i+1)/_div); break;
                              case fir_hamm: _coeff = 0.54 - 0.46*MathCos(2.0*M_PI*(i+1)/_div); break;
                              case fir_blck: _coeff = 0.42 - 0.50*MathCos(2.0*M_PI*(i+1)/_div) + 0.08*MathCos(4.0*M_PI*i/_div); break;
                              case fir_blha: _coeff = 0.35875 - 0.48829*MathCos(2.0*M_PI*(i+1)/_div) + 0.14128*MathCos(4.0*M_PI*(i+1)/_div) - 0.01168*MathCos(6.0*M_PI*(i+1)/_div); break;
                              case fir_lwma: _coeff = global.period-i; break;
                              case fir_tma:  _coeff = i+1.0; if (_coeff>((global.period+1.0)/2.0)) _coeff = global.period-i; break;
                        }
                        global.coeffs[i]  = _coeff;
                        global.coeffsSum += _coeff;
                  }

      //
      //
      //

         string _names [] = {"Rectangular/SMA","Hanning","Hamming","Blackman","Blackman/Harris","Linear weighted","Triangular"};
      
      //
      //
      //
      
   IndicatorSetString(INDICATOR_SHORTNAME,StringFormat("%s (%i)",_names[inpFirType],global.period));            
   return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { return; }

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double   &open[],
                const double   &high[],
                const double   &low[],
                const double   &close[],
                const long     &tick_volume[],
                const long     &volume[],
                const int &spread[])
{
   int _limit = (prev_calculated>0) ? prev_calculated-1 : 0;

   //
   //
   //

      struct sWorkStruct
            {
               double price;
            };  
      static sWorkStruct m_work[];
      static int         m_workSize = -1;
                     if (m_workSize<rates_total) m_workSize = ArrayResize(m_work,rates_total+500,2000);

      //
      //
      //

      for (int i=_limit; i<rates_total; i++)
         {
            m_work[i].price = iGetPrice(inpPrice,open[i],high[i],low[i],close[i]);

               double dSum = 0; for (int k=0; k<global.period && i>=k; k++) dSum += m_work[i-k].price*global.coeffs[k];
            
            val[i]  = (global.coeffsSum!=0) ? dSum/global.coeffsSum : 0;
            valc[i] = (i>0) ? (val[i]>val[i-1]) ? 1 : (val[i]<val[i-1]) ? 2 : valc[i-1] : 0;
         }

   //
   //
   //

   return(rates_total);
}

//--------------------------------------------------------------------------------------------------
//                                                                  
//--------------------------------------------------------------------------------------------------
//
//
//

double iGetPrice(ENUM_APPLIED_PRICE price,double open, double high, double low, double close)
{
   switch (price)
   {
      case PRICE_CLOSE:     return(close);
      case PRICE_OPEN:      return(open);
      case PRICE_HIGH:      return(high);
      case PRICE_LOW:       return(low);
      case PRICE_MEDIAN:    return((high+low)/2.0);
      case PRICE_TYPICAL:   return((high+low+close)/3.0);
      case PRICE_WEIGHTED:  return((high+low+close+close)/4.0);
   }
   return(0);
}

]]