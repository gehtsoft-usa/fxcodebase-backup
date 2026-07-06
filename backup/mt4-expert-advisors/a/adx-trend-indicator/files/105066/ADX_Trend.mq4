//+------------------------------------------------------------------+
//|                                                    ADX_Trend.mq4 |
//|                               Copyright © 2016, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2016, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red

extern int ADX1_Length=10;
extern int ADX2_Length=14;
extern int ADX3_Length=20;
extern double Level1=35.;
extern double Level2=30.;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  
extern int Label_Size=2;

double ADXT_Up[], ADXT_Dn[];

int init()
{
 IndicatorShortName("ADX Trend indicator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_ARROW,0,Label_Size);
 SetIndexArrow(0,119);
 SetIndexBuffer(0,ADXT_Up);
 SetIndexStyle(1,DRAW_ARROW,0,Label_Size);
 SetIndexArrow(1,119);
 SetIndexBuffer(1,ADXT_Dn);

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
 double ADX1_0, ADX2_0, ADX3_0, ADX1_1, ADX2_1, ADX3_1, DMI;
 pos=limit;
 while(pos>=0)
 {
  ADX1_0=iADX(NULL, 0, ADX1_Length, Price, 0, pos);
  ADX2_0=iADX(NULL, 0, ADX2_Length, Price, 0, pos);
  ADX3_0=iADX(NULL, 0, ADX3_Length, Price, 0, pos);
  ADX1_1=iADX(NULL, 0, ADX1_Length, Price, 0, pos+1);
  ADX2_1=iADX(NULL, 0, ADX2_Length, Price, 0, pos+1);
  ADX3_1=iADX(NULL, 0, ADX3_Length, Price, 0, pos+1);
  
  DMI=iADX(NULL, 0, ADX1_Length, Price, 1, pos)-iADX(NULL, 0, ADX1_Length, Price, 2, pos);
  
  ADXT_Up[pos]=EMPTY_VALUE;
  ADXT_Dn[pos]=EMPTY_VALUE;
  
  if (ADX1_1<ADX1_0 && ADX2_1<ADX2_0 && ADX3_1<ADX3_0 && ADX1_0>Level1 && ADX2_0>Level2)
  {
   if (DMI>0.)
   {
    ADXT_Up[pos]=High[pos];
   }
   else
   {
    ADXT_Dn[pos]=Low[pos];
   }
  }

  pos--;
 } 
 
 return(0);
}

