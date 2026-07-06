//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=74699

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
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

#property copyright "Copyright © 2024, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_minimum - 45.0
#property indicator_maximum 45.0
#property indicator_color1 clrOrange
#property indicator_color2 clrLawnGreen
#property indicator_color3 clrRed
#property indicator_color4 clrBlue
#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 2
#property indicator_width4 2
#property indicator_level2 12.0
#property indicator_level3 - 12.0
#property strict

//
//
//
//
//

extern int                Per             = 5;            // Period to use
extern ENUM_MA_METHOD     Ma_Type         = 0;            // Ma type to use
extern ENUM_APPLIED_PRICE Price           = 4;            // Price to use
extern bool               alertsOn        = false;        // Turn alerts on?
extern bool               alertsOnCurrent = false;        // Alerts on still opened bar?
extern bool               alertsMessage   = true;         // Alerts should display message?
extern bool               alertsSound     = false;        // Alerts should play a sound?
extern bool               alertsNotify    = false;        // Alerts should send a notification?
extern bool               alertsEmail     = false;        // Alerts should send an email?
extern string             soundFile       = "alert2.wav"; // Sound file

double AboveBuff[], ShortBuff[], LongBuffe[], BelowBuff[];

// ------------------------------------------------------------------

input string TArrows    = "== Set Arrows ==";     // Set Arrows
input bool   ArrowsOn   = true;                   // Arrows On?
input color  ArrowUpClr = clrBlue;                // Arrow Up Color:
input color  ArrowDnClr = clrRed;                 // Arrow Down Color:

class Arrow
{
    string   _name;
    datetime _iniTm;
    double   _price;
    color    _clr;
    string   _txt;
    string   _type;
    int      _count;
    int      _arrowCode;

  public:
    Arrow() { ; }
    Arrow(string inpName, datetime inpIniTm, double inpPrice, color inpClr, string inpLabelTxt = "", string inpType = "up")
    {
        _name  = inpName;
        _iniTm = inpIniTm;
        _price = inpPrice;
        _clr   = inpClr;
        _txt   = inpLabelTxt;
        _type  = inpType;
    }
    ~Arrow()
    {
        ObjectsDeleteAll(0, "Arrow");
    }

    Arrow* price(double inpPrice)
    {
        _price = inpPrice;
        return &this;
    }
    Arrow* txt(string inpTxt)
    {
        _txt = inpTxt;
        return &this;
    }
    Arrow* Color(color clr)
    {
        _clr = clr;
        return &this;
    }
    Arrow* Type(string direction)
    {
        _type = direction;
        return &this;
    }
    Arrow* candle(int shift)
    {
        _iniTm = TimeByCandles(shift);
        return &this;
    }
    Arrow* ArrowCode(int code)
    {
        _arrowCode = code;
        return &this;
    }

    datetime TimeByCandles(int candlesBack)
    {
        _iniTm = Time[candlesBack];
        return _iniTm;
    }

    void draw()
    {
        // draw arrow
        if (_type == "up") {
            _name = AutoName();
            //  _iniTm = TimeByCandles(1);
            ObjectCreate(0, _name, OBJ_ARROW, 0, _iniTm, 0, 0, 0);

            int arrowCode = _arrowCode == 0 ? 233 : _arrowCode;
            ObjectSetInteger(0, _name, OBJPROP_ARROWCODE, arrowCode); // Set the arrow code
            ObjectSetInteger(0, _name, OBJPROP_ANCHOR, ANCHOR_TOP);   // Set the arrow Anchor
                                                                      //  ObjectSetDouble(0, _name, OBJPROP_PRICE, iLow(Symbol(), Period(), 1) -100*_Point);  // Set price
            ObjectSetDouble(0, _name, OBJPROP_PRICE, _price);         // Set price
        }

        if (_type == "down") {
            _name = AutoName();
            // _iniTm = TimeByCandles(1);
            ObjectCreate(0, _name, OBJ_ARROW, 0, _iniTm, _price, TimeCurrent(), _price);

            int arrowCode = _arrowCode == 0 ? 234 : _arrowCode;
            ObjectSetInteger(0, _name, OBJPROP_ARROWCODE, arrowCode);  // Set the arrow code
            ObjectSetInteger(0, _name, OBJPROP_ANCHOR, ANCHOR_BOTTOM); // Set the arrow Anchor
            // ObjectSetDouble(0,_name,OBJPROP_PRICE,iHigh(Symbol(),Period(),1)+100*_Point);// Set price
            ObjectSetDouble(0, _name, OBJPROP_PRICE, _price); // Set price
        }
        ObjectSetInteger(0, _name, OBJPROP_COLOR, _clr);

        // draw label
        if (_txt != NULL) {
            //  Period() * 2 * 60
            ObjectCreate(0, _name + "Label", OBJ_TEXT, 0, TimeCurrent(), _price);
            ObjectSetInteger(0, _name + "Label", OBJPROP_ANCHOR, ANCHOR_RIGHT);
            ObjectSetString(0, _name + "Label", OBJPROP_FONT, "Calibri Light");
            ObjectSetInteger(0, _name + "Label", OBJPROP_FONTSIZE, 8);
            ObjectSetInteger(0, _name + "Label", OBJPROP_COLOR, _clr);
            ObjectSetString(0, _name + "Label", OBJPROP_TEXT, _txt);
            // ObjectSetInteger(0, _name + "Label", OBJPROP_STYLE, STYLE_DOT);
        }
    }

