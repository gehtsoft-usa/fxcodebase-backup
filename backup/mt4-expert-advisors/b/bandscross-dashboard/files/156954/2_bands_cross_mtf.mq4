// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=75274

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                https://appliedmachinelearning.systems/contact/ | 
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal:  https://goo.gl/9Rj74e   |
//|                                                             Patreon :  http://tiny.cc/1ybwxz   |   
//|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2024, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict
#property indicator_separate_window
#property indicator_buffers 3

//
//
//

enum enTimeFrames
{
         tf_cu  = 0,                                                 // Current time frame
         tf_m1  = PERIOD_M1,                                         // 1 minute
         tf_m5  = PERIOD_M5,                                         // 5 minutes
         tf_m15 = PERIOD_M15,                                        // 15 minutes
         tf_m30 = PERIOD_M30,                                        // 30 minutes
         tf_h1  = PERIOD_H1,                                         // 1 hour
         tf_h4  = PERIOD_H4,                                         // 4 hours
         tf_d1  = PERIOD_D1,                                         // Daily
         tf_w1  = PERIOD_W1,                                         // Weekly
         tf_mn1 = PERIOD_MN1,                                        // Monthly
         tf_n1  = -1,                                                // First higher time frame
         tf_n2  = -2,                                                // Second higher time frame
         tf_n3  = -3,                                                // Third higher time frame
         tf_cus = 12345678                                           // Custom time frame
      };
input enTimeFrames       inpTimeFrame           = tf_cu;             // Time frame to use
input int                inpTimeFrameCustom     = 0;                 // Custom time frame to use (if custom time frame used)  
input int                B1Period               = 20;                // First band period
input ENUM_APPLIED_PRICE B1Price                = PRICE_CLOSE;       // First band price
input int                B2Period               = 40;                // Second band period
input ENUM_APPLIED_PRICE B2Price                = PRICE_CLOSE;       // Second band price
input double             Deviation              = 1;                 // Bands deviation 
input int                HistoWidth             = 2;                 // Histogram bars width
input color              UpHistoColor           = clrMediumSlateBlue;      // Bullish histogram color
input color              DnHistoColor           = clrMediumVioletRed;            // Bearish histogram color
input color              NuHistoColor           = clrYellow;           // Neutral histogram color

double huu[],hdd[],hnn[],valc[],count[];
struct sGlobalStruct
{
   string indicatorFileName;
   int    indicatorTimeFrame;
   int    tfcustom;
};
sGlobalStruct global;
#define _mtfCall(_buff,_ind) iCustom(_Symbol,global.indicatorTimeFrame,global.indicatorFileName,tf_cu,0,B1Period,B1Price,B2Period,B2Price,Deviation,HistoWidth,UpHistoColor,DnHistoColor,NuHistoColor,_buff,_ind)

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   IndicatorBuffers(5);
   SetIndexBuffer(0,huu,INDICATOR_DATA); SetIndexStyle(0,DRAW_HISTOGRAM,EMPTY,HistoWidth,UpHistoColor);
   SetIndexBuffer(1,hdd,INDICATOR_DATA); SetIndexStyle(1,DRAW_HISTOGRAM,EMPTY,HistoWidth,DnHistoColor);   
   SetIndexBuffer(2,hnn,INDICATOR_DATA); SetIndexStyle(2,DRAW_HISTOGRAM,EMPTY,HistoWidth,NuHistoColor);
   SetIndexBuffer(3,valc, INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,count,INDICATOR_CALCULATIONS);
   
   IndicatorSetDouble(INDICATOR_MINIMUM,0);
   IndicatorSetDouble(INDICATOR_MAXIMUM,1);
   
   global.indicatorFileName = WindowExpertName();
   if (inpTimeFrameCustom==0) global.tfcustom =(enTimeFrames)timeFrameValue(inpTimeFrameCustom);
   global.indicatorTimeFrame = (inpTimeFrame!=tf_cus) ? (enTimeFrames)timeFrameValue(inpTimeFrame) : (enTimeFrames)inpTimeFrameCustom;
   
   IndicatorSetString(INDICATOR_SHORTNAME,timeFrameToString(global.indicatorTimeFrame)+" 2 Bands cross ("+(string)B1Period+","+(string)B2Period+")");
return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   int i,r,limit = fmin(rates_total-prev_calculated+1,rates_total-1); count[0]=limit;
      if (global.indicatorTimeFrame!=_Period)
      {
         limit = (int)fmax(limit,fmin(rates_total-1,_mtfCall(4,0)*global.indicatorTimeFrame/_Period));
         for(i=limit; i>=0; i--)
         {
            int y = iBarShift(NULL,global.indicatorTimeFrame,time[i]);
               huu[i] = _mtfCall(0,y);
               hdd[i] = _mtfCall(1,y); 
               hnn[i] = _mtfCall(2,y);                                     
         }   
	return(rates_total);
	}    
         
   //
   //
   //
   
   struct bbStruct
   {
     double bu1;
     double bu2;
     double bd1;
     double bd2;
   };
   static bbStruct wrk[];
   static int        wrkSize = -1;
                 if (wrkSize<rates_total) wrkSize = ArrayResize(wrk,rates_total+500);
   
   //
   //
   //
   
   for(i=limit, r=rates_total-limit-1; i>=0; i--,r++)
   {
      wrk[r].bu1 = iBands(_Symbol,_Period,B1Period,Deviation,0,B1Price,MODE_UPPER,i);
      wrk[r].bu2 = iBands(_Symbol,_Period,B2Period,Deviation,0,B2Price,MODE_UPPER,i);
      wrk[r].bd1 = iBands(_Symbol,_Period,B1Period,Deviation,0,B1Price,MODE_LOWER,i);
      wrk[r].bd2 = iBands(_Symbol,_Period,B2Period,Deviation,0,B2Price,MODE_LOWER,i);
      valc[i] = (wrk[r].bu1>wrk[r].bu2 && wrk[r].bd1>wrk[r].bd2) ? 1 : (wrk[r].bd1<wrk[r].bd2 && wrk[r].bu1<wrk[r].bu2) ? -1 : 0; 
      huu[i]  = (valc[i]== 1)                                ? 1 : EMPTY_VALUE;
      hdd[i]  = (valc[i]==-1)                                ? 1 : EMPTY_VALUE;  
      hnn[i]  = (huu[i]==EMPTY_VALUE && hdd[i]==EMPTY_VALUE) ? 1 : EMPTY_VALUE; 
   }
return(rates_total);
}

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}
int timeFrameValue(int _tf)
{
   int add  = (_tf>=0) ? 0 : fabs(_tf);
   if (add != 0) _tf = _Period;
   int size = ArraySize(iTfTable); 
      int i =0; for (;i<size; i++) if (iTfTable[i]==_tf) break;
                                   if (i==size) return(_Period);
                                                return(iTfTable[(int)MathMin(i+add,size-1)]);
}
//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal:  https://goo.gl/9Rj74e   |
//|                                                             Patreon :  http://tiny.cc/1ybwxz   |   
//|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
//+------------------------------------------------------------------------------------------------+
//|  Cryptocurrency  |  Network                    |  Address                                      |
//+------------------------------------------------+-----------------------------------------------+
//|  USDT            |  ERC20 (ETH Ethereum)       |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
//|  USDT            |  TRC20 (Tron)               |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
//|  USDT            |  BEP20 (BSC BNB Smart Chain)|  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  Matic Polygon              |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  SOL Solana                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
//|  USDT            |  ARBITRUM Arbitrum One      |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//+------------------------------------------------+-----------------------------------------------+ 