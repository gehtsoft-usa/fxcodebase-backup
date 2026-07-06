//Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=73455

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
#property strict

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1  clrDodgerBlue

#property indicator_level1 0.0

enum ENUM_CALCULATION_MODE
{
   CALCULATION_MODE_BALANCED,                                                                      // Balanced   
   CALCULATION_MODE_FAST,                                                                          // Fast
   CALCULATION_MODE_SLOW                                                                           // Slow
};


input  int                    i_length             = 13;                                           // Period of calculation
input  ENUM_CALCULATION_MODE  i_mode               = CALCULATION_MODE_FAST;                        // Mode of calculation
input  int                    i_indBarsCount       = 0;                                            // The number of bars to display

input string T1                    = "== Notifications ==";  // ————————————
input bool   notifications         = true;                   // Notifications On?
input bool   desktop_notifications = true;                   // Desktop MT4 Notifications
input bool   email_notifications   = false;                  // Email Notifications
input bool   push_notifications    = false;                  // Push Mobile Notifications


double            g_resSentiment[];
double            g_sentBull[];
double            g_sentBear[];
double            g_tempBull[];
double            g_tempBear[];

bool              g_activate;                                                                      // Sign of successful initialization of indicator
     

//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+

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


//| Custom indicator initialization function                                                                                                                                                          |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
int OnInit()
{
   g_activate = false;                                                                             
   
   if (!IsTuningParametersCorrect())                                                               
      return INIT_FAILED;                                 
      
   if (!BuffersBind())                             
      return (INIT_FAILED);                                 
         
   g_activate = true;                                                                              
   return INIT_SUCCEEDED;
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Checking the correctness of values of tuning parameters                                                                                                                                           |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool IsTuningParametersCorrect()
{
   string name = WindowExpertName();

   if (i_length < 1)
   {
      Alert(name, ": period of calculation must be more than zero. Indicator is off.");
      return false;
   }

   return (true);
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Binding the arrays with the indicator buffers                                                                                                                                                     |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool BuffersBind()
{
   string name = WindowExpertName();
   IndicatorBuffers(5);

   if (!SetIndexBuffer(0, g_resSentiment)     ||
       !SetIndexBuffer(1, g_sentBull)         ||
       !SetIndexBuffer(2, g_sentBear)         ||
       !SetIndexBuffer(3, g_tempBull)         ||
       !SetIndexBuffer(4, g_tempBear))
   {
      Alert(name, ": error of binding the arrays with the indicator buffers. Error ¹", GetLastError());
      return false;
   }

   SetIndexStyle(0, DRAW_LINE);
      
   string mode = "";
   switch(i_mode)
   {
      case CALCULATION_MODE_BALANCED:  mode = "Balanced"; break;
      case CALCULATION_MODE_FAST:      mode = "Fast";     break;
      case CALCULATION_MODE_SLOW:      mode = "Slow";     break;
   }

   IndicatorShortName(StringConcatenate("Sentiment (", i_length, ", ", mode, ")"));   
   IndicatorDigits(_Digits + 2);
      
   return true;
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Custom indicator deinitialization function                                                                                                                                                        |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void OnDeinit(const int reason)
{
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Determination of the index bar, from which we want to make recalculation                                                                                                                          |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
int GetRecalcIndex(int& total, const int ratesTotal, const int prevCalculated)
{
   total = ratesTotal - i_length - 1;                                                                         
                                                   
   if (i_indBarsCount > 0 && i_indBarsCount < total)
      total = MathMin(i_indBarsCount, total);                      
                                                   
   if (prevCalculated < ratesTotal - 1)                     
   {       
      InitializeBuffers();
      return (total);
   }
   
   return (MathMin(ratesTotal - prevCalculated, total));                            
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| The indicator buffers initialization                                                                                                                                                              |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void InitializeBuffers()
{
   ArrayInitialize(g_resSentiment, EMPTY_VALUE);
   ArrayInitialize(g_sentBull, 0.0);
   ArrayInitialize(g_sentBear, 0.0);
   ArrayInitialize(g_tempBull, EMPTY_VALUE);
   ArrayInitialize(g_tempBear, EMPTY_VALUE);
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Set the temporary values                                                                                                                                                                          |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void SetTheTemporary(int barIndex, double barBull, double barBear, double groupBull, double groupBear)
{
   if (barIndex == Bars - 1)
   {
      g_tempBull[barIndex] = barBull;
      g_tempBear[barIndex] = barBear;
      return;
   }

   switch(i_mode)
   {
      case CALCULATION_MODE_BALANCED:  g_tempBull[barIndex] = (barBull + groupBull) / 2;
                                       g_tempBear[barIndex] = (barBear + groupBear) / 2;
                                       break;
         
      case CALCULATION_MODE_FAST:      g_tempBull[barIndex] = barBull;
                                       g_tempBear[barIndex] = barBear;
                                       break;
      
      case CALCULATION_MODE_SLOW:      g_tempBull[barIndex] = groupBull;
                                       g_tempBear[barIndex] = groupBear;
                                       break;
   }
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Prepare the calculattion data                                                                                                                                                                     |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void PrepareData(int limit)
{
   for (int i = limit; i >= 0; i--)
   {
      int length      = (int)MathCeil(i_length / 4);
      double barhi    = iMA(NULL, 0, length, 0, MODE_LWMA, PRICE_HIGH,  i);
      double barlo    = iMA(NULL, 0, length, 0, MODE_LWMA, PRICE_LOW,   i);
      double barop    = iMA(NULL, 0, length, 0, MODE_LWMA, PRICE_OPEN,  i);
      double barcl    = iMA(NULL, 0, length, 0, MODE_LWMA, PRICE_CLOSE, i);
      double bar_range = barhi - barlo;
      
      double grouphi     = High[iHighest(NULL, 0, MODE_HIGH, i_length, i)];
      double grouplo     = Low [iLowest (NULL, 0, MODE_LOW,  i_length, i)];
      double groupop     = iOpen(NULL, 0, i + i_length - 1);
      double group_range = grouphi - grouplo;
      
      if (bar_range == 0.0)   
         bar_range = 1.0;

      if(group_range == 0) 
         group_range = 1.0;

      double barBull   = (((barcl - barlo) + (barhi - barop)) / 2) / bar_range;
      double barBear   = (((barhi - barcl) + (barop - barlo)) / 2) / bar_range;

      double groupBull = (((barcl - grouplo) + (grouphi - groupop)) / 2) / group_range;
      double groupBear = (((grouphi - barcl) + (groupop - grouplo)) / 2) / group_range;
      
      SetTheTemporary(i, barBull, barBear, groupBull, groupBear);
   }
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Show the indicator data                                                                                                                                                                           |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void ShowIndicatorData(int limit)
{
   for (int i = limit; i >= 0; i--)
   {
      g_sentBull[i] = iMAOnArray(g_tempBull, Bars, i_length, 0, 0, i);
      g_sentBear[i] = iMAOnArray(g_tempBear, Bars, i_length, 0, 0, i);
      
      g_resSentiment[i] = g_sentBull[i] - g_sentBear[i];
   }
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Custom indicator iteration function                                                                                                                                                               |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
{
   if (!g_activate)                                                                                
      return rates_total;                                 
    
   int total;   
   int limit = GetRecalcIndex(total, rates_total, prev_calculated);                                

   PrepareData(limit);
   ShowIndicatorData(limit);


	 if (newCandle.IsNewCandle())
	 {
			if(g_resSentiment[1] > g_resSentiment[2])
      {
        Notifications(0);
      }
			if(g_resSentiment[1] < g_resSentiment[2])
      {
        Notifications(1);
      }
	 }

   
   return rates_total;
}

// ------------------------------------------------------------------

void Notifications(int type)
{
  string text = "";
  if (type == 0) 
	text += _Symbol + " " + GetTimeFrame(_Period) + " Sentiment is Going UP "; 
	else
    text += _Symbol + " " + GetTimeFrame(_Period) + " Sentiment is Going DOWN ";

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