//+------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                           mario.jemic@gmail.com  |
//|                          https://AppliedMachineLearning.systems  |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//|                                 Patreon : https://goo.gl/GdXWeN  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2020, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property strict

#property indicator_chart_window
#property indicator_buffers 6
#property indicator_color1 DodgerBlue  // up[]
#property indicator_width1 1
#property indicator_color2 Red       // down[]
#property indicator_width2 1
#property indicator_color3 DodgerBlue  // atrlo[]
#property indicator_width3 1
#property indicator_color4 Red       // atrhi[]
#property indicator_width4 1
#property indicator_color5 DodgerBlue  // arrup[]
#property indicator_width5 1
#property indicator_color6 Red      // arrdwn[]
#property indicator_width6 1

input int    Amplitude           = 2.0;
input ENUM_TIMEFRAMES HTF = PERIOD_CURRENT; // Timeframe    
input bool   alertsOn            = true;
input bool   alertsOnCurrent     = false;
input bool   alertsMessage       = true;
input bool   alertsNotification  = true;
input bool   alertsSound         = true;
input bool   alertsEmail         = false;

input bool   ShowBars            = false;
input bool   ShowArrows          = true;
input int    arrowSize           = 2;
input int    uparrowCode         = 233;
input int    dnarrowCode         = 234;
input bool   ArrowsOnFirstBar    = true;

bool nexttrend;
double minhighprice,maxlowprice;
double up[],down[],atrlo[],atrhi[],trend[];
double arrup[],arrdwn[];

//
//
//
//
//

string indicatorFileName;
bool   returnBars;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
  for (int i=0; i<indicator_buffers; i++) SetIndexStyle(i,DRAW_LINE);
   IndicatorBuffers(7); // +1 buffer - trend[]
   SetIndexBuffer(0,up);
   SetIndexBuffer(1,down);
   SetIndexBuffer(2,atrlo);
   SetIndexBuffer(3,atrhi);
   SetIndexBuffer(4,arrup);
   SetIndexBuffer(5,arrdwn);
   SetIndexBuffer(6,trend);
   SetIndexEmptyValue(0,0.0);
   SetIndexEmptyValue(1,0.0);
   SetIndexEmptyValue(6,0.0);
   
   if(ShowBars)
   {
      SetIndexStyle(2,DRAW_HISTOGRAM, STYLE_SOLID);
      SetIndexStyle(3,DRAW_HISTOGRAM, STYLE_SOLID);
   }
   else
   {
      SetIndexStyle(2,DRAW_NONE);
      SetIndexStyle(3,DRAW_NONE);
   }
   if (ShowArrows)
   {
     SetIndexStyle(4,DRAW_ARROW,0,arrowSize); SetIndexArrow(4,uparrowCode);
     SetIndexStyle(5,DRAW_ARROW,0,arrowSize); SetIndexArrow(5,dnarrowCode);   
   }
   else
   {
     SetIndexStyle(4,DRAW_NONE);
     SetIndexStyle(5,DRAW_NONE);
   }        
          
     
   nexttrend=0;
   minhighprice= High[Bars-1];
   maxlowprice = Low[Bars-1];
   indicatorFileName = WindowExpertName();
   return (0);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CFix { } ExtFix;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
{  
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   double atr,lowprice_i,highprice_i,lowma,highma;
   int workbar=0;
   int minBars = 1;
   int limit = MathMin(Bars - 1 - minBars, Bars - counted_bars - 1);
   for (int i = limit; i >= 0; --i)
   {
      lowprice_i=iLow(Symbol(),Period(),iLowest(Symbol(),Period(),MODE_LOW,Amplitude,i));
      highprice_i=iHigh(Symbol(),Period(),iHighest(Symbol(),Period(),MODE_HIGH,Amplitude,i));
      lowma=NormalizeDouble(iMA(NULL,0,Amplitude,0,MODE_SMA,PRICE_LOW,i),Digits());
      highma=NormalizeDouble(iMA(NULL,0,Amplitude,0,MODE_SMA,PRICE_HIGH,i),Digits());
      trend[i]=trend[i+1];
      atr=iATR(Symbol(),0,100,i)/2;

      arrup[i]  = EMPTY_VALUE;
      arrdwn[i] = EMPTY_VALUE;
      if (nexttrend==1)
      {
         maxlowprice=MathMax(lowprice_i,maxlowprice);
         if (highma<maxlowprice && Close[i]<Low[i+1])
         {
            trend[i]=1.0;
            nexttrend=0;
            minhighprice=highprice_i;
         }
      }
      if (nexttrend==0)
      {
         minhighprice=MathMin(highprice_i,minhighprice);
         if (lowma>minhighprice && Close[i]>High[i+1])
         {
            trend[i]=0.0;
            nexttrend=1;
            maxlowprice=lowprice_i;
         }
      }
      if (trend[i]==0.0)
      {
         if (trend[i+1] != 0.0)
         {
            if (HTF != PERIOD_CURRENT && HTF != _Period)
            {
               int index = iBarShift(_Symbol, HTF, Time[i]);
               double value = iCustom(_Symbol, HTF, "HalfTmtf 2", Amplitude, 5, index);
               if (value != EMPTY_VALUE && value != 0)
               {
                  continue;
               }
            }
            up[i]=down[i+1];
            up[i+1]=up[i];
            arrup[i] = up[i] - 2*atr;
         }
         else
         {
            up[i]=MathMax(maxlowprice,up[i+1]);
         }
         atrhi[i] = up[i] - atr;
         atrlo[i] = up[i];
         down[i]=0.0;
      }
      else
      {
         if (trend[i+1]!=1.0)
         {
            if (HTF != PERIOD_CURRENT && HTF != _Period)
            {
               int index = iBarShift(_Symbol, HTF, Time[i]);
               double value = iCustom(_Symbol, HTF, "HalfTmtf 2", Amplitude, 4, index);
               if (value != EMPTY_VALUE && value != 0)
               {
                  continue;
               }
            }
            down[i]=up[i+1];
            down[i+1]=down[i];
            arrdwn[i] = down[i] + 2*atr;           
         }
         else
         {
            down[i]=MathMin(minhighprice,down[i+1]);
         }
         atrhi[i] = down[i] + atr;
         atrlo[i] = down[i];
         up[i]=0.0;
      }
   }
   manageAlerts();
   return (0);
  }
  
