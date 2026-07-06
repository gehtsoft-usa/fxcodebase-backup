//+------------------------------------------------------------------+
//|                               Copyright © 2017, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                         Donate / Support:  https://goo.gl/9Rj74e |
//|                     BitCoin: 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  | 
//+------------------------------------------------------------------+

#property copyright "Copyright © 2017, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window

#property indicator_buffers 3
#property indicator_color1 Red
#property indicator_color2 Blue
#property indicator_color3 Yellow


extern int LookbackPeriod=40; // Period of indicator
extern int PowerPeriod=10;    // Period of EMA

double Power[], BearPower[], BullPower[];

int init()
  {
   IndicatorShortName("Total power");
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,Power);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,BearPower);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,BullPower);

   return(0);
  }

int deinit()
  {

   return(0);
  }

int start()
  {
   if(Bars<=LookbackPeriod) return(0);
   int ExtCountedBars=IndicatorCounted();
   if (ExtCountedBars<0) return(-1);
   int    pos=Bars-2;
   if(ExtCountedBars>2) pos=Bars-ExtCountedBars-1;
   while(pos>=0)
   {
    double BullCount=0;
    double BearCount=0;
    for (int i=0;i<=LookbackPeriod-1;i++)
    {
     double EMA=iMA(NULL, 0 , PowerPeriod, 0, MODE_EMA, PRICE_CLOSE, pos+i);
     if (High[pos+i]>EMA) BullCount++;
     if (Low[pos+i]<EMA) BearCount++;
    }
    BearPower[pos]=BearCount*100/LookbackPeriod;
    BullPower[pos]=BullCount*100/LookbackPeriod;
    Power[pos]=MathAbs(BearCount-BullCount)*100/LookbackPeriod;
   
    pos--;
   } 
   return(0);
  }


