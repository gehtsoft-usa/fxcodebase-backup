//+------------------------------------------------------------------+
//|                                                        KMAMA.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red

extern int Short_Lenght=25;
extern int Long_Lenght=50;

double KMAMA[], KMAMA_Dn[];

int init()
{
 IndicatorShortName("KMAMA");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,KMAMA);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,KMAMA_Dn);

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
 double Short_MA, Long_MA;
 pos=limit;
 while(pos>=0)
 {
  Short_MA=iMA(NULL, 0, Short_Lenght, 0, MODE_SMA, PRICE_CLOSE, pos);
  Long_MA=iMA(NULL, 0, Long_Lenght, 0, MODE_SMA, PRICE_CLOSE, pos);
  
  if (Long_MA!=0.)
  {
   KMAMA[pos]=100.*Short_MA/Long_MA-100.;
  }
  else
  {
   KMAMA[pos]=EMPTY_VALUE;
  } 
  
  if (KMAMA[pos]>KMAMA[pos+1])
  {
   KMAMA_Dn[pos]=EMPTY_VALUE;
  }
  else
  {
   KMAMA_Dn[pos]=KMAMA[pos];
  }

  pos--;
 } 
 return(0);
}

