//+------------------------------------------------------------------+
//|                                                   MA_Candles.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 4

extern int MA_Period=10;
extern int MA_Method=0;
extern color UpBarColor = MediumSeaGreen;
extern color DnBarColor = Orange;

//Indicator Buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];

int init()
  {
   IndicatorShortName("Moving averages candles");
   IndicatorDigits(Digits);

   SetIndexBuffer( 0, ExtMapBuffer1 );
   SetIndexBuffer( 1, ExtMapBuffer2 );
   SetIndexBuffer( 2, ExtMapBuffer3 );
   SetIndexBuffer( 3, ExtMapBuffer4 );

   SetIndexStyle( 0, DRAW_HISTOGRAM, DRAW_LINE, 1, UpBarColor );
   SetIndexStyle( 1, DRAW_HISTOGRAM, DRAW_LINE, 1, DnBarColor );
   SetIndexStyle ( 2, DRAW_HISTOGRAM, DRAW_LINE, 4, UpBarColor );
   SetIndexStyle( 3, DRAW_HISTOGRAM, DRAW_LINE, 4, DnBarColor );

   SetIndexEmptyValue( 0, 0.0 );
   SetIndexEmptyValue( 1, 0.0 );
   SetIndexEmptyValue( 2, 0.0 );
   SetIndexEmptyValue( 3, 0.0 );

   return(0);
  }

int deinit()
  {

   return(0);
  }

int start()
{
 if(Bars<=MA_Period) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 if (ExtCountedBars>0) ExtCountedBars--;
 int    pos=Bars-2;
 if(ExtCountedBars>2) pos=Bars-ExtCountedBars-1;
 double MA_Open, MA_Close, MA_High, MA_Low;
 while(pos>=0)
 {
  MA_Open=iMA(NULL, 0, MA_Period, 0, MA_Method, PRICE_OPEN, pos);   
  MA_Close=iMA(NULL, 0, MA_Period, 0, MA_Method, PRICE_CLOSE, pos);   
  MA_High=iMA(NULL, 0, MA_Period, 0, MA_Method, PRICE_HIGH, pos);   
  MA_Low=iMA(NULL, 0, MA_Period, 0, MA_Method, PRICE_LOW, pos);   
  if (MA_Open<MA_Close)
  {
   ExtMapBuffer1[pos]=MA_High;
   ExtMapBuffer2[pos]=MA_Low;
  }
  else
  {
   ExtMapBuffer1[pos]=MA_Low;
   ExtMapBuffer2[pos]=MA_High;
  }
  ExtMapBuffer3[pos]=MA_Close;
  ExtMapBuffer4[pos]=MA_Open;
  pos--;
 } 

 return(0);
}

