//+------------------------------------------------------------------+
//|                               Copyright © 2017, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                         Donate / Support:  https://goo.gl/9Rj74e |
//|                     BitCoin: 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  | 
//+------------------------------------------------------------------+

#property copyright "Copyright © 2017, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"


#property copyright ""
#property link      ""

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Red

extern int MA_Period=10;
extern int MA_Step=5;

double ExtMapBuffer[];


int init()
  {
   SetIndexBuffer(0,ExtMapBuffer);
   SetIndexStyle(0,DRAW_LINE);
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));

   return(0);
  }

int deinit()
  {

   return(0);
  }

int start()
  {
   if(Bars<=MA_Period*MA_Step) return(0);
   int ExtCountedBars=IndicatorCounted();
   if (ExtCountedBars<0) return(-1);
   if (ExtCountedBars>0) ExtCountedBars--;
   int    pos=Bars-2;
   if(ExtCountedBars>2) pos=Bars-ExtCountedBars-1;
   while(pos>=0)
     {
      double Sum=0;
      for (int i=0;i<MA_Period;i++)
      {
       Sum+=Close[pos+i*MA_Step];
      }
      ExtMapBuffer[pos]=Sum/MA_Period;
      pos--;
     }
   

   return(0);
  }


