// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=69192


//+------------------------------------------------------------------+
//|                               Copyright © 2019, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  | 
//|                                    Paypal: https://goo.gl/9Rj74e |
//+------------------------------------------------------------------+
//|                                Patreon :  https://goo.gl/GdXWeN  |  
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
//|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
//+------------------------------------------------------------------+
 
#property strict
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2

#property indicator_label1  "Red"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_width1  2 

#property indicator_label2  "Blue"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrBlue
#property indicator_width2  2

//#property indicator_label3  "White"
//#property indicator_type3   DRAW_SECTION
//#property indicator_color3  clrWhite
//#property indicator_style3  STYLE_SOLID
//#property indicator_width3  1
//--- input parameters
input ENUM_TIMEFRAMES TimeFrame=0;
input int      RSIPeriod = 12;
input int      MFIPeriod = 13;
input int      STOCHPeriodK = 25;
input int      STOCHPeriodD = 3;
input int      STOCHSlowing = 3;
input int      MfiHigh = 78;
input int      MfiLow = 22;
input int      RsiHigh = 70;
input int      RsiLow = 30;
input int      StochHigh = 80;
input int      StochLow = 20;
//--- indicator buffers
double         Buffer1[];
double         Buffer2[];

int n=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0,Buffer1);
   SetIndexStyle(0,DRAW_LINE);

   SetIndexBuffer(1,Buffer2);
   SetIndexStyle(1,DRAW_LINE);

   SetIndexEmptyValue(0,-1);
   SetIndexEmptyValue(1,-1);

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   datetime TimeArray[];
   int    i,limit,y=0,counted_bars=IndicatorCounted();

// Plot defined time frame on to current time frame
   ArrayCopySeries(TimeArray,MODE_TIME,Symbol(),TimeFrame);

   limit=Bars-counted_bars;
   for(i=0,y=0;i<limit;i++)
     {
      if(Time[i]<TimeArray[y]) y++;

      double mfi = iMFI(NULL, TimeFrame, MFIPeriod, y);
      double rsi = iRSI(NULL, TimeFrame, RSIPeriod, PRICE_CLOSE, y);
      double stoch = iStochastic(NULL, TimeFrame, STOCHPeriodK,STOCHPeriodD,STOCHSlowing, MODE_SMA, 1, MODE_MAIN, y);

      if(mfi>=MfiHigh && rsi>=RsiHigh && stoch>=StochHigh)
        {
         Buffer1[i]=High[i];
        }
      else Buffer1[i]=-1;
      if(mfi<=MfiLow && rsi<=RsiLow && stoch<=StochLow)
        {
         Buffer2[i]=Low[i];
        }
      else Buffer2[i]=-1;

     }

   return(0);
  }
//+------------------------------------------------------------------+
