//+------------------------------------------------------------------+
//|                                                  Connors_RSI.mq4 |
//|                               Copyright © 2015, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Yellow

extern int RSI_Closes_Length=3;
extern int RSI_UpClose_Length=2;
extern int Percent_Rank_Length=100;
extern double Overbought_Level=70.;
extern double Oversold_Level=30.;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double CRSI[];
double UpDown[], RSI[];

int init()
{
 IndicatorShortName("Connors RSI");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,CRSI);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,UpDown);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,RSI);

 SetLevelValue(0, Overbought_Level);
 SetLevelValue(1, Oversold_Level);

 return(0);
}

int deinit()
{

 return(0);
}

double Percent_Rank(int index)
{
 int i;
 int Count=0;
 for (i=1;i<=Percent_Rank_Length;i++)
 {
  if (RSI[index]>RSI[index+i])
  {
   Count++;
  }
 }
 
 return (100.*(0.+Count)/(0.+Percent_Rank_Length));
}

int start()
{
 if(Bars<=3) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 double Pr0, Pr1;
 pos=limit;
 while(pos>=0)
 {
  Pr0=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
  Pr1=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos+1);
  
  if (Pr0>Pr1)
  {
   if (UpDown[pos+1]>0.)
   {
    UpDown[pos]=UpDown[pos+1]+1.;
   }
   else
   {
    UpDown[pos]=1.;
   }
  }
  else
  {
   if (Pr0<Pr1)
   {
    if (UpDown[pos+1]<0.)
    {
     UpDown[pos]=UpDown[pos+1]-1.;
    }
    else
    {
     UpDown[pos]=-1.;
    }
   }
   else
   {
    UpDown[pos]=0.;
   }
  }

  pos--;
 } 

 pos=limit;
 while(pos>=0)
 {
  RSI[pos]=iRSI(NULL, 0, 1, Price, pos);

  pos--;
 }
   
 double RSI1, RSI2, RSI3;
 pos=limit;
 while(pos>=0)
 {
  RSI1=iRSI(NULL, 0, RSI_Closes_Length, Price, pos);
  RSI2=iRSIOnArray(UpDown, 0, RSI_UpClose_Length, pos);
  RSI3=Percent_Rank(pos);
  
  CRSI[pos]=(RSI1+RSI2+RSI3)/3.;

  pos--;
 }
   
 return(0);
}

