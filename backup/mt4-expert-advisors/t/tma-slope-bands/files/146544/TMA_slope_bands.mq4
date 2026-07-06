// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=72342

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
#property indicator_buffers 10
#property indicator_color1 LimeGreen
#property indicator_color2 PaleVioletRed
#property indicator_color3 PaleVioletRed
#property indicator_color4 LimeGreen
#property indicator_color5 PaleVioletRed
#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 2
#property indicator_width4 3
#property indicator_width5 3
#property indicator_style4 STYLE_SOLID
#property indicator_style5 STYLE_SOLID

#property indicator_label7 "Up"
#property indicator_type7  DRAW_HISTOGRAM
#property indicator_color7 CornflowerBlue
#property indicator_style7 STYLE_SOLID
#property indicator_width7 5
#property indicator_label9 "Down"
#property indicator_type9  DRAW_HISTOGRAM
#property indicator_color9 Violet
#property indicator_style9 STYLE_SOLID
#property indicator_width9 5

//
//
//
//
//

extern int    HalfLength    = 60;
extern int    Price         = PRICE_CLOSE;
extern double ATRMultiplier = 3.0;
extern int    ATRPeriod     = 300;
extern bool   alertsOn      = false;
extern bool   alertsMessage = true;
extern bool   alertsSound   = false;
extern bool   alertsEmail   = false;
input bool    ribonsOn      = true;  // Ribbons On:

double buffer1[];
double buffer2a[];
double buffer2b[];
double bandUp[];
double bandDn[];
double slope[];

//--- Ribbons
double Up_HighLimit[];
double Up_DownLimit[];
double Dn_HighLimit[];
double Dn_DownLimit[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//

int init()
{
  HalfLength = MathMax(HalfLength, 1);
  IndicatorBuffers(10);
  SetIndexBuffer(0, buffer1); SetIndexDrawBegin(0, HalfLength);
  SetIndexBuffer(1, buffer2a); SetIndexDrawBegin(1, HalfLength);
  SetIndexBuffer(2, buffer2b); SetIndexDrawBegin(2, HalfLength);
  SetIndexBuffer(3, bandUp); SetIndexDrawBegin(3, HalfLength);
  SetIndexBuffer(4, bandDn); SetIndexDrawBegin(4, HalfLength);
  SetIndexBuffer(5, slope);
  //--- Ribons
  SetIndexBuffer(6, Up_HighLimit);
  SetIndexBuffer(7, Up_DownLimit);
  SetIndexBuffer(8, Dn_HighLimit);
  SetIndexBuffer(9, Dn_DownLimit);

  return (0);
}
int deinit() { return (0); }

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
  int counted_bars = IndicatorCounted();
  int i, j, k, limit;

  if (counted_bars < 0) return (-1);
  if (counted_bars > 0) counted_bars--;
  limit = MathMin(Bars - counted_bars + HalfLength, Bars - 1);

  //
  //
  //
  //
  //

  if (slope[limit] == -1) CleanPoint(limit, buffer2a, buffer2b);
  for (i = limit; i >= 0; i--)
  {
    double sum  = (HalfLength + 1) * iMA(NULL, 0, 1, 0, MODE_SMA, Price, i);
    double sumw = (HalfLength + 1);
    for (j = 1, k = HalfLength; j <= HalfLength; j++, k--)
    {
      sum += k * iMA(NULL, 0, 1, 0, MODE_SMA, Price, i + j);
      sumw += k;
      if (j <= i)
      {
        sum += k * iMA(NULL, 0, 1, 0, MODE_SMA, Price, i - j);
        sumw += k;
      }
    }
    double range = iATR(NULL, 0, ATRPeriod, i + 10) * ATRMultiplier;
    buffer1[i]   = sum / sumw;
    bandUp[i]    = buffer1[i] + range;
    bandDn[i]    = buffer1[i] - range;
    buffer2a[i]  = EMPTY_VALUE;
    buffer2b[i]  = EMPTY_VALUE;
    slope[i]     = slope[i + 1];
    if (buffer1[i] > buffer1[i + 1]) slope[i] = 1;
    if (buffer1[i] < buffer1[i + 1]) slope[i] = -1;
    if (slope[i] == -1) PlotPoint(i, buffer2a, buffer2b, buffer1);

    if (ribonsOn)
    {
      if (slope[i] == 1)
      {
        Up_HighLimit[i] = bandUp[i];
        Up_DownLimit[i] = bandDn[i];
      }
      if (slope[i] == -1)
      {
        Dn_HighLimit[i] = bandUp[i];
        Dn_DownLimit[i] = bandDn[i];
      }
    }
 	
  }
  manageAlerts();
  return (0);
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
    if (slope[0] == 1) doAlert("up");
    if (slope[0] == -1) doAlert("down");
  }
}

//
//
//
//
//

void doAlert(string doWhat)
{
  static string previousAlert = "nothing";
  string        message;

  if (previousAlert != doWhat)
  {
    previousAlert = doWhat;

    //
    //
    //
    //
    //

    message = Symbol() + " at " + TimeToStr(TimeLocal(), TIME_SECONDS) + " TMA slope is currently " + doWhat;
    if (alertsMessage) Alert(message);
    if (alertsEmail) SendMail(StringConcatenate(Symbol(), "TMA centered & bands "), message);
    if (alertsSound) PlaySound("alert2.wav");
  }
}

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
//
//
//
//
//

void CleanPoint(int i, double& first[], double& second[])
{
  if ((second[i] != EMPTY_VALUE) && (second[i + 1] != EMPTY_VALUE))
    second[i + 1] = EMPTY_VALUE;
  else if ((first[i] != EMPTY_VALUE) && (first[i + 1] != EMPTY_VALUE) && (first[i + 2] == EMPTY_VALUE))
    first[i + 1] = EMPTY_VALUE;
}

//
//
//
//
//

void PlotPoint(int i, double& first[], double& second[], double& from[])
{
  if (first[i + 1] == EMPTY_VALUE)
  {
    if (first[i + 2] == EMPTY_VALUE)
    {
      first[i]     = from[i];
      first[i + 1] = from[i + 1];
      second[i]    = EMPTY_VALUE;
    } else
    {
      second[i]     = from[i];
      second[i + 1] = from[i + 1];
      first[i]      = EMPTY_VALUE;
    }
  } else
  {
    first[i]  = from[i];
    second[i] = EMPTY_VALUE;
  }
}