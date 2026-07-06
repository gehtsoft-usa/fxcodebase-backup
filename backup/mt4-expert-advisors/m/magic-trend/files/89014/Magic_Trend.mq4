//+------------------------------------------------------------------+
//|                                                  Magic_Trend.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Gray
#property indicator_color2 Green
#property indicator_color3 Red

extern int CCI_Length=50;
extern int ATR_Length=5;

double MT[], MT_Up[], MT_Dn[];

int init()
{
 IndicatorShortName("Magic trend");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,MT);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,MT_Up);
 SetIndexStyle(2,DRAW_LINE);
 SetIndexBuffer(2,MT_Dn);

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
 double CCI;
 double ATR;
 pos=limit;
 while(pos>=0)
 {
  if (MT[pos+1]==0 || MT[pos+1]==EMPTY_VALUE)
  {
   CCI=iCCI(NULL, 0, CCI_Length, PRICE_TYPICAL, pos+1);
   ATR=iATR(NULL, 0, ATR_Length, pos+1);
   if (CCI>0) 
   {
    MT[pos+1]=Low[pos+1]-ATR;
   }
   else
   {
    MT[pos+1]=High[pos+1]+ATR;
   }
  }
  
  CCI=iCCI(NULL, 0, CCI_Length, PRICE_TYPICAL, pos);
  ATR=iATR(NULL, 0, ATR_Length, pos);
  if (CCI>0)
  {
   MT[pos]=MathMax(MT[pos+1], Low[pos]-ATR);
  }
  else
  {
   MT[pos]=MathMin(MT[pos+1], High[pos]+ATR);
  }
  if (MT[pos]>MT[pos+1])
  {
   MT_Up[pos+1]=MT[pos+1];
   MT_Up[pos]=MT[pos];
   MT_Dn[pos]=EMPTY_VALUE;
  }
  else
  {
   if (MT[pos]<MT[pos+1])
   {
    MT_Dn[pos+1]=MT[pos+1];
    MT_Dn[pos]=MT[pos];
    MT_Up[pos]=EMPTY_VALUE;
   }
   else
   {
    MT_Up[pos]=EMPTY_VALUE;
    MT_Dn[pos]=EMPTY_VALUE;
   }
  }
  pos--;
 } 
 return(0);
}

