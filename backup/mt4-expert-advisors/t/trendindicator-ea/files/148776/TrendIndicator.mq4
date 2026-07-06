// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=73497

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+


#property copyright "Copyright © 2023, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

#property indicator_chart_window
#property indicator_buffers 9

#property indicator_color1 Red
#property indicator_color2 Green
#property indicator_color3 Red
#property indicator_color4 Green

//arrow
#property indicator_color5 Green
#property indicator_width5 2
#property indicator_color6 Red
#property indicator_width6 2

//MA lines
#property indicator_color7 Red
#property indicator_color8 Green
#property indicator_width7 1
#property indicator_width8 1


int indiCounted = 0;
double HA0buffer[],HA1buffer[],HAopenBuffer[],HAcloseBuffer[];
double UpSideBuffer[];
double DownSidebuffer[];
double TrendBuffer[];

extern string ashi="******* Alert settings:";
extern int SignalCandle=1;
extern string MA1Setting = "MA1 Setting";
extern int MA1_Period =   8;
extern ENUM_MA_METHOD  MA1_Mode = MODE_EMA;
extern string MA2Setting = "MA2 Setting";
extern int MA2_Period =   13;
extern ENUM_MA_METHOD  MA2_Mode = MODE_EMA;
extern bool UseMATrendFilter = true;
extern double ArrowGapMultiplier = .5;
extern color  BuyArrowColor = clrGreen;
extern color  SellArrowColor = clrRed;
extern int    ArrowSize = 1;
extern string  _AlertSetting = "---Alert Settings ---";
extern bool   alertsOn            = false;  //Turn alerts on?
extern bool   alertsOnCurrentBar     = false; //Alerts on (still opened) bar true/false?
extern bool   alertsMessage       = false;  //Alerts Message true/false?
extern bool   alertsSound         = false;   //Alerts sound true/false?
extern bool   alertsNotification  = false;  //Alerts push notification true/false?
extern bool   alertsEmail         = false;  //Alerts email true/false?
extern string  soundFile = "alert.wav";

double MA1Buffer[];
double MA2Buffer[];

int curCandleDir,lastCandleDir;
int lastDir=3;
double atr;

int Direction = 1;  //1 buy 2 sell
double Poin = Point;


int init() {

 if (Point==0.00001) Poin=0.0001;
   else {
      if (Point==0.001) Poin=0.01;
      else Poin=Point;
    } 
   
   
   IndicatorBuffers(9);
   
   SetIndexStyle(0, DRAW_HISTOGRAM, STYLE_SOLID, 2);
   SetIndexBuffer(0, HA0buffer);//red
   SetIndexLabel(0, "HA0");
   SetIndexBuffer(0, HA0buffer);
   SetIndexDrawBegin(0, 10);
   
   SetIndexStyle(1, DRAW_HISTOGRAM, STYLE_SOLID, 2);
   SetIndexBuffer(1, HA1buffer);//green
   SetIndexLabel(1, "HA1");
   SetIndexBuffer(1, HA1buffer);
   SetIndexDrawBegin(1, 10);
   
   SetIndexStyle(2, DRAW_HISTOGRAM, STYLE_SOLID, 3);
   SetIndexBuffer(2, HAopenBuffer);//red
   SetIndexLabel(2, "HAOpen");
   SetIndexBuffer(2, HAopenBuffer);
   SetIndexDrawBegin(2, 10);
   
   SetIndexStyle(3, DRAW_HISTOGRAM, STYLE_SOLID, 3);
   SetIndexBuffer(3, HAcloseBuffer);//green
   SetIndexLabel(3, "HAClose");
   SetIndexBuffer(3, HAcloseBuffer);
   SetIndexDrawBegin(3, 10);
   
   //arrows
   SetIndexBuffer(4,UpSideBuffer);
   SetIndexBuffer(5,DownSidebuffer);
   
   SetIndexStyle(4,DRAW_ARROW,STYLE_SOLID,ArrowSize,SellArrowColor);
   SetIndexStyle(5,DRAW_ARROW,STYLE_SOLID,ArrowSize,BuyArrowColor);
   SetIndexLabel(4, "HA Arrow Sell Arrow");
   SetIndexLabel(5, "HA Arrow Buy Arrow");
   SetIndexArrow(4,234);
   SetIndexArrow(5,233);
   SetIndexEmptyValue(4,EMPTY_VALUE);
   SetIndexEmptyValue(5,EMPTY_VALUE);
   
   
    //ma lines
   SetIndexBuffer(6, MA1Buffer);
   SetIndexBuffer(7, MA2Buffer);
   SetIndexStyle(6,DRAW_LINE,STYLE_SOLID,1);
   SetIndexStyle(7,DRAW_LINE,STYLE_SOLID,1);
   
   //trend buffer
   SetIndexBuffer(8,TrendBuffer);
   SetIndexStyle(8,DRAW_NONE,STYLE_SOLID,0,clrNONE);
   SetIndexEmptyValue(8,0);
   
   return(0);
}

