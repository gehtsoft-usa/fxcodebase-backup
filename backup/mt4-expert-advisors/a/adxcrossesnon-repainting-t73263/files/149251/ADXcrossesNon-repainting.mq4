// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=73263

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright c 2023, Gehtsoft USA LLC  | 
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


#property copyright "Copyright c 2023, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
 

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red
//---- input parameters
extern int ADXcrossesPeriod = 14;
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
//----
double b4plusdi, b4minusdi, nowplusdi, nowminusdi;
int    nShift;   


input string T1                    = "== Notifications ==";  // ————————————
input bool   notifications         = false;                  // Notifications On?
input bool   desktop_notifications = false;                  // Desktop MT4 Notifications
input bool   email_notifications   = false;                  // Email Notifications
input bool   push_notifications    = false;                  // Push Mobile Notifications

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


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
    SetIndexStyle(0, DRAW_ARROW, 0, 1);
    SetIndexArrow(0, 233);
    SetIndexBuffer(0, ExtMapBuffer1);
//----
    SetIndexStyle(1, DRAW_ARROW, 0, 1);
    SetIndexArrow(1, 234);
    SetIndexBuffer(1, ExtMapBuffer2);
//---- name for DataWindow and indicator subwindow label
    IndicatorShortName("ADXcrosses(" + ADXcrossesPeriod + ")");
    SetIndexLabel(0, "ADXcrUp");
    SetIndexLabel(1, "ADXcrDn"); 
//----
    switch(Period())
      {
        case     1: nShift = 1;   break;    
        case     5: nShift = 3;   break; 
        case    15: nShift = 5;   break; 
        case    30: nShift = 10;  break; 
        case    60: nShift = 15;  break; 
        case   240: nShift = 20;  break; 
        case  1440: nShift = 80;  break; 
        case 10080: nShift = 100; break; 
        case 43200: nShift = 200; break;               
      }
//----
    return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
    return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
    int limit;
    int counted_bars = IndicatorCounted();
//---- check for possible errors
    if(counted_bars < 0) 
        return(-1);
//---- last counted bar will be recounted
    if(counted_bars > 0) 
        counted_bars--;
    limit = Bars - counted_bars;
//----
    for(int i = 0; i < limit; i++)
      {
        b4plusdi = iADX(NULL, 0, ADXcrossesPeriod, PRICE_CLOSE, MODE_PLUSDI, i + 1);
        nowplusdi = iADX(NULL, 0, ADXcrossesPeriod, PRICE_CLOSE, MODE_PLUSDI, i);
        b4minusdi = iADX(NULL, 0, ADXcrossesPeriod, PRICE_CLOSE, MODE_MINUSDI, i + 1);
        nowminusdi = iADX(NULL, 0, ADXcrossesPeriod, PRICE_CLOSE, MODE_MINUSDI, i);  
        //----
        if(b4plusdi < b4minusdi && nowplusdi > nowminusdi)
				{
            ExtMapBuffer1[i] = Low[i] - nShift*Point;
				    if (newCandle.IsNewCandle()) Notifications(0);
				}
        //----
        if(b4plusdi > b4minusdi && nowplusdi < nowminusdi)
					{
            ExtMapBuffer2[i] = High[i] + nShift*Point;
						if (newCandle.IsNewCandle()) Notifications(1);
					}
      }
//----
    return(0);
  }
//+------------------------------------------------------------------+

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