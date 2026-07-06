// Id: 14221
//+------------------------------------------------------------------+
//|                                           Weight_Of_Evidence.mq4 |
//|                               Copyright � 2015, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2015, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Green
#property indicator_color2 Red

extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  
extern int Length1=3;
extern int Length2=5;
extern int Length3=10;
extern int Length4=20;
extern int Length5=50;
extern int Smoothing=3;

double WoE[], Signal[];
double PVT[];

int init()
{
     double temp = iCustom(NULL, 0, "OBV", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'OBV' indicator");
       return INIT_FAILED;
   }
       
temp = iCustom(NULL, 0, "WAD", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'WAD' indicator");
       return INIT_FAILED;
   }
   IndicatorShortName("");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,WoE);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,Signal);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,PVT);

 return(0);
}

int deinit()
{

 return(0);
}

double PercentRank(double Len, int index)
{
 double Count=0.;
 int i;
 for (i=1;i<=Len;i++)
 {
  if (iMA(NULL, 0, 1, 0, MODE_SMA, Price, index)>iMA(NULL, 0, 1, 0, MODE_SMA, Price, index+i))
  {
   Count++;
  }
 }
 return (100.*Count/Len);
}

int start()
{
 if(Bars<=3) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 double Total;
 double Max;
 double EMA1, EMA2, EMA3, EMA4, EMA5;
 double RSI1, RSI2, RSI3, RSI4, RSI5;
 double OBV, OBV1, OBV2, OBV3, OBV4, OBV5;
 double WAD, WAD1, WAD2, WAD3, WAD4, WAD5;
 double ATR;
 double Pr;
 pos=limit;
 while(pos>=0)
 {
  Total=0.;
  Max=High[iHighest(NULL, 0, MODE_HIGH, Length3, pos)];
  if (pos==Bars-2)
  {
   PVT[pos]=0.;
  }
  else
  {
   if (Close[pos+1]!=0.)
   {
    PVT[pos]=Volume[pos]*(Close[pos]-Close[pos+1])/Close[pos+1]+PVT[pos+1];
   }
  } 
  Pr=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
  
  EMA1=iMA(NULL, 0, Length1, 0, MODE_EMA, Price, pos);
  EMA2=iMA(NULL, 0, Length2, 0, MODE_EMA, Price, pos);
  EMA3=iMA(NULL, 0, Length3, 0, MODE_EMA, Price, pos);
  EMA4=iMA(NULL, 0, Length4, 0, MODE_EMA, Price, pos);
  EMA5=iMA(NULL, 0, Length5, 0, MODE_EMA, Price, pos);
  
  RSI1=iRSI(NULL, 0, Length1, Price, pos);
  RSI2=iRSI(NULL, 0, Length2, Price, pos);
  RSI3=iRSI(NULL, 0, Length3, Price, pos);
  RSI4=iRSI(NULL, 0, Length4, Price, pos);
  RSI5=iRSI(NULL, 0, Length5, Price, pos);
  
  OBV=iCustom(NULL, 0, "OBV", 0, pos);
  OBV1=iCustom(NULL, 0, "OBV", 0, pos+Length1-1);
  OBV2=iCustom(NULL, 0, "OBV", 0, pos+Length2-1);
  OBV3=iCustom(NULL, 0, "OBV", 0, pos+Length3-1);
  OBV4=iCustom(NULL, 0, "OBV", 0, pos+Length4-1);
  OBV5=iCustom(NULL, 0, "OBV", 0, pos+Length5-1);
  
  WAD=iCustom(NULL, 0, "WAD", 2, pos)+iCustom(NULL, 0, "WAD", 3, pos);
  WAD1=iCustom(NULL, 0, "WAD", 2, pos+Length1-1)+iCustom(NULL, 0, "WAD", 3, pos+Length1-1);
  WAD2=iCustom(NULL, 0, "WAD", 2, pos+Length2-1)+iCustom(NULL, 0, "WAD", 3, pos+Length2-1);
  WAD3=iCustom(NULL, 0, "WAD", 2, pos+Length3-1)+iCustom(NULL, 0, "WAD", 3, pos+Length3-1);
  WAD4=iCustom(NULL, 0, "WAD", 2, pos+Length4-1)+iCustom(NULL, 0, "WAD", 3, pos+Length4-1);
  WAD5=iCustom(NULL, 0, "WAD", 2, pos+Length5-1)+iCustom(NULL, 0, "WAD", 3, pos+Length5-1);
  
  ATR=iATR(NULL, 0, Length3, pos);
  
  if (Pr>=EMA1) Total++;
  if (Pr>=EMA2) Total++;
  if (Pr>=EMA3) Total++;
  if (Pr>=EMA4) Total++;
  if (Pr>=EMA5) Total++;
  
  if (RSI1>=50.) Total++;
  if (RSI2>=50.) Total++;
  if (RSI3>=50.) Total++;
  if (RSI4>=50.) Total++;
  if (RSI5>=50.) Total++;
  
  if (OBV>=OBV1) Total++;
  if (OBV>=OBV2) Total++;
  if (OBV>=OBV3) Total++;
  if (OBV>=OBV4) Total++;
  if (OBV>=OBV5) Total++;
  
  if (Pr>Max+ATR) Total++;
  if (Pr>Max+2.*ATR) Total++;
  if (Pr>Max+3.*ATR) Total++;
  if (Pr>Max+4.*ATR) Total++;
  if (Pr>Max+5.*ATR) Total++;
  
  if (PVT[pos]>=PVT[pos+Length1-1]) Total++;
  if (PVT[pos]>=PVT[pos+Length2-1]) Total++;
  if (PVT[pos]>=PVT[pos+Length3-1]) Total++;
  if (PVT[pos]>=PVT[pos+Length4-1]) Total++;
  if (PVT[pos]>=PVT[pos+Length5-1]) Total++;
  
  if (WAD>=WAD1) Total++;
  if (WAD>=WAD2) Total++;
  if (WAD>=WAD3) Total++;
  if (WAD>=WAD4) Total++;
  if (WAD>=WAD5) Total++;
  
  if (PercentRank(Length1, pos)>=50.) Total++;
  if (PercentRank(Length2, pos)>=50.) Total++;
  if (PercentRank(Length3, pos)>=50.) Total++;
  if (PercentRank(Length4, pos)>=50.) Total++;
  if (PercentRank(Length5, pos)>=50.) Total++;
  
  WoE[pos]=100.*Total/40./Point;

  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  Signal[pos]=iMAOnArray(WoE, 0, Smoothing, 0, MODE_EMA, pos);

  pos--;
 }
   
 return(0);
}

