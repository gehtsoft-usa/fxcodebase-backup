// Id: 16113
//+------------------------------------------------------------------+
//|                                                  GHLA_ST_Bar.mq4 |
//|                               Copyright � 2016, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2016, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Yellow

extern int GHLA_Length=10;
extern int ST_Length=14;
extern int ST_Shift=20;
extern bool ST_Use_Filter=true;

double UP[], DN[], NE[];

int init()
{
     double temp = iCustom(NULL, 0, "ST_Bar", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'ST_Bar' indicator");
       return INIT_FAILED;
   }
       
temp = iCustom(NULL, 0, "GHLA", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'GHLA' indicator");
       return INIT_FAILED;
   }
   IndicatorShortName("");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,UP);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,DN);
 SetIndexStyle(2,DRAW_HISTOGRAM);
 SetIndexBuffer(2,NE);

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
 double ST, GHLA;
 pos=limit;
 while(pos>=0)
 {
  ST=iCustom(NULL, 0, "ST_Bar", ST_Length, ST_Shift, ST_Use_Filter, 2, pos);
  GHLA=iCustom(NULL, 0, "GHLA", GHLA_Length, 0, pos);
  
  UP[pos]=0.; DN[pos]=0.; NE[pos]=0.;
  
  if (Close[pos]>ST && Close[pos]>GHLA)
  {
   UP[pos]=1.;
  }
  else
  {
   if (Close[pos]<ST && Close[pos]<GHLA)
   {
    DN[pos]=1.;
   }
   else
   {
    NE[pos]=1.;
   }
  }

  pos--;
 } 
 return(0);
}

