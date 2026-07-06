// More information about this indicator can be found at:
// http://fxcodebase.com/ 

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2021, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                              Support our efforts by donating   | 
//|                                                                 Paypal: https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+

//Your donations will allow the service to continue onward.
//+------------------------------------------------------------------------------------------------+
//|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
//|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
//|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
//|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
//|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
//|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
//|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
//|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
//+------------------------------------------------------------------------------------------------+




#property copyright "Copyright © 2021, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict
#property indicator_plots 4
#property indicator_buffers 8
#property indicator_chart_window
#property indicator_label1 "Hull"
#property indicator_type1  DRAW_LINE
#property indicator_color1 clrMediumSeaGreen
#property indicator_width1 2
#property indicator_label2 "Buy Buffer"
#property indicator_type2  DRAW_ARROW
#property indicator_color2 clrGreen
#property indicator_width2 1
#property indicator_label3 "Sell Buffer"
#property indicator_type3  DRAW_ARROW
#property indicator_color3 clrRed
#property indicator_width3 1
#property indicator_label4 "Hull - slope down"
#property indicator_type4  DRAW_LINE
#property indicator_color4 clrOrangeRed
#property indicator_width4 2

#property indicator_color5 clrNONE
#property indicator_color6 clrNONE
#property indicator_color7 clrNONE
#property indicator_color8 clrNONE

//
//
//

// NOTE: INPUTS
input int                inpPeriod  = 20;           // Period
input double             inpDivisor = 2.0;          // Divisor ("speed")
input ENUM_APPLIED_PRICE inpPrice   = PRICE_CLOSE;  // Price
input int                lookback   = 2;            // Sensibility

double val[], valda[], valdb[], valc[];
// ------------------------------------------------------------------
// NOTE: PINESCRIPT
int stddev_len = 21;
// double    HMA[];
double    concavity[];
double    sellBuffer[];
double    buyBuffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
	IndicatorBuffers(8);
   iHull.init(inpPeriod, inpDivisor);
   //--- hull buffers
   SetIndexBuffer(0, val, INDICATOR_DATA);
   SetIndexBuffer(1, buyBuffer,INDICATOR_DATA);
   SetIndexBuffer(2, sellBuffer,INDICATOR_DATA);
   SetIndexBuffer(3, valda, INDICATOR_DATA);
   SetIndexBuffer(4, valdb, INDICATOR_DATA);
   SetIndexBuffer(5, valc);
   SetIndexBuffer(6, concavity,INDICATOR_CALCULATIONS);
   SetIndexArrow(1,233); 
   SetIndexArrow(2,234); 

   
   
   IndicatorSetString(INDICATOR_SHORTNAME, "Hull (" + (string)inpPeriod + "," + (string)inpDivisor + ")");

   return (INIT_SUCCEEDED);

}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated, const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long&   tick_volume[],
                const long&   volume[],
                const int&    spread[])
{
   int i = rates_total - prev_calculated + 1;
   if (i >= rates_total) i = rates_total - 1;

   if (valc[i] == -1) iCleanPoint(i, valda, valdb);
   for (; i >= 0 && !_StopFlag; i--)
   {
      val[i]   = iHull.calculate(iMA(NULL, 0, 1, 0, MODE_SMA, inpPrice, i), rates_total - i - 1, rates_total);
      valc[i]  = (i < rates_total - 1) ? (val[i] > val[i + 1]) ? 1 : (val[i] < val[i + 1]) ? -1 : valc[i + 1] : 0;
      valda[i] = valdb[i] = EMPTY_VALUE;
      if (valc[i] == -1) iPlotPoint(i, valda, valdb, val);
      
      //--- 
      sellBuffer[i] = 0;
      buyBuffer[i]  = 0;
      if ((i < rates_total - (lookback + 1)))    
      {  
         // NOTE: val[i] = value HULL M.A
         
         double delta         = val[i+1] - val[i + lookback + 1];  // es la distancia (en puntos) entre la HMA1 y HMA4
         double delta_per_bar = delta / lookback;            // promedio de delta por vela
         double next_bar      = val[i+1] + delta_per_bar;      // HMA + delta por vela,
         concavity[i]         = val[i] > next_bar ? 1 : -1;
         double turning_point = concavity[i+1] != concavity[i] ? val[i] : NULL;
      //--- condicion entradas:
      sellBuffer[i] = turning_point != NULL && concavity[i] == -1 ? high[i] : 0;
      buyBuffer[i] = turning_point != NULL && concavity[i] == 1 ? low[i] :0;
      }
   }




   return (rates_total);
}

//------------------------------------------------------------------
// Custom function(s)
//------------------------------------------------------------------
//
//---
//

