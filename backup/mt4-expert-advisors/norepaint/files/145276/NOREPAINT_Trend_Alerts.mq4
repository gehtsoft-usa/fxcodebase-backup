// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=71948

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
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
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




#property copyright "Copyright © 2022, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

//---- indicator settings
#property  indicator_chart_window
#property  indicator_buffers 4
#property  indicator_color1  Red
#property  indicator_color2  Green

#property  indicator_color3  DeepPink
#property  indicator_color4  Aqua


#property  indicator_width1  2
#property  indicator_width2  2
#property  indicator_width3  1
#property  indicator_width4  1
input int BobaPeriod= 20;
// ------------------------------------------------------------------
input string T1                    = "== Notifications ==";  // Notifications
input bool   notifications         = false;                  // Notifications On?
input bool   desktop_notifications = false;                  // Desktop MT4 Notifications
input bool   email_notifications   = false;                  // Email Notifications
input bool   push_notifications    = false;                  // Push Mobile Notifications
// ------------------------------------------------------------------


class CNewCandle
{
  private:
   int    _initialCandles;
   string _symbol;
   int    _tf;

  public:
   CNewCandle(string symbol, int tf) : _symbol(symbol), _tf(tf), _initialCandles(iBars(symbol, tf)) {}
   CNewCandle()
   {
      // toma los valores del chart actual
      _initialCandles = iBars(Symbol(), Period());
      _symbol         = Symbol();
      _tf             = Period();
   }
   ~CNewCandle() { ; }

   bool IsNewCandle()
   {
      int _currentCandles = iBars(_symbol, _tf);
      if (_currentCandles > _initialCandles)
      {
         _initialCandles = _currentCandles;
         return true;
      }

      return false;
   }
};
CNewCandle newCandle();

//---- indicator buffers
double     small_buy[];
double     small_sell[];
double     arrow_sell[];
double     arrow_buy[];
double     trend_buy[];
double     trend_sell[];
double     small_arrow_buy[];
double     small_arrow_sell[];


string UD="";
bool TRENDDN_up=1,TRENDDN_down=1;
bool small_TRENDDN_up=1,small_TRENDDN_down=1;



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
{
   //---- 2 additional buffers are used for counting.
   
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS)+2);
   
   // two bollies
   SetIndexBuffer(0,arrow_buy);  
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexDrawBegin(0,BobaPeriod);
   SetIndexArrow(0, 233);
   SetIndexEmptyValue(0, 0);
    SetIndexLabel(0,"arrow_buy");   
    
   SetIndexBuffer(1,arrow_sell);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexDrawBegin(1,BobaPeriod);
   SetIndexArrow(1, 234);
   SetIndexEmptyValue(1, 0);
    SetIndexLabel(1,"arrow_sell");
    
  
   SetIndexBuffer(2,trend_buy);  
   SetIndexStyle(2,DRAW_LINE);
   SetIndexDrawBegin(2,BobaPeriod);
   SetIndexEmptyValue(2, 0);
   SetIndexLabel(2,"trend_buy");
      
   SetIndexBuffer(3,trend_sell);
   SetIndexStyle(3,DRAW_LINE);
   SetIndexDrawBegin(3,BobaPeriod);
   SetIndexEmptyValue(3, 0);
   SetIndexLabel(3,"trend_sell");



   
    
   //---- name for DataWindow and indicator subwindow label
   // IndicatorShortName("GimmeBar ");
   
   //---- initialization done
   return(0);
}



//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   int counted_bars= IndicatorCounted(),
         lastbar;
     
   if (counted_bars>0)
      counted_bars--;
      
   lastbar= Bars - counted_bars;
   
   GimmeeBar(0, lastbar, arrow_sell, arrow_buy, trend_buy, trend_sell);

   return (0);
}   




//+------------------------------------------------------------------+
//| Mark Gimmee-Bars and mark possible entries for deals              |
//+------------------------------------------------------------------+
double GimmeeBar(int offset, int lastbar, double &insell_arrow[], double &inbuy_arrow[], double &intrend_buy[], double &intrend_sell[])
{
   int markerdist= 3;   // distance between bars and marker dots
   int smallBDistance=5;


   lastbar= MathMin(Bars-BobaPeriod, lastbar);   

   //---- main loop
   for(int i= lastbar; i>=offset; i--){
   
      insell_arrow[i]= 0;
      inbuy_arrow[i]=0;

      double Holy_buy_1 =iCustom(NULL,0,"NoRepaint",0,i);
      double Holy_sell_1 =iCustom(NULL,0,"NoRepaint",1,i);
     
      // 1. Prices were rising.
      // 2. Prices touched the upper band.
      // 3. The price bar closed lower than it
      // opened when prices were previously rising.
      // or vice versa
//----------------------------------------------------------------------------------------------      
      if (Holy_sell_1>0 && Holy_sell_1 !=EMPTY_VALUE )  
      { 
         insell_arrow[i]= High[i] + markerdist*Point;
         
				    
						TRENDDN_up=0;
            TRENDDN_down=1;
       
      }
      
			if(TRENDDN_down) 
			{ 
				intrend_sell[i]=High[i]; 
				if (newCandle.IsNewCandle()) { Notifications(0); }
			}
        
//-----------------------------------------------------------------------------------------    
      if (Holy_buy_1>0 &&  Holy_buy_1 !=EMPTY_VALUE  )  
			{
         inbuy_arrow[i]= Low[i] - markerdist*Point;
         
			

            TRENDDN_down=0;
            TRENDDN_up=1;
      }      
			if(TRENDDN_up) 
			{ 
				intrend_buy[i]=Low[i]; 
				if (newCandle.IsNewCandle()) { Notifications(1); }
			}
   }
   
   return (0); 
}

void Notifications(int type)
{
   string text = "";
   if (type == 0)
      text += _Symbol + " " + GetTimeFrame(_Period) + " BUY ";
   else
      text += _Symbol + " " + GetTimeFrame(_Period) + " SELL ";

   text += " ";

   if (!notifications)
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

//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+