int deinit() {
   return(0);
}

int start() {
   double HAmedian,MaxHighHA,MinLowHA,HAweighted;
   
   if (Bars <= 10) return(0);
   indiCounted = IndicatorCounted();
   if (indiCounted < 0) return (-1);
   if (indiCounted > 0) indiCounted--;
   
   for (int shift = Bars - indiCounted - 1; shift >= 0; shift--)
   {
   
      MA1Buffer[shift] = iMA(Symbol(),0, MA1_Period, 0, MA1_Mode, PRICE_CLOSE, shift);
      MA2Buffer[shift] = iMA(Symbol(),0, MA2_Period, 0, MA2_Mode, PRICE_CLOSE, shift);
   
   
      atr = iATR(Symbol(),0,100, shift);
     
      HAweighted = NormalizeDouble((Open[shift] + High[shift] + Low[shift] + Close[shift]) / 4.0, Digits);
      HAweighted = (HAweighted + Close[shift]) / 2.0;
      HAmedian = (HAopenBuffer[shift + 1] + (HAcloseBuffer[shift + 1])) / 2.0;
      MaxHighHA = MathMax(High[shift], MathMax(HAmedian, HAweighted));
      MinLowHA = MathMin(Low[shift], MathMin(HAmedian, HAweighted));
     
      if (HAmedian < HAweighted)
      {//BLUE CANDLE
         HA0buffer[shift] = MinLowHA;//green
         HA1buffer[shift] = MaxHighHA;//blue
         if (shift==(SignalCandle+1)) lastCandleDir=OP_BUY;
         if (shift==SignalCandle)     curCandleDir=OP_BUY;
         
       // if (lastCandleDir == OP_BUY || curCandleDir == OP_BUY)
           TrendBuffer[shift] = 1;
         
      }
      else
      {//RED CANDLE
         HA0buffer[shift] = MaxHighHA;//red
         HA1buffer[shift] = MinLowHA;//green
         if (shift==(SignalCandle+1)) lastCandleDir=OP_SELL;
         if (shift==SignalCandle)     curCandleDir=OP_SELL;
         
       //  if (lastCandleDir == OP_SELL || curCandleDir == OP_SELL)
         TrendBuffer[shift] = -1;
         
      }
     
      HAopenBuffer[shift] = HAmedian;//red
      HAcloseBuffer[shift] = HAweighted;//green
     
     
      //filter
      //Get MA
       //MA lines
      double MA1Now = iMA(Symbol(),0, MA1_Period, 0, MA1_Mode, PRICE_CLOSE, shift);
      double MA2Now  = iMA(Symbol(),0, MA2_Period, 0, MA2_Mode, PRICE_CLOSE, shift);

      double MA1_PeriodNow = iMA(Symbol(),0, MA1_Period, 0, MA1_Mode, PRICE_CLOSE, shift);
      double MA1_PeriodPrev = iMA(Symbol(),0, MA1_Period, 0, MA1_Mode, PRICE_CLOSE, shift+1);
     
      double MA2_PeriodNow = iMA(Symbol(),0, MA2_Period, 0, MA2_Mode, PRICE_CLOSE, shift);
      double MA2_PeriodPrev = iMA(Symbol(),0, MA2_Period, 0, MA2_Mode, PRICE_CLOSE, shift+1);

     
   
      if ( (TrendBuffer[shift+1] != TrendBuffer[shift] ) && (TrendBuffer[shift]== 1) )
      {
     
         //uptrend
         if (UseMATrendFilter)
         {
            //if ( (MA1_PeriodNow > MA2_PeriodNow) && (MA1_PeriodPrev < MA2_PeriodPrev) )
             if  (MA1_PeriodNow > MA2_PeriodNow)
            {
             DownSidebuffer[shift] = Low[shift] - atr*ArrowGapMultiplier;
             }
            }
         else
         {
            DownSidebuffer[shift] = Low[shift] -  atr*ArrowGapMultiplier;
         }
       
       }
     
      if ( (TrendBuffer[shift+1] != TrendBuffer[shift] )  && (TrendBuffer[shift]== -1) )
     {
        //down trend
        if (UseMATrendFilter)
        {
           //if ( (MA1_PeriodNow < MA2_PeriodNow) && (MA1_PeriodPrev > MA2_PeriodPrev) )
           if ( MA1_PeriodNow < MA2_PeriodNow  )
           {
              UpSideBuffer[shift] = High[shift] +  atr*ArrowGapMultiplier;
           }
        }
        else
        {
               UpSideBuffer[shift] = High[shift] +  atr*ArrowGapMultiplier;
        }
       
     }
       
       
   //for (int shift = Bars - indiCounted - 1; shift >= 0; shift--) {   
//----
   
     
     
   
   }
   
   
   
   manageAlerts();
     
//----
   return(0);
}


