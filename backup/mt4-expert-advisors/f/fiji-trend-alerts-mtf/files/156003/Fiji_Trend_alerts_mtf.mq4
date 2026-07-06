//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75029

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                https://appliedmachinelearning.systems/contact/ | 
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal:  https://goo.gl/9Rj74e   |
//|                                                             Patreon :  http://tiny.cc/1ybwxz   |   
//|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2024, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Aqua
#property indicator_color2 Yellow
#property indicator_color3 Lime
#property indicator_color4 Red
#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 3
#property indicator_width4 3


//
//
//
//
//

extern string TimeFrame       = "Current time frame";
extern int    MA_Price        = 0;    //Applied Price: 0-C,1-O,2-H,3-L,4-Median,5-Typical,6-Weighted
extern int    MA_Length       = 5;    //MA's Period 
extern int    MA_Mode         = 0;    //MA's Method:0-SMA,1-EMA,2-SMMA,3-LWMA  
extern int    ATR_Length      = 11;   //ATR's Period
extern double Kv              = 1.3;  //Volatility's Factor or Multiplier
extern double MoneyRisk       = 0.15; //Offset Factor 
extern bool   alertsOn        = true; // Alert On:
extern bool   alertsOnCurrent = false; // Alerts On Current candle:
extern bool   alertsMessage   = true;  // Desktop Alert
extern bool   alertsSound     = false; // Sound Alert
extern bool   alertsEmail     = false; // Email Alert:
extern bool push_notifications = false; // Push Alert:
extern string soundFile       = "alert2.wav";  // Sound File:

//
//
//
//
//

double UpBuffer[];
double DnBuffer[];
double UpSignal[];
double DnSignal[];
double smin[];
double smax[];
double trend[];

//
//
//
//
//

string indicatorFileName;
int    timeFrame;
bool   returnBars;
bool   calculateValue;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
//
//

