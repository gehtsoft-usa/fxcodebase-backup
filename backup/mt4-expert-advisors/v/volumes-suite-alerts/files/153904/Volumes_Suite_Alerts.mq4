//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=74509s

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright c 2024, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                    Developed by : Mario Jemic  |                                                                                      
//|                                                                         mario.jemic@gmail.com  |                                                                         
//|                                                        https://AppliedMachineLearning.systems  |                                                                      
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                              Paypal: https://goo.gl/9Rj74e     |
//|                                                            Patreon : https://goo.gl/GdXWeN     |  
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright c 2024, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

/*---------------------------------------------------------------------------------------------
User Notes:

This indicator is coded to run on MT4 Builds 600+.  It draws a PVA (Price-Volume Analysis)
volumes histogram or a standard volumes histogram in the first chart subwindow.  An alert
option signals when a "Climax" situation exists.  Specific details follow.

The PVA Volumes Histogram -
   This indicator creates PVA Volumes to be used together with the PVA Candles indicator.
   Special colors are used for candles and corresponding volume bars when notable situations
   occur involving price and volume, hence PVA (Price-Volume Analysis).  The criteria for the
   special colors used are as follows.

   Situation "Climax"
   Bars with volume >= 200% of the average volume of the 10 previous chart TFs, and bars
   where the product of candle spread x candle volume is >= the highest for the 10 previous
   chart time TFs.
   Default Colors:  Bull bars are green and bear bars are red.

   Situation "Volume Rising Above Average"
   Bars with volume >= 150% of the average volume of the 10 previous chart TFs.
   Default Colors:  Bull bars are blue and bear are blue-violet.

   PVA Color Options -
   There are three PVA color options provided....
     1. Simple:  Use this option for a simple PVA two color display based on Climax only
        situations (an option allows you to include "Rising" volume).  You can change any
        color.  To start, a shade of blue/red are input for the PVA bull/bear bars.
     2. Standard:  Use this option for the 4-color PVA display where you can change any
        color. To start, the traditional PVA colors are input.
     3. Default:  There are no inputs.  The hard coded traditional PVA colors display.
   These color options help traders suffering from color blindness by enabling them to
   choose the colors that work best for them.  Of course, there are many other reasons
   that some traders might wish to choose colors differing from the traditional colors.
   And, it is easy to return anytime to the default traditional PVA color display.

The Alert -
   This indicator includes a sound-text alert that triggers once per TF at the first
   qualification of the TF bar as a "Climax" situation.  Set "Alert_On" to "true"
   to activate the alert.  Enter your "Broker_Name_In_Alert" to avoid confusion if
   simultaneously using multiple platforms.  If also using the PVA Candles indicator,
   be sure the two alert inputs in that indicator are set to "false".

The Standard Volumes Display -
   A normal volume histogram is displayed in the single color selected.  However, you
   can highlight Climax situations with wider bars and utilize the Alert.

                                                                    - Traderathome, 05-30-2015
-----------------------------------------------------------------------------------------------
Acknowledgements:
BetterVolume.mq4 - for initial "climax" candle code definition (BetterVolume_v1.4).

----------------------------------------------------------------------------------------------
Suggested Colors            White Chart        Black Chart        Remarks

indicator_color1            White              C'010,010,010'     Chart Background
indicator_color2            C'119,146,179'     C'102,099,163'     Normal Volume
indicator_color3            C'067,100,214'     C'017,136,255'     Bull Rising
indicator_color4            C'154,038,232'     C'173,051,255'     Bear Rising
indicator_color5            C'014,165,101'     C'031,192,071'     Bull Climax
indicator_color6            C'000,166,100'     C'224,001,006'     Bear Climax
indicator_color7            C'046,055,169'     C'102,099,163'     Standard Volume

Note: Suggested colors coincide with the colors of the Candles Suite indicator.
---------------------------------------------------------------------------------------------*/


//+-------------------------------------------------------------------------------------------+
//| Indicator Global Inputs                                                                   |                                                  
//+-------------------------------------------------------------------------------------------+
#property indicator_separate_window
#property indicator_buffers 7
#property indicator_minimum 0