class CHull
{
  private:
   int    m_fullPeriod;
   int    m_halfPeriod;
   int    m_sqrtPeriod;
   int    m_arraySize;
   double m_weight1;
   double m_weight2;
   double m_weight3;
   struct sHullArrayStruct
   {
      double value;
      double value3;
      double wsum1;
      double wsum2;
      double wsum3;
      double lsum1;
      double lsum2;
      double lsum3;
   };
   sHullArrayStruct m_array[];

  public:
   CHull() : m_fullPeriod(1), m_halfPeriod(1), m_sqrtPeriod(1), m_arraySize(-1) {}
   ~CHull() { ArrayFree(m_array); }

   ///
   ///
   ///

   bool init(int period, double divisor)
   {
      m_fullPeriod = (int)(period > 1 ? period : 1);
      m_halfPeriod = (int)(m_fullPeriod > 1 ? m_fullPeriod / (divisor > 1 ? divisor : 1) : 1);
      m_sqrtPeriod = (int)MathSqrt(m_fullPeriod);
      m_arraySize  = -1;
      m_weight1 = m_weight2 = m_weight3 = 1;
      return (true);
   }

   //
   //
   //

   double calculate(double value, int i, int bars)
   {
      if (m_arraySize < bars)
      {
         m_arraySize = ArrayResize(m_array, bars + 500);
         if (m_arraySize < bars) return (0);
      }

      //
      //
      //

      m_array[i].value = value;
      if (i > m_fullPeriod)
      {
         m_array[i].wsum1 = m_array[i - 1].wsum1 + value * m_halfPeriod - m_array[i - 1].lsum1;
         m_array[i].lsum1 = m_array[i - 1].lsum1 + value - m_array[i - m_halfPeriod].value;
         m_array[i].wsum2 = m_array[i - 1].wsum2 + value * m_fullPeriod - m_array[i - 1].lsum2;
         m_array[i].lsum2 = m_array[i - 1].lsum2 + value - m_array[i - m_fullPeriod].value;
      } else
      {
         m_array[i].wsum1     = m_array[i].wsum2 =
             m_array[i].lsum1 = m_array[i].lsum2 = m_weight1 = m_weight2 = 0;
         for (int k = 0, w1 = m_halfPeriod, w2 = m_fullPeriod; w2 > 0 && i >= k; k++, w1--, w2--)
         {
            if (w1 > 0)
            {
               m_array[i].wsum1 += m_array[i - k].value * w1;
               m_array[i].lsum1 += m_array[i - k].value;
               m_weight1 += w1;
            }
            m_array[i].wsum2 += m_array[i - k].value * w2;
            m_array[i].lsum2 += m_array[i - k].value;
            m_weight2 += w2;
         }
      }
      m_array[i].value3 = 2.0 * m_array[i].wsum1 / m_weight1 - m_array[i].wsum2 / m_weight2;

      //
      //---
      //

      if (i > m_sqrtPeriod)
      {
         m_array[i].wsum3 = m_array[i - 1].wsum3 + m_array[i].value3 * m_sqrtPeriod - m_array[i - 1].lsum3;
         m_array[i].lsum3 = m_array[i - 1].lsum3 + m_array[i].value3 - m_array[i - m_sqrtPeriod].value3;
      } else
      {
         m_array[i].wsum3 =
             m_array[i].lsum3 = m_weight3 = 0;
         for (int k = 0, w3 = m_sqrtPeriod; w3 > 0 && i >= k; k++, w3--)
         {
            m_array[i].wsum3 += m_array[i - k].value3 * w3;
            m_array[i].lsum3 += m_array[i - k].value3;
            m_weight3 += w3;
         }
      }
      return (m_array[i].wsum3 / m_weight3);
   }
};
CHull iHull;

//
//
//

void iCleanPoint(int i, double& first[], double& second[])
{
   if (i >= Bars - 3) return;
   if ((second[i] != EMPTY_VALUE) && (second[i + 1] != EMPTY_VALUE))
      second[i + 1] = EMPTY_VALUE;
   else if ((first[i] != EMPTY_VALUE) && (first[i + 1] != EMPTY_VALUE) && (first[i + 2] == EMPTY_VALUE))
      first[i + 1] = EMPTY_VALUE;
}
void iPlotPoint(int i, double& first[], double& second[], double& from[])
{
   if (i >= Bars - 2) return;
   if (first[i + 1] == EMPTY_VALUE)
      if (first[i + 2] == EMPTY_VALUE)
      {
         first[i]     = from[i];
         first[i + 1] = from[i + 1];
         second[i]    = EMPTY_VALUE;
      } else
      {
         second[i]     = from[i];
         second[i + 1] = from[i + 1];
         first[i]      = EMPTY_VALUE;
      }
   else
   {
      first[i]  = from[i];
      second[i] = EMPTY_VALUE;
   }
}
