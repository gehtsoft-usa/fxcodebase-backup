/* HEADER:BEGIN */
// More information about this indicator can be found at:
// http://fxcodebase.com/

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2023, Gehtsoft USA LLC  |
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |
//+------------------------------------------------------------------------------------------------+
/* HEADER:END */

#property copyright "Copyright © 2024, Gehtsoft USA LLC"
#property link "http://fxcodebase.com"
#property version "1.0"
#property strict
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1

#property indicator_label1  "Waves"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrLimeGreen,clrPaleVioletRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

//
//
//
//
//

input int   Period1      = 34;             // Period 1
input int   Period2      = 45;             // Period 2
input int   Period3      = 53;             // Period 3
input int   SmoothPeriod = 10;             // Smoothing period
input color ColorFrom    = clrOrange;      // Color down
input color ColorTo      = clrLime;        // Color Up
input int   ColorSteps   = 50;             // Color steps for drawing


//
//
//
//
//

double wave[];
double wavec[];

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//
//
//

int cSteps;
int OnInit()
{
   SetIndexBuffer(0,wave,INDICATOR_DATA); 
   SetIndexBuffer(1,wavec,INDICATOR_COLOR_INDEX); 
             cSteps = (ColorSteps>1) ? ColorSteps : 2;
             PlotIndexSetInteger(0,PLOT_COLOR_INDEXES,cSteps+1);
               for (int i=0;i<cSteps+1;i++) 
                     PlotIndexSetInteger(0,PLOT_LINE_COLOR,i,gradientColor(i,cSteps+1,ColorFrom,ColorTo));
   IndicatorSetString(INDICATOR_SHORTNAME,"TTM waves ("+(string)Period1+","+(string)Period2+","+(string)Period3+")");
   return(0);
}

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//
//
//

int totalBars;
double work[][3];
#define _diff1 0
#define _diff2 1
#define _diff3 2
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
{
   if (ArrayRange(work,0)!=rates_total) ArrayResize(work,rates_total); totalBars = rates_total;

   //
   //
   //
   //
   //

   for (int i=(int)MathMax(prev_calculated-1,1); i<rates_total; i++)
   {
      double price = (open[i-1] + close[i-1]) * 0.375 + close[i] * 0.25;
      double xma1  = iLinr(price,Period1,i,0);
      double xma2  = iLinr(price,Period2,i,1);
      double xma3  = iLinr(price,Period3,i,2);
         work[i][_diff1] = iLinr(xma1-price,SmoothPeriod,i,3);
         work[i][_diff2] = iLinr(xma2-price,SmoothPeriod,i,4);
         work[i][_diff3] = iLinr(xma3-price,SmoothPeriod,i,5);
               wave[i]   = 0;  for (int k=0; k<Period2 && (i-k)>=0; k++) wave[i] -= (2.0*work[i-k][_diff1]+work[i-k][_diff2]+work[i-k][_diff3])/4.0;

      //
      //
      //
      //
      //
      
      double min = wave[i];
      double max = wave[i];
      double col = 0;
      for(int k=1;  k<ColorSteps && (i-k)>=0; k++)
      {
         min = (wave[i-k]<min) ? wave[i-k] : min;
         max = (wave[i-k]>max) ? wave[i-k] : max;
      }
      if((max-min) == 0)
            col = 50;
      else  col = 100 * (wave[i]-min)/(max-min);         
      wavec[i] = MathFloor(col*cSteps/100.0);                                  
   }
   return(rates_total);
}


//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

double workLinr[][6];
double iLinr(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workLinr,0)!= totalBars) ArrayResize(workLinr,totalBars);

   //
   //
   //
   //
   //
   
      period = MathMax(period,1);
      workLinr[r][instanceNo] = price;
         double lwmw = period; double lwma = lwmw*price;
         double sma  = price;
         for(int k=1; k<period && (r-k)>=0; k++)
         {
            double weight = period-k;
                   lwmw  += weight;
                   lwma  += weight*workLinr[r-k][instanceNo];  
                   sma   +=        workLinr[r-k][instanceNo];
         }             
   
   return(3.0*lwma/lwmw-2.0*sma/period);
}


//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

color getColor(int stepNo, int totalSteps, color from, color to)
{
   double stes = (double)totalSteps-1.0;
   double step = (from-to)/(stes);
   return((color)round(from-step*stepNo));
}
color gradientColor(int step, int totalSteps, color from, color to)
{
   color newBlue  = getColor(step,totalSteps,(from & 0XFF0000)>>16,(to & 0XFF0000)>>16)<<16;
   color newGreen = getColor(step,totalSteps,(from & 0X00FF00)>> 8,(to & 0X00FF00)>> 8) <<8;
   color newRed   = getColor(step,totalSteps,(from & 0X0000FF)    ,(to & 0X0000FF)    )    ;
   return(newBlue+newGreen+newRed);
}


/* FOOTER:BEGIN */
//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+

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
/* FOOTER:END */