    void erase()
    {
        ObjectDelete(0, _name);
        ObjectDelete(0, _name + "Label");
    }

    Arrow* redraw()
    {
        erase();
        draw();
        return &this;
    }

    string AutoName()
    {
        _count++;
        _name = "arrow ";
        return _name + _count;
    }

    void EraseAll()
    {
        ObjectsDeleteAll(0, OBJ_ARROW);
    }
};

Arrow arrow();
// ------------------------------------------------------------------

// ---
int init()
{
    SetIndexBuffer(0, AboveBuff);
    SetIndexStyle(0, DRAW_HISTOGRAM);
    SetIndexLabel(0, "Above");
    SetIndexBuffer(1, BelowBuff);
    SetIndexStyle(1, DRAW_HISTOGRAM);
    SetIndexLabel(1, "Below");
    SetIndexBuffer(2, ShortBuff);
    SetIndexStyle(2, DRAW_ARROW);
    SetIndexArrow(2, 108);
    SetIndexBuffer(3, LongBuffe);
    SetIndexStyle(3, DRAW_ARROW);
    SetIndexArrow(3, 108);

    SetLevelStyle(STYLE_DOT, 0, SteelBlue);
    IndicatorShortName(" Forex MTN ");
    return (0);
}

int deinit() { 
   arrow.EraseAll();
   return (0); 
}

//
//
//
//
//

int start()
{
    int counted_bars = IndicatorCounted();
    if (counted_bars < 0)
        return (-1);
    if (counted_bars > 0)
        counted_bars--;
    int limit = fmin(Bars - counted_bars, Bars - 2);

    //
    //
    //
    //
    //

    for (int i = limit; i >= 0; i--) {
        double Main = iMA(NULL, 0, Per, 0, Ma_Type, Price, i);
        double Minr = 0.2 * iATR(NULL, 0, Per, i);

        if (Minr != 0) {
            AboveBuff[i] = 3.0 * (High[i] - Main) / Minr;
            BelowBuff[i] = 3.0 * (Low[i] - Main) / Minr;
        }

        ShortBuff[i] = (AboveBuff[i] > 24.0) ? 25 : EMPTY_VALUE;
        LongBuffe[i] = (BelowBuff[i] < -24.0) ? -25 : EMPTY_VALUE;

        if(ArrowsOn){
            if(LongBuffe[i+1] != EMPTY_VALUE) arrow.price(Low[i+1]).Color(ArrowUpClr).Type("up").candle(i+1).draw();
            if(ShortBuff[i+1] != EMPTY_VALUE) arrow.price(High[i+1]).Color(ArrowDnClr).Type("down").candle(i+1).draw();         
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
    if (alertsOn) {
        int whichBar = 1;
        if (alertsOnCurrent)
            whichBar = 0;
        static datetime time1 = 0;
        static string   mess1 = "";
        if (ShortBuff[whichBar] != EMPTY_VALUE || LongBuffe[whichBar] != EMPTY_VALUE) {
            if (ShortBuff[whichBar] != EMPTY_VALUE && ShortBuff[whichBar + 1] == EMPTY_VALUE)
                doAlert(time1, mess1, whichBar, "up");
            if (LongBuffe[whichBar] != EMPTY_VALUE && LongBuffe[whichBar + 1] == EMPTY_VALUE)
                doAlert(time1, mess1, whichBar, "down");
        }
    }
}

//
//
//
//
//

void doAlert(datetime& previousTime, string& previousAlert, int forBar, string doWhat)
{
    string message;

    if (previousAlert != doWhat || previousTime != Time[forBar]) {
        previousAlert = doWhat;
        previousTime  = Time[forBar];

        //
        //
        //
        //
        //

        message = StringConcatenate(Symbol(), " at ", TimeToStr(TimeLocal(), TIME_SECONDS), " ForexMTN ", doWhat);
        if (alertsMessage)
            Alert(message);
        if (alertsNotify)
            SendNotification(message);
        if (alertsEmail)
            SendMail(StringConcatenate(Symbol(), " ForexMTN "), message);
        if (alertsSound)
            PlaySound(soundFile);
    }
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