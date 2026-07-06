// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=72342

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
#property strict

#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots 5
#property indicator_color1 LimeGreen
#property indicator_width1 2
#property indicator_width2 2
#property indicator_color4 CornflowerBlue, Violet

input int    HalfLength    = 60;
input int    Price         = PRICE_CLOSE;
input double ATRMultiplier = 3.0;
input int    ATRPeriod     = 300;
input bool   alertsOn      = false;
input bool   alertsMessage = true;
input bool   alertsSound   = false;
input bool   alertsEmail   = false;
input bool   ribonsOn      = true;  // Ribbons On:
input color  ribonUpColor  = CornflowerBlue;
input color  ribonDnColor  = Violet;

double buffer1[];
double bandUp[];
double bandDn[];
double slope[];

//--- Ribbons
double Up_HighLimit[];
double Up_DownLimit[];

//--- Handlers
int ma1, atr;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
{
  SetIndexBuffer(0, buffer1,INDICATOR_DATA);  
	PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, HalfLength);
	PlotIndexSetInteger(0,PLOT_DRAW_TYPE,DRAW_LINE); 
	
	SetIndexBuffer(1, bandUp,INDICATOR_DATA); 
	PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, HalfLength);
  PlotIndexSetInteger(1,PLOT_DRAW_TYPE,DRAW_LINE); 

	SetIndexBuffer(2, bandDn,INDICATOR_DATA); 
  PlotIndexSetInteger(2,PLOT_DRAW_TYPE,DRAW_LINE); 
	PlotIndexSetInteger(2, PLOT_DRAW_BEGIN, HalfLength);
  
	//--- Ribons
  PlotIndexSetInteger(3,PLOT_DRAW_TYPE,DRAW_FILLING); 
  PlotIndexSetString(4,PLOT_LABEL,"Fill"); 
  PlotIndexSetString(3,PLOT_LABEL,"Fill"); 
	SetIndexBuffer(3, Up_HighLimit, INDICATOR_DATA);
  SetIndexBuffer(4, Up_DownLimit,INDICATOR_DATA);
  
	SetIndexBuffer(5, slope,INDICATOR_CALCULATIONS);

	// NOTE: handlers
	ma1 = iMA(NULL, 0, 1, 0, MODE_SMA, PRICE_CLOSE);
	atr = iATR(NULL, 0, ATRPeriod);

	return (INIT_SUCCEEDED);
}
int deinit() { return (0); }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnCalculate(const int       rates_total,
                const int       prev_calculated,
                const datetime& time[],
                const double&   open[],
                const double&   high[],
                const double&   low[],
                const double&   close[],
                const long&     tick_volume[],
                const long&     volume[],
                const int&      spread[])
{
  int counted_bars = prev_calculated;
  int i, j, k, limit;

  if (prev_calculated > 1) limit = prev_calculated - 1;
  else { limit = HalfLength - 1;
  }

  for (i = limit; i < rates_total && !IsStopped(); i++)
  {
    double sum  = (HalfLength + 1) * Ma1_index(i);
    double sumw = (HalfLength + 1);
    for (j = 1, k = HalfLength; j <= HalfLength; j++, k--)
    {
      sum += k * Ma1_index(i - j);
      sumw += k;

      int shf = Bars(_Symbol, Period()) - i;
			if (j <= shf)
      {
        sum += k * Ma1_index(i + j);
        sumw += k;
      }
    }

    double range = ATR_index(i - 10) * ATRMultiplier;
    buffer1[i]   = sum / sumw;             
    bandUp[i]    = buffer1[i] + range;
    bandDn[i]    = buffer1[i] - range;
    slope[i]     = slope[i - 1];
    
		if (buffer1[i] > buffer1[i - 1]) slope[i] = 1;
    if (buffer1[i] < buffer1[i - 1]) slope[i] = -1;

		//--- 
    if (ribonsOn)
    {
      if (slope[i] == 1)
      {
        Up_HighLimit[i] = bandUp[i];
        Up_DownLimit[i] = bandDn[i];
      }
      if (slope[i] == -1)
      {
				Up_HighLimit[i] = bandDn[i];
        Up_DownLimit[i] = bandUp[i];
      }
    }

  }
  manageAlerts();
  return (rates_total);
}

//+-------------------------------------------------------------------
//|
//+-------------------------------------------------------------------
void manageAlerts()
{
  if (alertsOn)
  {
    if (slope[0] == 1) doAlert("up");
    if (slope[0] == -1) doAlert("down");
  }
}

void doAlert(string doWhat)
{
  static string previousAlert = "nothing";
  string        message;

  if (previousAlert != doWhat)
  {
    previousAlert = doWhat;
    message = Symbol() + " TMA slope is currently " + doWhat;
    message = Symbol() + " at " + " TMA slope is currently " + doWhat;
    if (alertsMessage) Alert(message);    
		string msg;
		StringConcatenate(msg, Symbol(), "TMA centered & bands ");
    if (alertsEmail) SendMail(msg, message);
    if (alertsSound) PlaySound("alert2.wav");
  }
}

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
double Ma1_index(int shift, int buffer=0)
{
 double value[1];
 int    shf  = Bars(_Symbol, Period()) - shift;
 int    copy = CopyBuffer(ma1, buffer, shf, 1, value);
 if (copy > 0) { return value[0]; }
 //--- 
 return -1;
}

double ATR_index(int shift, int buffer=0)
{
 double value[1];
 int shf = Bars(_Symbol, Period()) - shift;
 int    copy = CopyBuffer(atr, buffer, shf, 1, value);
 if (copy > 0) { return value[0]; }
 //--- 
 return -1;
}