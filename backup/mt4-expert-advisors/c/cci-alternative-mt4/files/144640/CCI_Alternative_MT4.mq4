// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=71765

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
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




#property copyright "Copyright © 2022, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
// ------------------------------------------------------------------
#property indicator_buffers 4
#property indicator_plots 2
#property indicator_separate_window
//--- plot Linea1
#property indicator_label1 "CCI up"
#property indicator_type1  DRAW_LINE
#property indicator_color1 clrSkyBlue
#property indicator_style1 STYLE_SOLID
#property indicator_width1 2
#property indicator_label2 "CCI down"
#property indicator_type2  DRAW_LINE
#property indicator_color2 clrDodgerBlue
#property indicator_style2 STYLE_SOLID
#property indicator_width2 2
// ------------------------------------------------------------------
input int inpPeriod = 14;  // CCI period
// ------------------------------------------------------------------
//--- indicator buffers
double up[];
double down[];
double cci[];
double prices[];

int OnInit()
{
   SetIndexBuffer(0, up, INDICATOR_DATA);
   SetIndexBuffer(1, down, INDICATOR_DATA);
   SetIndexBuffer(2, cci);
   SetIndexBuffer(3, prices);
   SetIndexStyle(2, DRAW_NONE, 0, 0);
   SetIndexStyle(3, DRAW_NONE, 0, 0);
   SetLevelValue(0, 0);
   SetLevelStyle(STYLE_DOT, 1, clrBlack);
   IndicatorDigits(6);
   IndicatorSetString(INDICATOR_SHORTNAME, "CCI (alternative)(" + (string)inpPeriod + ")");

   return (INIT_SUCCEEDED);
}

int OnCalculate(const int       rates_total,
                const int       prev_calculated,
                const datetime& time[],
                const double&   open[],
                const double&   high[],
                const double&   low[],
                const double&   close[],
                const long&     tick_volume[],
                const long&     volume[],
                const int&      spread[])
{
   int limit;
   if (prev_calculated == 0) { limit = rates_total - inpPeriod; } else { limit = prev_calculated + 1; }	

   for (int i = limit; i >= 0; i--)
   {
      
      prices[i] = (high[ArrayMaximum(high, inpPeriod, i)] + low[ArrayMinimum(low, inpPeriod, i)] + close[i]) / 3;

      double avg = 0;
      for (int k = 0; k < inpPeriod; k++) { avg += prices[i + k]; }
      avg = avg / inpPeriod;

      double dev = 0;
      for (int j = 0; j < inpPeriod; j++) { dev += MathAbs(prices[i + j] - avg); }
      dev /= inpPeriod;

      cci[i] = (prices[i]-avg)/(0.015*dev);

      if ( cci[i] >= cci[i+1] )   
      {
         up[i] = cci[i];
         up[i+1] = cci[i+1];
      } else
      {
         down[i] = cci[i];
         down[i+1] = cci[i+1];
      }
     }
   return (i);
}
//+------------------------------------------------------------------+