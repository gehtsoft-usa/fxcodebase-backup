//+------------------------------------------------------------------+
//|                                                 Multiple_CCI.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 8
#property indicator_color1 Red
#property indicator_color2 OrangeRed
#property indicator_color3 DeepPink
#property indicator_color4 Magenta
#property indicator_color5 Yellow
#property indicator_color6 Chartreuse
#property indicator_color7 LimeGreen
#property indicator_color8 Green

extern bool CCI1_Enable=true;
extern int CCI1_Length=5;
extern bool CCI2_Enable=true;
extern int CCI2_Length=10;
extern bool CCI3_Enable=true;
extern int CCI3_Length=15;
extern bool CCI4_Enable=true;
extern int CCI4_Length=20;
extern bool CCI5_Enable=true;
extern int CCI5_Length=25;
extern bool CCI6_Enable=true;
extern int CCI6_Length=30;
extern bool CCI7_Enable=true;
extern int CCI7_Length=35;
extern bool CCI8_Enable=true;
extern int CCI8_Length=40;
extern int Price=0;      // Applied price
                         // 0 - Close
                         // 1 - Open
                         // 2 - High
                         // 3 - Low
                         // 4 - Median
                         // 5 - Typical
                         // 6 - Weighted  

double CCI1[], CCI2[], CCI3[], CCI4[], CCI5[], CCI6[], CCI7[], CCI8[];

int init()
{
 IndicatorShortName("Multiple CCI");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,CCI1);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,CCI2);
 SetIndexStyle(2,DRAW_LINE);
 SetIndexBuffer(2,CCI3);
 SetIndexStyle(3,DRAW_LINE);
 SetIndexBuffer(3,CCI4);
 SetIndexStyle(4,DRAW_LINE);
 SetIndexBuffer(4,CCI5);
 SetIndexStyle(5,DRAW_LINE);
 SetIndexBuffer(5,CCI6);
 SetIndexStyle(6,DRAW_LINE);
 SetIndexBuffer(6,CCI7);
 SetIndexStyle(7,DRAW_LINE);
 SetIndexBuffer(7,CCI8);

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
 pos=limit;
 while(pos>=0)
 {
  if (CCI1_Enable)
  {
   CCI1[pos]=iCCI(NULL, 0, CCI1_Length, Price, pos);
  }
  else
  {
   CCI1[pos]=EMPTY_VALUE;
  }
  if (CCI2_Enable)
  {
   CCI2[pos]=iCCI(NULL, 0, CCI2_Length, Price, pos);
  }
  else
  {
   CCI2[pos]=EMPTY_VALUE;
  }
  if (CCI3_Enable)
  {
   CCI3[pos]=iCCI(NULL, 0, CCI3_Length, Price, pos);
  }
  else
  {
   CCI3[pos]=EMPTY_VALUE;
  }
  if (CCI4_Enable)
  {
   CCI4[pos]=iCCI(NULL, 0, CCI4_Length, Price, pos);
  }
  else
  {
   CCI4[pos]=EMPTY_VALUE;
  }
  if (CCI5_Enable)
  {
   CCI5[pos]=iCCI(NULL, 0, CCI5_Length, Price, pos);
  }
  else
  {
   CCI5[pos]=EMPTY_VALUE;
  }
  if (CCI6_Enable)
  {
   CCI6[pos]=iCCI(NULL, 0, CCI6_Length, Price, pos);
  }
  else
  {
   CCI6[pos]=EMPTY_VALUE;
  }
  if (CCI7_Enable)
  {
   CCI7[pos]=iCCI(NULL, 0, CCI7_Length, Price, pos);
  }
  else
  {
   CCI7[pos]=EMPTY_VALUE;
  }
  if (CCI8_Enable)
  {
   CCI8[pos]=iCCI(NULL, 0, CCI8_Length, Price, pos);
  }
  else
  {
   CCI8[pos]=EMPTY_VALUE;
  }
  
  pos--;
 } 
 return(0);
}

