// More information about this indicator can be found at:
// //https://fxcodebase.com/code/viewtopic.php?f=38&t=71895

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
#property description "Mobidik"
#property strict
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1  clrGold
#property indicator_color2  clrSteelBlue
#property indicator_color3  clrGray
#property indicator_color4  clrSteelBlue
#property indicator_style3  2
#property strict
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

bool CloseCandleMode = true;
class CNewCandle
{
  private:
   int    velasInicio;
   string m_symbol;
   int    m_tf;

  public:
   CNewCandle();
   CNewCandle(string symbol, int tf) : m_symbol(symbol), m_tf(tf), velasInicio(iBars(symbol, tf)) {}
   ~CNewCandle();

   bool IsNewCandle();
};
CNewCandle::CNewCandle()
{
   // toma los valores del chart actual
   velasInicio = iBars(Symbol(), Period());
   m_symbol    = Symbol();
   m_tf        = Period();
}
CNewCandle::~CNewCandle() {}
bool CNewCandle::IsNewCandle()
{
   int velasActuales = iBars(m_symbol, m_tf);
   if (velasActuales > velasInicio)
   {
      velasInicio = velasActuales;
      return true;
   }

   //---
   return false;
}
CNewCandle* newCandle;


enum enTimeFrames
{
   tf_cu  = PERIOD_CURRENT, // Current time frame
   tf_m1  = PERIOD_M1,      // 1 minute
   tf_m5  = PERIOD_M5,      // 5 minutes
   tf_m15 = PERIOD_M15,     // 15 minutes
   tf_m30 = PERIOD_M30,     // 30 minutes
   tf_h1  = PERIOD_H1,      // 1 hour
   tf_h4  = PERIOD_H4,      // 4 hours
   tf_d1  = PERIOD_D1,      // Daily
   tf_w1  = PERIOD_W1,      // Weekly
   tf_mn1 = PERIOD_MN1,     // Monthly
   tf_n1  = -1,             // First higher time frame
   tf_n2  = -2,             // Second higher time frame
   tf_n3  = -3              // Third higher time frame
};