int init()
{
   IndicatorBuffers(7);
   SetIndexBuffer(0,UpBuffer); SetIndexStyle(0,DRAW_ARROW); SetIndexArrow(0,246); SetIndexLabel(0,"UpTrend");
   SetIndexBuffer(1,DnBuffer); SetIndexStyle(1,DRAW_ARROW); SetIndexArrow(1,248); SetIndexLabel(1,"DnTrend");
   SetIndexBuffer(2,UpSignal); SetIndexStyle(2,DRAW_ARROW); SetIndexArrow(2,233); SetIndexLabel(2,"UpSignal"); 
   SetIndexBuffer(3,DnSignal); SetIndexStyle(3,DRAW_ARROW); SetIndexArrow(3,234); SetIndexLabel(3,"DnSignal");
   SetIndexBuffer(4,smin);
   SetIndexBuffer(5,smax);
   SetIndexBuffer(6,trend);
   
      //
      //
      // 
      //
      //
      
      indicatorFileName = WindowExpertName();
      calculateValue    = (TimeFrame=="calculateValue"); if (calculateValue) return(0);
      returnBars        = (TimeFrame=="returnBars");     if (returnBars)     return(0);
      timeFrame         = stringToTimeFrame(TimeFrame);
      
      //
      //
      //
      //
      //
   
   
   IndicatorShortName(timeFrameToString(timeFrame)+" Fiji Trend");
return(0);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int start()
{
   int counted_bars=IndicatorCounted();
   int shift,limit;

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
         limit = MathMin(Bars-counted_bars,Bars-1);
         if (returnBars) { UpBuffer[0] = limit+1; return(0); }

   //
   //
   //
   //
   //

   if (calculateValue || timeFrame==Period())
   {
     for(shift=limit;shift>=0;shift--)
     {
        double bprice = iMA(NULL,0,MA_Length,0,MA_Mode,MA_Price,shift);
        double sprice = iMA(NULL,0,MA_Length,0,MA_Mode,MA_Price,shift);
        smax[shift]   = bprice + Kv*iATR(NULL,0,ATR_Length,shift);
        smin[shift]   = sprice - Kv*iATR(NULL,0,ATR_Length,shift);
        
        DnBuffer[shift]=EMPTY_VALUE;
        DnSignal[shift]=EMPTY_VALUE;
        UpBuffer[shift]=EMPTY_VALUE;
        UpSignal[shift]=EMPTY_VALUE;
        trend[shift]=trend[shift+1];
      
        //
        //
        //
        //
        //
      
        if (High[shift] > smax[shift+1]) trend[shift] =  1;
        if (Low[shift]  < smin[shift+1]) trend[shift] = -1;
	     if (trend[shift] > 0 && smin[shift] < smin[shift+1]) smin[shift] = smin[shift+1];
	     if (trend[shift] < 0 && smax[shift] > smax[shift+1]) smax[shift] = smax[shift+1];
        if (trend[shift] == 1)
        {  
           UpBuffer[shift] = smin[shift] - (MoneyRisk - 1) * iATR(NULL,0,ATR_Length,shift); if (trend[shift+1]!= 1) UpSignal[shift] = UpBuffer[shift];
        }
        if (trend[shift] == -1)
        {  
            DnBuffer[shift] = smax[shift] + (MoneyRisk - 1) * iATR(NULL,0,ATR_Length,shift); if (trend[shift+1]!=-1)  DnSignal[shift] = DnBuffer[shift];
        }
   }
   manageAlerts();
   return(0);
   }
   
   //
   //
   //
   //
   //
      
   limit = MathMax(limit,MathMin(Bars,iCustom(NULL,timeFrame,indicatorFileName,"returnBars",0,0)*timeFrame/Period()));
   for (int i=limit;i>=0; i--)
   {
      int y = iBarShift(NULL,timeFrame,Time[i]);
         UpBuffer[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",MA_Price,MA_Length,MA_Mode,ATR_Length,Kv,MoneyRisk,0,y);
         DnBuffer[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",MA_Price,MA_Length,MA_Mode,ATR_Length,Kv,MoneyRisk,1,y);
         trend[i]    = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",MA_Price,MA_Length,MA_Mode,ATR_Length,Kv,MoneyRisk,6,y);
         UpSignal[i] = EMPTY_VALUE;
         DnSignal[i] = EMPTY_VALUE;
            if (UpBuffer[i]!= EMPTY_VALUE && UpBuffer[i+1]==EMPTY_VALUE) UpSignal[i]=UpBuffer[i];
            if (DnBuffer[i]!= EMPTY_VALUE && DnBuffer[i+1]==EMPTY_VALUE) DnSignal[i]=DnBuffer[i];
   }
   manageAlerts();  
   return(0);         
}

//+-------------------------------------------------------------------
//|                                                                  
//+-------------------------------------------------------------------
//
//
//
//
//

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

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
   if (! calculateValue && alertsOn)
   {
      int whichBar = 0;
      if (alertsOnCurrent)
               whichBar = 0;
      else     whichBar = 1; whichBar = iBarShift(NULL,0,iTime(NULL,timeFrame,whichBar));
      if (trend[whichBar] != trend[whichBar+1])
      {
         if (trend[whichBar] == 1) doAlert(whichBar,"buy");
         if (trend[whichBar] ==-1) doAlert(whichBar,"sell");
      }         
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

       message =  StringConcatenate(Symbol()," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," - ",timeFrameToString(timeFrame)+" Fiji Trend ",doWhat);
          if (alertsMessage) Alert(message);
          if (alertsEmail)   SendMail(StringConcatenate(Symbol()," Fiji Trend "),message);
          if (alertsSound)   PlaySound("alert2.wav");
          if (push_notifications) SendNotification(message);
   }
}

//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal:  https://goo.gl/9Rj74e   |
//|                                                             Patreon :  http://tiny.cc/1ybwxz   |   
//|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
//+------------------------------------------------------------------------------------------------+
//|  Cryptocurrency  |  Network                    |  Address                                      |
//+------------------------------------------------+-----------------------------------------------+
//|  USDT            |  ERC20 (ETH Ethereum)       |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
//|  USDT            |  TRC20 (Tron)               |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
//|  USDT            |  BEP20 (BSC BNB Smart Chain)|  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  Matic Polygon              |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  SOL Solana                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
//|  USDT            |  ARBITRUM Arbitrum One      |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//+------------------------------------------------+-----------------------------------------------+ 