//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
//
//
//
//
//

string sTfTable[] = {"M1","M5","M10","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,10,15,30,60,240,1440,10080,43200};

//
//
//
//
//

int stringToTimeFrame(string tfs)
{
   tfs = stringUpperCase(tfs);
   for (int i=ArraySize(iTfTable)-1; i>=0; i--)
         if (tfs==sTfTable[i] || tfs==""+iTfTable[i]) return(MathMax(iTfTable[i],Period()));
                                                      return(Period());
}
string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}

//
//
//
//
//

string stringUpperCase(string str)
{
   string   s = str;

   for (int length=StringLen(str)-1; length>=0; length--)
   {
      int tchar = StringGetChar(s, length);
         if((tchar > 96 && tchar < 123) || (tchar > 223 && tchar < 256))
                     s = StringSetChar(s, length, tchar - 32);
         else if(tchar > -33 && tchar < 0)
                     s = StringSetChar(s, length, tchar + 224);
   }
   return(s);
}

//+-------------------------------------------------------------------
//|                                                                  
//+-------------------------------------------------------------------
//
//
//
//
//

void manageAlerts()
{
   if (alertsOn)
   {
      int whichBar = alertsOnCurrent ? 0 : 1;
      if (arrup[whichBar]  != EMPTY_VALUE) doAlert(whichBar,"up");
      if (arrdwn[whichBar] != EMPTY_VALUE) doAlert(whichBar,"down");
   }
}

//
//
//
//
//

void doAlert(int forBar, string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
   if (previousAlert != doWhat || previousTime != Time[forBar]) {
       previousAlert  = doWhat;
       previousTime   = Time[forBar];

       //
       //
       //
       //
       //

       message =  StringConcatenate(Symbol()," ",timeFrameToString(_Period)," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," HalfTrend ",doWhat);
          if (alertsMessage)      Alert(message);
          if (alertsEmail)        SendMail(StringConcatenate(Symbol(),"HalfTrend "),message);
          if (alertsNotification) SendNotification(message);
          if (alertsSound)        PlaySound("alert2.wav");
   }
}