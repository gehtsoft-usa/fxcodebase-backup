//+------------------------------------------------------------------+
//|                                                Other_Candles.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 6

extern color UpBarColor = MediumSeaGreen;
extern color DnBarColor = Orange;

double UpBody[], UpH[], UpL[], DnBody[], DnH[], DnL[];

int init()
  {
   IndicatorShortName("Other candles");
   IndicatorDigits(Digits);

   SetIndexBuffer( 0, UpBody );
   SetIndexBuffer( 1, UpH );
   SetIndexBuffer( 2, UpL );
   SetIndexBuffer( 3, DnBody );
   SetIndexBuffer( 4, DnH );
   SetIndexBuffer( 5, DnL );

   SetIndexStyle( 0, DRAW_HISTOGRAM, DRAW_LINE, 4, UpBarColor );
   SetIndexStyle( 1, DRAW_HISTOGRAM, DRAW_LINE, 1, UpBarColor );
   SetIndexStyle( 2, DRAW_HISTOGRAM, DRAW_LINE, 1, UpBarColor );
   SetIndexStyle( 3, DRAW_HISTOGRAM, DRAW_LINE, 4, DnBarColor );
   SetIndexStyle( 4, DRAW_HISTOGRAM, DRAW_LINE, 1, DnBarColor );
   SetIndexStyle( 5, DRAW_HISTOGRAM, DRAW_LINE, 1, DnBarColor );

   SetIndexEmptyValue( 0, 0.0 );
   SetIndexEmptyValue( 1, 0.0 );
   SetIndexEmptyValue( 2, 0.0 );
   SetIndexEmptyValue( 3, 0.0 );
   SetIndexEmptyValue( 4, 0.0 );
   SetIndexEmptyValue( 5, 0.0 );

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
 int pos;
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 pos=limit;
 while(pos>=0)
 {
  if (Close[pos]>=Open[pos])
  {
   UpBody[pos]=Close[pos]-Open[pos];
   UpH[pos]=High[pos]-Open[pos];
   UpL[pos]=Low[pos]-Open[pos];
   DnBody[pos]=0;
   DnH[pos]=0;
   DnL[pos]=0;
  }
  else
  {
   DnBody[pos]=Close[pos]-Open[pos];
   DnH[pos]=High[pos]-Open[pos];
   DnL[pos]=Low[pos]-Open[pos];
   UpBody[pos]=0;
   UpH[pos]=0;
   UpL[pos]=0;
  }
  
  pos--;
 }

 return(0);
}