//
//
// ------------------------------------------------------------------
extern enTimeFrames    TimeFrame          = tf_cu;   // Time frame
extern int                DPO_Period         = 14;               // Dpo period
extern ENUM_APPLIED_PRICE DPO_Price          = PRICE_CLOSE;      // Dpo price
extern ENUM_MA_METHOD     DPO_Method         = MODE_SMMA;        // Dpo ma method
extern int                BollingerPeriod    = 21;               // Bollinger period
extern double             BollingerDeviation = 1;                // Bollinger deviation
extern int                BollingerShift     = 0;                // Bollinger shift
extern bool               Interpolate        = true;             // Interpolate in mtf mode
// ------------------------------------------------------------------
input string       TZ                      = "== Notifications ==";      // Notifications
input bool         notificationsOn         = false;                      // Notifications On:
input bool         desktop_notifications   = false;                      // Desktop MT4 Notifications
input bool         email_notifications     = false;                      // Email Notifications
input bool         push_notifications      = false;                      // Push Mobile Notifications
// ------------------------------------------------------------------
double dpo[],BUpper[],BMiddle[],BLower[],count[];
string indicatorFileName;
#define _mtfCall(_buff,_ind) iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,DPO_Period,DPO_Price,DPO_Method,BollingerPeriod,BollingerDeviation,0,_buff,_ind)
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
 {
  IndicatorBuffers(5);
  SetIndexBuffer(0, dpo);     SetIndexLabel (0, "DPO");
  SetIndexBuffer(1, BUpper);  SetIndexLabel (1, "BB Up");
  SetIndexBuffer(2, BMiddle); SetIndexLabel (2, "BB Middle");
  SetIndexBuffer(3, BLower);  SetIndexLabel (3, "BB Dn");
  SetIndexBuffer(4, count);
   
  indicatorFileName = WindowExpertName();
  TimeFrame         = (enTimeFrames)timeFrameValue(TimeFrame);
  
  for (int i=0; i<7; i++) SetIndexShift(i,BollingerShift*TimeFrame/Period());
  
  IndicatorShortName(timeFrameToString(TimeFrame)+" DPO-BB");

  //--- 
  newCandle = new CNewCandle();
  //--- 
return(0);
 }
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//+------------------------------------------------------------------+
//| DPO-BB                                                           |
//+------------------------------------------------------------------+
int start()
 {
    int i,counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
           int limit = fmin(Bars-counted_bars,Bars-1); count[0] = limit;

   //
   //
   //
   //
   //

   if (TimeFrame == _Period)
   {
     int shift = DPO_Period/2+1;       
     for(i=limit; i>=0; i--) dpo[i] = iMA(NULL,0,1,0,DPO_Method,DPO_Price,i)-iMA(NULL,0,DPO_Period,0,DPO_Method,DPO_Price,i+shift);
     for(i=limit; i>=0; i--)
     {
        BUpper [i] = iBandsOnArray(dpo,0,BollingerPeriod,BollingerDeviation,BollingerShift,MODE_UPPER,i);
        BMiddle[i] = iBandsOnArray(dpo,0,BollingerPeriod,BollingerDeviation,BollingerShift,MODE_MAIN, i);
        BLower [i] = iBandsOnArray(dpo,0,BollingerPeriod,BollingerDeviation,BollingerShift,MODE_LOWER,i);
     } 

// TODO: noti
//--- CANDLE CLOSE:
   if (CloseCandleMode)
      if (newCandle.IsNewCandle())
      {
         if(notificationsOn)
         {
            if(dpo[1]>0 && dpo[2]<0) { Notify(0); }
            if(dpo[1]<0 && dpo[2]>0) { Notify(1); }
            if(dpo[1]>BMiddle[1]&& dpo[2]<BMiddle[2]) { Notify(2); }
            if(dpo[1]<BMiddle[1]&& dpo[2]>BMiddle[2]) { Notify(3); }
         }
      }
   return(0);
   }
   
   //
   //
   //
   //
   //
   
   limit = (int)MathMax(limit,MathMin(Bars-1,_mtfCall(4,0)*TimeFrame/_Period));
   for (i=limit; i>=0; i--)
   {
      int y = iBarShift(NULL,TimeFrame,Time[i]);
         dpo[i]     = _mtfCall(0,y);
         BUpper[i]  = _mtfCall(1,y);
         BMiddle[i] = _mtfCall(2,y);
         BLower[i]  = _mtfCall(3,y);
         
         //
         //
         //
         //
         //
      
         if (!Interpolate || (i>0 && y==iBarShift(NULL,TimeFrame,Time[i-1]))) continue;
            #define _interpolate(buff) buff[i+j] = buff[i]+(buff[i+n]-buff[i])*j/n
            int n,j; datetime time = iTime(NULL,TimeFrame,y);
               for(n = 1; (i+n)<Bars && Time[i+n] >= time; n++) continue;	
               for(j = 1; j<n && (i+n)<Bars && (i+j)<Bars; j++) 
               {
                  _interpolate(dpo);
                  _interpolate(BUpper);
                  _interpolate(BMiddle);
                  _interpolate(BLower);
               }                           
   }
return(0);
}

//
//
//
//
//

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}
int timeFrameValue(int _tf)
{
   int add  = (_tf>=0) ? 0 : MathAbs(_tf);
   if (add != 0) _tf = _Period;
   int size = ArraySize(iTfTable); 
      int i =0; for (;i<size; i++) if (iTfTable[i]==_tf) break;
                                   if (i==size) return(_Period);
                                                return(iTfTable[(int)MathMin(i+add,size-1)]);
}

// 0 cruza linea cero para abajo
// 1 cruza linea cero para arriba
// 2 toca banda inferior
// 3 toca banda superior

void Notify(int type)
{
   string text = "DPO Indicator: ";
     switch (type) 
     {
        case 0: text += " Cross Zero Line to UP -" + _Symbol + " " + GetTimeFrame(_Period); break;
        case 1: text += " Cross Zero Line to Down -" + _Symbol + " " + GetTimeFrame(_Period); break;
        case 2: text += " Cross Midle Line BB to UP  -" + _Symbol + " " + GetTimeFrame(_Period); break;
        case 3: text += " Cross Midle Line BB to Down -" + _Symbol + " " + GetTimeFrame(_Period); break;
     }   

   text += " ";

   if (!notificationsOn)
      return;
   if (desktop_notifications)
      Alert(text);
   if (push_notifications)
      SendNotification(text);
   if (email_notifications)
      SendMail("MetaTrader Notification", text);
}

string GetTimeFrame(int lPeriod)
{
   switch (lPeriod)
   {
      case PERIOD_M1:
         return ("M1");
      case PERIOD_M5:
         return ("M5");
      case PERIOD_M15:
         return ("M15");
      case PERIOD_M30:
         return ("M30");
      case PERIOD_H1:
         return ("H1");
      case PERIOD_H4:
         return ("H4");
      case PERIOD_D1:
         return ("D1");
      case PERIOD_W1:
         return ("W1");
      case PERIOD_MN1:
         return ("MN1");
   }
   return IntegerToString(lPeriod);
}


// 