void manageAlerts()
{
   int barshift = 0;
   string msg = Symbol()+ ", " + TF2Str(Period());
   
   if (alertsOnCurrentBar == false) barshift = 1;
   
   
   if (alertsOn)
   {
   
    if (UpSideBuffer[barshift] != EMPTY_VALUE)
     {
        msg = msg + " APB Signal : Sell Alert " + " @ " + TimeToStr(TimeLocal(),TIME_SECONDS);
        doAlert(barshift,msg);
     }
     
    else if (DownSidebuffer[barshift] != EMPTY_VALUE)
     {
       msg = msg + " APB Signal: Buy Alert " + " @ " + TimeToStr(TimeLocal(),TIME_SECONDS);
     
       doAlert(barshift,msg);
     }
     
       
   }
}

 
//+------------------------------------------------------------------+
//|     doAlert                                                             |
//+------------------------------------------------------------------+

void doAlert(int forBar, string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime = TimeCurrent();

   

   
   if (previousAlert != doWhat && previousTime != Time[forBar] && previousTime != TimeCurrent())
   {
       previousAlert  = doWhat;
       previousTime   = Time[forBar];

 
       //

     //  message =  StringConcatenate(Symbol(),", ",timeFrameToString(_Period)," HP ",doWhat," @ ",TimeToStr(TimeLocal(),TIME_SECONDS));
          if (alertsMessage)      Alert(doWhat);
          if (alertsEmail)        SendMail(StringConcatenate(Symbol(),"Super Signal "),doWhat);
          if (alertsNotification) SendNotification(doWhat);
          if (alertsSound)        PlaySound("alert.wav");
   }

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string TF2Str(int nperiod)
  {
   switch(nperiod)
     {
      case PERIOD_M1: return("M1");
      case PERIOD_M5: return("M5");
      case PERIOD_M15: return("M15");
      case PERIOD_M30: return("M30");
      case PERIOD_H1: return("H1");
      case PERIOD_H4: return("H4");
      case PERIOD_D1: return("D1");
      case PERIOD_W1: return("W1");
      case PERIOD_MN1: return("MN");
     }
   return(Period());
  }
  
  
//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+

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