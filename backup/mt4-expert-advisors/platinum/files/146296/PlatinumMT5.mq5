// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&p=147072

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
// Your donations will allow the service to continue onward.
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
#property link "http://fxcodebase.com"
#property version "1.0"
#property strict
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots 2
#property indicator_label1 "Arrow Dn"
#property indicator_type1  DRAW_ARROW
#property indicator_style1 STYLE_SOLID
#property indicator_width1  1
#property indicator_label2 "Arrow Up"
#property indicator_type2  DRAW_ARROW
#property indicator_style2 STYLE_SOLID
#property indicator_width2  1

datetime     NewCandleTimeCurrent;
input int    Risk      = 3;
input double ArrowsGap = 1.0;
double       ArrowUp[];
double       ArrowDn[];
double       WprBuffer[];
input bool   alert_send_notification = false;  //   Alert / Send Notification

string UpcommingSignal     = "NONE";
string capture_recent_time = 0;

int wprHandle, wprHandle3,wprHandle4;

// E37F0136AA3FFAF149B351F6A4C948E9
int OnInit()
{
  capture_recent_time = iTime(NULL, 0, 0);

  SetIndexBuffer(0, ArrowDn, INDICATOR_DATA);
  PlotIndexSetInteger(0, PLOT_ARROW, 234);
  PlotIndexSetInteger(0, PLOT_ARROW_SHIFT, -10);
  PlotIndexSetInteger(0, PLOT_LINE_COLOR, Lime);

  SetIndexBuffer(1, ArrowUp, INDICATOR_DATA);
  PlotIndexSetInteger(1, PLOT_ARROW, 233);
  PlotIndexSetInteger(1, PLOT_ARROW_SHIFT, 10);
  PlotIndexSetInteger(1, PLOT_LINE_COLOR, Lime);

  SetIndexBuffer(2, WprBuffer);
	wprHandle = iWPR(NULL, 0, Risk * 2 + 3);
	wprHandle3 = iWPR(NULL, 0, 3);
  wprHandle4 = iWPR(NULL, 0, 4);
  
	return (INIT_SUCCEEDED);
}

// EA2B2676C28C0DB26D39331A336C6B92
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
  if (IsNewCandleCurrent()) {
  int    wprPeriods;
  double avg;
  bool   gapControl;
  bool   rangeControl;

  double LimitTOP    = Risk + 67.0;
  double LimitBOTTOM = 33.0 - Risk;

  int i, start, n;
  int Period = 10;

  if (prev_calculated > 1) start = prev_calculated - 1;
  else { start = Period + 1; }

  for (i = start; i < rates_total && !IsStopped(); i++) 
	{
    wprPeriods = Risk * 2 + 3;		
    avg        = 0;

		// calcula el promedio del high-low para 10 velas hacia atrás
    for (n = 0; n < 10; n++) avg += high[i - n] - low[i - n];
    avg /= 10.0;
    
		// chequea si tenés un gap
		// busca durante 6 velas hacia atrás si el fabs de Open[i] - Close[i-1] es mayor a 2*avg
		// open de la vela actual menos el cierre de la anterior
		gapControl = false;
    for (n = 0; n < 6  && !gapControl; n++) gapControl = MathAbs(open[i - n] - (close[i - n - 1])) >= 2.0 * avg;
    
		// cheques un range
		// busca durante 9 velas si el fabs CLOSE(0) - CLOSE(3) es mayor a 4.6 * avg
		// close actual - close tres velas atrás= te dá el rango de las velas entre la actual y 3 anteriores
		rangeControl = false;
    for (n = 0; n < 9  && !rangeControl; n++) rangeControl = MathAbs(close[i - n - 3] - (close[i - n])) >= 4.6 * avg;

    if (gapControl) wprPeriods = 3;
    if (rangeControl) wprPeriods = 4;

    // NOTE: WPR
		WprBuffer[i]  = calculate(0, i, wprHandle) + 100;
    if(wprPeriods == 3) WprBuffer[i]  = calculate(0, i, wprHandle3) + 100;
    if(wprPeriods == 4) WprBuffer[i]  = calculate(0, i, wprHandle4) + 100;
    
    ArrowDn[i] = EMPTY_VALUE;
    ArrowUp[i] = EMPTY_VALUE;

    string capture_time;

    if (WprBuffer[i] < LimitBOTTOM) {      

		// busca hacia atrás la última salida del buffer de los limites
		for (n = 1; (i - n > 0) && (WprBuffer[i - n] >= LimitBOTTOM) && (WprBuffer[i - n] <= LimitTOP); n++) {}

      if (WprBuffer[i - n] > LimitTOP) {
        ArrowDn[i] = high[i] + avg * ArrowsGap;

        if (alert_send_notification == true) {
          //  Buying  Goes Here
          capture_time = time[i];
          if (StringCompare(capture_recent_time, capture_time) == -1 && (UpcommingSignal == "NONE" || UpcommingSignal == "BUY")) {
            UpcommingSignal = "SELL";
            Alert("Symbol :", Symbol(), " Selling");
            SendNotification("Symbol :" + Symbol() + " Selling");
          }
        }
      }
    }  // limit bottom

    if (WprBuffer[i] > LimitTOP) {
      for (n = 1; (i - n > 0) && WprBuffer[i - n] >= LimitBOTTOM && WprBuffer[i - n] <= LimitTOP; n++) {}

      if (WprBuffer[i - n] < LimitBOTTOM) {
        ArrowUp[i] = low[i] - avg * ArrowsGap;

        if (alert_send_notification == true) {
          // Selling  Goes Here
          capture_time = time[i];

          if (StringCompare(capture_recent_time, capture_time) == -1 && (UpcommingSignal == "NONE" || UpcommingSignal == "SELL")) {
            UpcommingSignal = "BUY";
            Alert("Symbol :", Symbol(), " Buying");
            SendNotification("Symbol :" + Symbol() + " Buying");
          }
        }
      }
    }  // cierra limitTOP

  }  // cierra bucle
  }    // ciera new Candle

  return (rates_total);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsNewCandleCurrent()
{
  if (NewCandleTimeCurrent == iTime(Symbol(), PERIOD_CURRENT, 0))
    return false;
  else {
    NewCandleTimeCurrent = iTime(Symbol(), PERIOD_CURRENT, 0);
    return true;
  }
}
//+------------------------------------------------------------------+

double calculate(int buffer, int shift, int _handle)
{
 int Bars = Bars(NULL, 0);
 int    candle = Bars - shift-1;
 double value[1];
 int    copy = CopyBuffer(_handle, buffer, candle, 1, value);
 if (copy > 0) {
   return value[0];
  }
  return -1;
}