// Id: 20333
// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=65625

//+------------------------------------------------------------------+
//|                               Copyright © 2018, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                    Paypal: https://goo.gl/9Rj74e |
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+

#property copyright "Copyright � 2018, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Green
#property indicator_color2 Blue
#property indicator_color3 Red

extern int Length=14;
extern double Fast_Level=5.;
extern double Slow_Level=2.5;
extern int ROC_Length=1;

double Fast[], Moderate[], Slow[];

int init()
{
     double temp = iCustom(NULL, 0, "Wilders DMI", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'Wilders DMI' indicator");
       return INIT_FAILED;
   }
   IndicatorShortName("ADX ROC oscillator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,Fast);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,Moderate);
 SetIndexStyle(2,DRAW_HISTOGRAM);
 SetIndexBuffer(2,Slow);

 return(0);
}

int deinit()
{

 return(0);
}

int start()
{
 if(Bars<=3) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 double ADX0, ADX_ROC;
 double diff;
 pos=limit;
 while(pos>=0)
 {
  ADX0=iCustom(NULL, 0, "Wilders DMI", "Current time frame", Length, 2, pos);
  ADX_ROC=iCustom(NULL, 0, "Wilders DMI", "Current time frame", Length, 2, pos+ROC_Length);
  diff=MathAbs(ADX0-ADX_ROC);
  Fast[pos]=0.;
  Moderate[pos]=0.;
  Slow[pos]=0.;
  
  if (diff>=Fast_Level)
  {
   Fast[pos]=1.;
  }
  else
  {
   if (diff<=Slow_Level)
   {
    Slow[pos]=1.;
   }
   else
   {
    Moderate[pos]=1.;
   }
  }

  pos--;
 } 
 return(0);
}

