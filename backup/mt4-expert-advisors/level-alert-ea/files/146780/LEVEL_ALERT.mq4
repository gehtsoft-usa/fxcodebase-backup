// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=72521
//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                              Support our efforts by donating   | 
//|                                                                 Paypal: https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   | 
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+
//Your donations will allow the service to continue onward.
//+------------------------------------------------------------------------------------------------+
//|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
//|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
//|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
//|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
//|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
//|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |  
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
//|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
//|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
//+------------------------------------------------------------------------------------------------+
#property copyright "Copyright © 2022, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"


#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 clrAqua
#property indicator_color2 clrOrange
#property indicator_width1 3
#property indicator_width2 3


extern string TimeFrame       = "240";
extern int    period          = 1;
extern int    appliedPrice    = PRICE_MEDIAN;
extern double multiplier      = 0.4;
extern bool   alertsOn        = true;
input bool    alertsNotify    = true;  
extern bool   alertsOnCurrent = false;
extern bool   alertsMessage   = false;
extern bool   alertsSound     = false;
extern bool   alertsEmail     = false;

//
//
//
//
//

double arrUp[];
double arrDn[];
double Direction[];
double Up[];
double Dn[];

string indicatorFileName;
bool   calculateValue;
bool   returnBars;
int    timeFrame;

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//


datetime  NewCandleTimeCurrent ;

int init()
{
   IndicatorBuffers(5);
      SetIndexBuffer(0, arrUp); SetIndexStyle(0,DRAW_ARROW); SetIndexArrow(0,221);
      SetIndexBuffer(1, arrDn); SetIndexStyle(1,DRAW_ARROW); SetIndexArrow(1,222);
      SetIndexBuffer(2, Direction);
      SetIndexBuffer(3, Up);
      SetIndexBuffer(4, Dn);

         //
         //
         //
         //
         //
                  
         indicatorFileName = WindowExpertName();
         calculateValue    = (TimeFrame=="CalculateValue"); if (calculateValue) return(0);
         returnBars        = (TimeFrame=="returnBars");     if (returnBars)     return(0);
         timeFrame         = stringToTimeFrame(TimeFrame);
         
         //
         //
         //
         //
         //
         
      SetIndexLabel(0,"SuperTrend up");
      SetIndexLabel(1,"SuperTrend down");
   IndicatorShortName("SuperTrend");
   period = MathMax(1,period);
}
int deinit() { return(0); }




//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int  OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{



   if( IsNewCandleCurrent())  {
   int counted_bars = IndicatorCounted();
      if(counted_bars < 0) return(-1);
      if(counted_bars > 0) counted_bars--;
           int limit = MathMin(Bars-counted_bars,Bars-1);
           if (returnBars) { arrUp[0] = limit+1; return(0); }

   //
   //
   //
   //
   //
      
   if (calculateValue || timeFrame==Period())
   {
      for(int i = limit; i >= 0; i--)
      {
         double atr    = iATR(NULL,0,period,i);
         double cprice = iMA(NULL,0,1,0,MODE_SMA,appliedPrice,i);
         double mprice = (High[i]+Low[i])/2;
             Up[i]  = mprice+multiplier*atr;
             Dn[i]  = mprice-multiplier*atr;
             Direction[i] = Direction[i+1];
               if (cprice > Up[i+1]) Direction[i] =  1;
               if (cprice < Dn[i+1]) Direction[i] = -1;
             arrUp[i] = EMPTY_VALUE;
             arrDn[i] = EMPTY_VALUE;
               if (Direction[i] > 0) { Dn[i] = MathMax(Dn[i],Dn[i+1]); if (Direction[i] != Direction[i+1]) arrUp[i] = Dn[i];}
               else                  { Up[i] = MathMin(Up[i],Up[i+1]); if (Direction[i] != Direction[i+1]) arrDn[i] = Up[i];}
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
   for (i=limit; i>=0; i--)
   {
      int y = iBarShift(NULL,timeFrame,Time[i]);
      int x = iBarShift(NULL,timeFrame,Time[i+1]);
         arrUp[i] = EMPTY_VALUE;
         arrDn[i] = EMPTY_VALUE;
         if (x!=y)         
         {
            arrUp[i] = iCustom(NULL,timeFrame,indicatorFileName,"CalculateValue",period,appliedPrice,multiplier,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,0,y);
            arrDn[i] = iCustom(NULL,timeFrame,indicatorFileName,"CalculateValue",period,appliedPrice,multiplier,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,1,y);
         }            
   }   

   }
    return(rates_total);



}

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
//
//
//
//
//

void manageAlerts()
{
   if (alertsOn)
   {
      int whichBar = 1; if (alertsOnCurrent) whichBar=0;
      if ((arrUp[whichBar] != EMPTY_VALUE) || (arrDn[whichBar] != EMPTY_VALUE))
            {
               if (arrUp[whichBar] != EMPTY_VALUE) doAlert("BUY"  );
               if (arrDn[whichBar] != EMPTY_VALUE) doAlert("SELL");
            }
   }
}

//
//
//
//
//

void doAlert(string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
   if (previousAlert != doWhat || previousTime != Time[0]) {
       previousAlert  = doWhat;
       previousTime   = Time[0];

       //
       //
       //
       //
       //

       message =  timeFrameToString(Period())+" "+Symbol()+" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+" CHECK "+doWhat;
          if (alertsMessage) Alert(message);
             if (alertsNotify)  SendNotification(message);
          if (alertsEmail)   SendMail(Symbol()+" super trend",message);
          if (alertsSound)   PlaySound("alert2.wav");
   }
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
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

int toInt(double value) { return(value); }
int stringToTimeFrame(string tfs)
{
   tfs = stringUpperCase(tfs);
   int max = ArraySize(iTfTable)-1, add=0;
   int nxt = (StringFind(tfs,"NEXT")>-1); if (nxt>0) { tfs = ""+Period(); add=1; }

      //
      //
      //
      //
      //
         
      for (int i=max; i>=0; i--)
         if (tfs==sTfTable[i] || tfs==""+iTfTable[i]) return(MathMax(iTfTable[toInt(MathMin(max,i+add))],Period()));
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




 bool IsNewCandleCurrent()
   {
     if(NewCandleTimeCurrent == iTime(Symbol(), PERIOD_CURRENT, 0))
     return false;  
    else  
    { 
   NewCandleTimeCurrent = iTime(Symbol(), PERIOD_CURRENT, 0);  
    return true;
    }
   }