#property indicator_color1  White
#property indicator_color2  C'119,146,179'
#property indicator_color3  C'067,100,214'
#property indicator_color4  C'154,038,232'
#property indicator_color5  C'014,165,101'
#property indicator_color6  C'000,166,100'
#property indicator_color7  C'046,055,169'

//Global External Inputs
extern bool   Indicator_On                               = true;
extern string Volume_Window_____________                 = "";
extern color  Chart_Background_Color                     = White;
extern bool   Volume_PVA_vs_STD                          = true;
extern int    __PVA_Color_Simple_Standard_Default_123    = 3;

extern string STD_Volumes_______________                 = "";
extern color  __STD_Volumes_Color                        = C'046,055,169';
extern bool   __Highlight_Climax_Volume                  = false;

extern string PVA_Simple________________                 = "";
extern color  __Simple_Normal_Bar                        = C'119,146,179';
extern color  __Simple_Bull_Climax                       = C'067,100,214';
extern color  __Simple_Bear_Climax                       = C'214,012,083';
extern bool   __Include_Rising_Volume                    = false;

extern string PVA_Standard______________                 = "";
extern color  __Standard__Normal_Bar                     = C'119,146,179';
extern color  __Standard_Bull_Rising                     = C'067,100,214';
extern color  __Standard_Bear_Rising                     = C'154,038,232';
extern color  __Standard_Bull_Climax                     = C'000,166,100';
extern color  __Standard_Bear_Climax                     = C'214,012,083';

extern string Alert______________________                = "";
extern bool   Alert_On                                   = true;
extern string Broker_Name_In_Alert                       = "";
extern bool   alertsSound = false;

//Global Buffers and Variables
bool          Deinitialized;
color         Normal_Bar,Bull_Rising,Bear_Rising,Bull_Climax,Bear_Climax;
int           Chart_Scale,i,j,Bar_Width,counted_bars,limit,va,nvClimax;
double        Phantom[],Normal[],RisingBull[],RisingBear[],ClimaxBull[],ClimaxBear[],
              av,Range,Value2,HiValue2,tempv2;             
string        ShortName;

//Default PVA Colors
color         PVA_Normal_Bar   = C'119,146,179';
color         PVA_Bull_Rising  = C'067,100,214';
color         PVA_Bear_Rising  = C'154,038,232';
color         PVA_Bull_Climax  = C'000,166,100';
color         PVA_Bear_Climax  = C'214,012,083';

//Alert
bool          Alert_Allowed;
static bool   allow = true;
static bool   disallow = false;

// ------------------------------------------------------------------
input string TZ                    = "== Notifications ==";  // ————————————
input bool   notifications         = false;                  // Notifications On
input bool   desktop_notifications = false;                  // Desktop MT4 Notifications
input bool   email_notifications   = false;                  // Email Notifications
input bool   push_notifications = false;                    // Push Mobile Notifications
input int    minutesBetwenNotify = 1;                      // Minutes Betwen Notifications
int timeNextNotify = 0;
// ------------------------------------------------------------------


//+-------------------------------------------------------------------------------------------+
//| Custom indicator deinitialization function                                                |
//+-------------------------------------------------------------------------------------------+
int deinit()
  {
  return(0);
  }

