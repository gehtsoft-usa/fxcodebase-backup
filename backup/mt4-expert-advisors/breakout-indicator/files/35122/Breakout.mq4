//+------------------------------------------------------------------+
//|                                                     Breakout.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Red
#property indicator_color2 Red
#property indicator_color3 Magenta
#property indicator_color4 Magenta

extern string PeriodBegin="00:00";
extern string PeriodEnd="05:00";
extern string BoxEnd="23:00";

int PeriodBeginMin, PeriodEndMin, BoxEndMin;

double UpperPeriod[], LowerPeriod[], UpperBox[], LowerBox[];

int ConvertTime(string StrTime)
{
 int PosStr=StringFind(StrTime,":");
 string H=StringSubstr(StrTime,0,PosStr);
 string M=StringSubstr(StrTime,PosStr+1);
 return (StrToDouble(H)*60+StrToDouble(M));
}

int init()
  {
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,UpperPeriod);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,LowerPeriod);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,UpperBox);
   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3,LowerBox);
  
   PeriodBeginMin=ConvertTime(PeriodBegin);
   PeriodEndMin=ConvertTime(PeriodEnd);
   BoxEndMin=ConvertTime(BoxEnd);
   Print(PeriodBeginMin,", ",PeriodEndMin,", ",BoxEndMin);
   return(0);
  }

int deinit()
  {

   return(0);
  }
  
int FindBar(string T, datetime CTime)
{
 string StrT_=TimeToStr(CTime, TIME_DATE)+" "+T;
 datetime T_=StrToTime(StrT_);
 if (T_>CTime) T_=T_-86400;
 int bar=iBarShift(NULL, 0, T_, false);
 return (bar);
}  

int start()
  {
   int i;
   int BeginBar, EndBar;
   double MinPrice, MaxPrice;
   if(Bars<=3) return(0);
   int ExtCountedBars=IndicatorCounted();
   if (ExtCountedBars<0) return(-1);
   int    pos=Bars-2;
   if(ExtCountedBars>2) pos=Bars-ExtCountedBars-1;
   while(pos>0)
     {
      int CurMin=TimeHour(Time[pos])*60+TimeMinute(Time[pos]);
      if ((PeriodEndMin>PeriodBeginMin && CurMin>=PeriodBeginMin && CurMin<=PeriodEndMin) || (PeriodEndMin<PeriodBeginMin && (CurMin>=PeriodBeginMin || CurMin<=PeriodEndMin)))
      {
       BeginBar=FindBar(PeriodBegin, Time[pos]);
       MaxPrice=High[iHighest(NULL, 0, MODE_HIGH, BeginBar-pos+1, pos)];
       MinPrice=Low[iLowest(NULL, 0, MODE_LOW, BeginBar-pos+1, pos)];
       for (i=BeginBar;i>=pos;i--)
       {
        UpperPeriod[i]=MaxPrice;
        LowerPeriod[i]=MinPrice;
       } 
      }
      
      if ((BoxEndMin>PeriodEndMin && CurMin>=PeriodEndMin && CurMin<=BoxEndMin) || (BoxEndMin<PeriodEndMin && (CurMin>=PeriodEndMin || CurMin<=BoxEndMin)))
      {
       BeginBar=FindBar(PeriodBegin, Time[pos]);
       EndBar=FindBar(PeriodEnd, Time[pos]);
       MaxPrice=High[iHighest(NULL, 0, MODE_HIGH, BeginBar-EndBar+1, EndBar)];
       MinPrice=Low[iLowest(NULL, 0, MODE_LOW, BeginBar-EndBar+1, EndBar)];
       for (i=EndBar;i>=pos;i--)
       {
        UpperBox[i]=MaxPrice;
        LowerBox[i]=MinPrice;
       } 
      }
      
      pos--;
     }

   return(0);
  }