//+-------------------------------------------------------------------------------------------+
//| Custom indicator initialization function                                                  |
//+-------------------------------------------------------------------------------------------+
int init()
  {
  Deinitialized = false;

  //Determine the current chart scale (chart scale number should be 0-5)
  Chart_Scale = ChartScaleGet();

  //Set bar widths
        if(Chart_Scale == 0) {Bar_Width = 1;}
  else {if(Chart_Scale == 1) {Bar_Width = 2;}
  else {if(Chart_Scale == 2) {Bar_Width = 2;}
  else {if(Chart_Scale == 3) {Bar_Width = 3;}
  else {if(Chart_Scale == 4) {Bar_Width = 6;}
  else {Bar_Width = 13;} }}}}

  //Phantom Volume
  SetIndexBuffer(0,Phantom);
  SetIndexStyle(0,DRAW_HISTOGRAM,0,1,Chart_Background_Color);

  //STD
  if(!Volume_PVA_vs_STD)
    {
    nvClimax = 1;
    ShortName= "Broker Tick Volume:    ";
    //Display widened Climax bars
    if(__Highlight_Climax_Volume)
      {
      if((Chart_Scale < 2) && (!Volume_PVA_vs_STD)) {nvClimax = 2;}
      if((Chart_Scale >= 2) && (!Volume_PVA_vs_STD)) {nvClimax = Bar_Width;}
      ShortName= "Broker Tick Volume, Climax Highlights:    ";
      //Alert
      if(Alert_On)
        {
        Alert_Allowed = true;
        ShortName= ShortName + "Alert On";
        }
      }
    //No display of widened Climax bars
    else
      {
      Alert_On = false;
      Alert_Allowed = false;
      }
    //Normal Volume Bars
    SetIndexBuffer(1,Normal);
    SetIndexStyle(1,DRAW_HISTOGRAM, 0, 1, __STD_Volumes_Color);
    //Climax Volume Bars
    SetIndexBuffer(2,ClimaxBull);
    SetIndexStyle(2,DRAW_HISTOGRAM, 0, nvClimax, __STD_Volumes_Color);
    SetIndexBuffer(3,ClimaxBear);
    SetIndexStyle(3,DRAW_HISTOGRAM, 0, nvClimax, __STD_Volumes_Color);
    }

  //PVA
  else
    {
    //Colors Selection for PVA
    if(__PVA_Color_Simple_Standard_Default_123==1)
      {
      Normal_Bar  = __Simple_Normal_Bar;
      Bull_Rising = __Simple_Bull_Climax;
      Bear_Rising = __Simple_Bear_Climax;
      Bull_Climax = __Simple_Bull_Climax;
      Bear_Climax = __Simple_Bear_Climax;
      if(!__Include_Rising_Volume) {ShortName= "Broker Tick PVA, Climax only:    ";}
      else {ShortName= "Broker Tick PVA:    ";}
      }
    else {if(__PVA_Color_Simple_Standard_Default_123==2)
      {
      Normal_Bar  = __Standard__Normal_Bar;
      Bull_Rising = __Standard_Bull_Rising;
      Bear_Rising = __Standard_Bear_Rising;
      Bull_Climax = __Standard_Bull_Climax;
      Bear_Climax = __Standard_Bear_Climax;
      ShortName= "Broker Tick PVA:    ";
      }
    else {if(__PVA_Color_Simple_Standard_Default_123==3)
      {
      Normal_Bar  = PVA_Normal_Bar;
      Bull_Rising = PVA_Bull_Rising;
      Bear_Rising = PVA_Bear_Rising;
      Bull_Climax = PVA_Bull_Climax;
      Bear_Climax = PVA_Bear_Climax;
      ShortName= "Broker Tick PVA:    ";
      }}}
    //PVA: Simple Normal Volume Bars
    SetIndexBuffer(1,Normal);
    SetIndexStyle(1,DRAW_HISTOGRAM, 0, 1, Normal_Bar);
    //PVA: Simple Rising Volume Bars
    SetIndexBuffer(2,RisingBull);
    SetIndexStyle(2,DRAW_HISTOGRAM, 0, Bar_Width, Bull_Rising);
    SetIndexBuffer(3,RisingBear);
    SetIndexStyle(3,DRAW_HISTOGRAM, 0, Bar_Width, Bear_Rising);
    //PVA: Simple Climax Volume Bars
    SetIndexBuffer(4,ClimaxBull);
    SetIndexStyle(4,DRAW_HISTOGRAM, 0, Bar_Width, Bull_Climax);
    SetIndexBuffer(5,ClimaxBear);
    SetIndexStyle(5,DRAW_HISTOGRAM, 0, Bar_Width, Bear_Climax);
    //Alert
    if(Alert_On)
      {
      Alert_Allowed = true;
      ShortName= ShortName + "Alert On";
      }
    }

  //Indicator ShortName, Index Digits & Labels
  IndicatorDigits(0);
  SetIndexLabel(0, NULL);
  if(Alert_On) {ShortName= ShortName + ",  Count ";}
  else {ShortName= ShortName + "Count ";}
  SetIndexLabel(1, IntegerToString(0));
  SetIndexLabel(2, NULL);
  SetIndexLabel(3, NULL);
  SetIndexLabel(4, NULL);
  SetIndexLabel(5, NULL);
  SetIndexLabel(6, NULL);
  IndicatorShortName (ShortName);

  return(0);
  }

//+-------------------------------------------------------------------------------------------+
//| Custom indicator iteration function                                                       |
//+-------------------------------------------------------------------------------------------+
int start()
  {
  //If Indicator is "Off" deinitialize only once, not every tick
  if (!Indicator_On)
    {
    if (!Deinitialized) {deinit(); Deinitialized = true;}
    return(0);
    }

  //Confirm range of chart bars for calculations
  //check for possible errors
  counted_bars = IndicatorCounted();
  if(counted_bars < 0)  return(-1);
  //last counted bar will be recounted
  if(counted_bars > 0) counted_bars--;
  limit = Bars - counted_bars;

  //Begin the loop of calculations for the range of chart bars.
  for(i = limit - 1; i >= 0; i--)
    {
    //Define Phantom volume larger than Normal, which displayed without color
    //assures Normal volume will occupy only the lower 75% of the volume window
    Phantom[i]= Volume[i]/0.75;

    //Define Normal volume
    Normal[i] = int(Volume[i]);

    if((Volume_PVA_vs_STD) || (__Highlight_Climax_Volume))
    {    
    //Clear buffers
    RisingBull[i] = 0;
    RisingBear[i] = 0;
    ClimaxBull[i] = 0;
    ClimaxBear[i] = 0;
    av            = 0;
    va            = 0;

    //Rising Volume
    for(j = i+1; j <= i+10; j++) {av = av + int(Volume[j]);}
    av = av / 10;

    //Climax Volume
    Range = (High[i]-Low[i]);
    Value2 = Volume[i]*Range;
    HiValue2 = 0;
    for(j = i+1; j <= i+10; j++)
      {
      tempv2 = Volume[j]*((High[j]-Low[j]));
      if (tempv2 >= HiValue2) {HiValue2 = tempv2;}
      }
    if((Value2 >= HiValue2) || (Volume[i] >= av * 2)) {va = 1;}

    //Rising Volume
    if( ((va == 0) && (Volume_PVA_vs_STD)) &&
      ((__PVA_Color_Simple_Standard_Default_123 > 1) ||
      ((__PVA_Color_Simple_Standard_Default_123 == 1) && (__Include_Rising_Volume))))
      {
      if(Volume[i] >= av * 1.5) {va= 2;}
      }

    //Apply Correct Color to bars
    if(va==1)
      {
      //Bull Candle
      if(Close[i] > Open[i])
        {
        ClimaxBull[i] = int(Volume[i]);
        }
      //Bear Candle
      else if (Close[i] <= Open[i])
        {
        ClimaxBear[i] = int(Volume[i]);
        }
      //Sound & Text Alert
      if(i == 0 && Alert_Allowed && Alert_On)
        {
        Alert_Allowed = false;
        Alert(Broker_Name_In_Alert, ":  ", Symbol(), "-", Period(), "   PVA alert!");
        if (alertsSound)   PlaySound("alert2.wav");
      }
      }
    else if(va==2)
      {
      if(Close[i] > Open[i]) {RisingBull[i] = int(Volume[i]);}
      if(Close[i] <= Open[i]) {RisingBear[i] = int(Volume[i]);}
      }      
    }  
    }//End "for i" loop

  return(0);
  }

//+-------------------------------------------------------------------------------------------+
//| Subroutine:  Set up to get the chart scale number                                         |
//+-------------------------------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
  {
  Chart_Scale = ChartScaleGet();
  if(Alert_Allowed == allow)
    {
    init();
    Alert_Allowed = allow;
    }
  else
    {
    init();
    Alert_Allowed = disallow;
    }
  }

//+-------------------------------------------------------------------------------------------+
//| Subroutine:  Get the chart scale number                                                   |
//+-------------------------------------------------------------------------------------------+
int ChartScaleGet()
  {
  long result = -1;
  ChartGetInteger(0,CHART_SCALE,0,result);
  return((int)result);
  }

//+-------------------------------------------------------------------------------------------+
//|Custom indicator end                                                                       |
//+-------------------------------------------------------------------------------------------+


void Notifications(int type)
{
    // time Control
    if(timeNextNotify != 0) if(TimeCurrent() < timeNextNotify) return;
    timeNextNotify = TimeCurrent() + (minutesBetwenNotify * 60);
        
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
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
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