//Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=73555

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
#property strict
#property indicator_chart_window
//--- input parameters
enum mode {
    Standard,
    Fibonacci,
    Camarilla,
    Woodie,
    Demark
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum lbCorner {
    TopLeft     = 0,  // Top Left
    TopRight    = 1,  // Top Right
    BottomLeft  = 2,  // Bottom Left
    BottomRight = 3   // Bottom Right
};
extern mode            Pmode       = Standard;         // Pivot Mode
extern ENUM_TIMEFRAMES inpPeriod   = PERIOD_D1;        // Pivot Time Frame
extern bool            HLINE       = false;            // Full Horizontal Lines
extern int             xShift      = 3;                // X-Axis Shift
extern int             xLen        = 25;               // Line Length
extern lbCorner        LabelCorner = TopRight;         // Label Corner
extern color           LevelPP     = SpringGreen;      // Pivot Point
extern ENUM_LINE_STYLE StylePP     = 0;                // Line Style
extern int             WidthPP     = 1;                // Line Width
extern color           LevelR1     = Crimson;          // R1
extern ENUM_LINE_STYLE StyleR1     = 2;                // Line Style
extern int             WidthR1     = 1;                // Line Width
extern color           LevelR2     = Crimson;          // R2
extern ENUM_LINE_STYLE StyleR2     = 1;                // Line Style
extern int             WidthR2     = 1;                // Line Width
extern color           LevelR3     = Crimson;          // R3
extern ENUM_LINE_STYLE StyleR3     = 0;                // Line Style
extern int             WidthR3     = 1;                // Line Width
extern color           LevelS1     = DodgerBlue;       // S1
extern ENUM_LINE_STYLE StyleS1     = 2;                // Line Style
extern int             WidthS1     = 1;                // Line Width
extern color           LevelS2     = DodgerBlue;       // S2
extern ENUM_LINE_STYLE StyleS2     = 1;                // Line Style
extern int             WidthS2     = 1;                // Line Width
extern color           LevelS3     = DodgerBlue;       // S3
extern ENUM_LINE_STYLE StyleS3     = 0;                // Line Style
extern int             WidthS3     = 1;                // Line Width
extern color           LevelYH     = MediumVioletRed;  // Yesterday's High
extern ENUM_LINE_STYLE StyleYH     = 2;                // Line Style
extern int             WidthYH     = 3;                // Line Width
extern color           LevelYL     = MediumSlateBlue;  // Yesterday's Low
extern ENUM_LINE_STYLE StyleYL     = 2;                // Line Style
extern int             WidthYL     = 3;                // Line Width
extern string          Font        = "Arial";          // Font
extern int             FontSize    = 8;                // Font Size
extern int             PivotBar    = 1;                // Bar (EXPERIMENTAL! current=0; default=1)

input string T1                    = "== Notifications ==";  // ————————————
input bool   notifications         = false;                  // Notifications On?
input bool   desktop_notifications = false;                  // Desktop MT4 Notifications
input bool   email_notifications   = false;                  // Email Notifications
input bool   push_notifications    = false;                  // Push Mobile Notifications
input int    hoursBetweenAlerts    = 4;                      // Hours Between Alerts

datetime     timeNextAlert         = 0;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double x, xR1, xR2, xR3, xS1, xS2, xS3, xPP;
int    LINE_TYPE;

// ------------------------------------------------------------------
double     prices[7];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
{
    int xOffset = 10;
    int yOffset = 20;
    int Line    = 5 + FontSize;
    if (HLINE)
        LINE_TYPE = OBJ_HLINE;
    else
        LINE_TYPE = OBJ_TREND;

    if (LabelCorner < 2)
    {
        ObjectMakeLabel("pInfo", xOffset, yOffset);
        ObjectMakeLabel("lbR3", xOffset, Line + yOffset);
        ObjectMakeLabel("lbR2", xOffset, 2 * Line + yOffset);
        ObjectMakeLabel("lbR1", xOffset, 3 * Line + yOffset);
        ObjectMakeLabel("lbPP", xOffset, 4 * Line + yOffset);
        ObjectMakeLabel("lbS1", xOffset, 5 * Line + yOffset);
        ObjectMakeLabel("lbS2", xOffset, 6 * Line + yOffset);
        ObjectMakeLabel("lbS3", xOffset, 7 * Line + yOffset);
    } else
    {
        ObjectMakeLabel("lbS3", xOffset, yOffset);
        ObjectMakeLabel("lbS2", xOffset, Line + yOffset);
        ObjectMakeLabel("lbS1", xOffset, 2 * Line + yOffset);
        ObjectMakeLabel("lbPP", xOffset, 3 * Line + yOffset);
        ObjectMakeLabel("lbR1", xOffset, 4 * Line + yOffset);
        ObjectMakeLabel("lbR2", xOffset, 5 * Line + yOffset);
        ObjectMakeLabel("lbR3", xOffset, 6 * Line + yOffset);
        ObjectMakeLabel("pInfo", 10, 7 * Line + yOffset);
    }
    return (0);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
{
    DrawLevel("R3", 0, StyleR3, WidthR3, LevelR3);
    DrawLevel("R2", 0, StyleR2, WidthR2, LevelR2);
    DrawLevel("R1", 0, StyleR1, WidthR1, LevelR1);
    DrawLevel("PP", 0, StylePP, WidthPP, LevelPP);
    DrawLevel("S1", 0, StyleS1, WidthS1, LevelS1);
    DrawLevel("S2", 0, StyleS2, WidthS2, LevelS2);
    DrawLevel("S3", 0, StyleS3, WidthS3, LevelS3);
    DrawLevel("Yesterdays High", 0, StyleYH, WidthYH, LevelYH);
    DrawLevel("Yesterdays Low", 0, StyleYL, WidthYL, LevelYL);

    ObjectDelete("pInfo");
    ObjectDelete("lbR3");
    ObjectDelete("lbR2");
    ObjectDelete("lbR1");
    ObjectDelete("lbPP");
    ObjectDelete("lbS1");
    ObjectDelete("lbS2");
    ObjectDelete("lbS3");

    return (0);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
{
    //--- Yesterday's High/Low
    double xYH = iHigh(NULL, PERIOD_D1, 1);
    double xYL = iLow(NULL, PERIOD_D1, 1);

    //--- Pivot Points
    double xOpen  = iOpen(NULL, inpPeriod, PivotBar);
    double xClose = iClose(NULL, inpPeriod, PivotBar);
    double xHigh  = iHigh(NULL, inpPeriod, PivotBar);
    double xLow   = iLow(NULL, inpPeriod, PivotBar);
    xPP           = (xHigh + xLow + xClose) / 3;
    double xRange = xHigh - xLow;

    //--- Standard Pivot
    if (Pmode == Standard)
    {
        xR1 = (2 * xPP) - xLow;
        xS1 = (2 * xPP) - xHigh;
        xR2 = xPP + xRange;
        xS2 = xPP - xRange;
        xR3 = xHigh + 2 * (xPP - xLow);
        xS3 = xLow - 2 * (xHigh - xPP);
    }
    //--- Fibonacci's Pivot
    else if (Pmode == Fibonacci)
    {
        xR1 = xPP + 0.382 * xRange;
        xR2 = xPP + 0.618 * xRange;
        xR3 = xPP + 1.000 * xRange;
        xS1 = xPP - 0.382 * xRange;
        xS2 = xPP - 0.618 * xRange;
        xS3 = xPP - 1.000 * xRange;
    }
    //--- Camarilla Pivot
    else if (Pmode == Camarilla)
    {
        xR1 = xClose + (0.275 * xRange);  // H3 Short
        xR2 = xClose + (0.55 * xRange);   // H4 Long Breakout
        xR3 = (xHigh / xLow) * xClose;    // H5 LB Target
        xS1 = xClose - (0.275 * xRange);  // L3 Long
        xS2 = xClose - (0.55 * xRange);   // L4 Short Breakout
        xS3 = xClose - (xR3 - xClose);    // L5 SB Target
    }
    //--- Woodie's Pivot
    else if (Pmode == Woodie)
    {
        xPP = (xHigh + xLow + 2 * xClose) / 4;
        xR1 = 2 * xPP - xLow;
        xR2 = xPP + xRange;
        xR3 = 0;  // Not used
        xS1 = 2 * xPP - xHigh;
        xS2 = xPP - xRange;
        xS3 = 0;  // Not used
    }
    //--- Demark Pivot
    else if (Pmode == Demark)
    {
        if (xClose < xOpen) x = xHigh + (2 * xLow) + xClose;
        if (xClose > xOpen) x = (2 * xHigh) + xLow + xClose;
        if (xClose == xOpen) x = xHigh + xLow + (2 * xClose);
        xPP = 0;  // Not used
        xR3 = x / 2 - xLow;
        xS3 = x / 2 - xHigh;
        xR1 = 0;  // R1, R2, S1 and S2 Not used
        xR2 = 0;
        xS1 = 0;
        xS2 = 0;
    }

    //--- Draw Lines
    DisplayMode();
    if (inpPeriod >= Period())
    {
        if (Period() <= 1440)
        {
            DrawLevel("Yesterdays High", xYH, StyleYH, WidthYH, LevelYH);
            DrawLevel("Yesterdays Low", xYL, StyleYL, WidthYL, LevelYL);
        }
        DrawLevel("R3", xR3, StyleR3, WidthR3, LevelR3);
        DrawLevel("R2", xR2, StyleR2, WidthR2, LevelR2);
        DrawLevel("R1", xR1, StyleR1, WidthR1, LevelR1);
        DrawLevel("PP", xPP, StylePP, WidthPP, LevelPP);
        DrawLevel("S1", xS1, StyleS1, WidthS1, LevelS1);
        DrawLevel("S2", xS2, StyleS2, WidthS2, LevelS2);
        DrawLevel("S3", xS3, StyleS3, WidthS3, LevelS3);
    } else
        DrawLevel("PP", xPP, StylePP, WidthPP, LevelPP);


//--- get prices and check for alerts:
        prices[0] = xR3;
        prices[1] = xR2;
        prices[2] = xR1;
        prices[3] = xPP;
        prices[4] = xS1;
        prices[5] = xS2;
        prices[6] = xS3;
        checkPricesForAlerts();

    return (0);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawLevel(string a_name_0, double ad, int a_style, int Width, color a_color)
{
    double l_price = ad;
    int    l_timeA;
    int    l_timeB;
    double diff = Period() * 60;
    l_timeA     = (int)(Time[0] + xShift * diff);
    l_timeB     = (int)(Time[0] - (xLen - xShift) * diff);

    if (ad > 0.0)
    {
        if (ObjectFind(a_name_0) != 0)
        {
            ObjectCreate(a_name_0, LINE_TYPE, 0, l_timeA, l_price, l_timeB, l_price);
            ObjectSet(a_name_0, OBJPROP_RAY, False);
            ObjectSet(a_name_0, OBJPROP_COLOR, a_color);
            ObjectSet(a_name_0, OBJPROP_WIDTH, Width);
            ObjectSet(a_name_0, OBJPROP_STYLE, a_style);
            ObjectSet(a_name_0, OBJPROP_SELECTABLE, false);
            ObjectSet(a_name_0, OBJPROP_HIDDEN, true);
            return;
        }
        ObjectSet(a_name_0, OBJPROP_RAY, False);
        ObjectMove(a_name_0, 0, l_timeA, l_price);
        ObjectMove(a_name_0, 1, l_timeB, l_price);
        ObjectSet(a_name_0, OBJPROP_COLOR, a_color);
        ObjectSet(a_name_0, OBJPROP_WIDTH, Width);
        ObjectSet(a_name_0, OBJPROP_STYLE, a_style);
        ObjectSet(a_name_0, OBJPROP_SELECTABLE, false);
        ObjectSet(a_name_0, OBJPROP_HIDDEN, true);
        return;
    }
    if (ObjectFind(a_name_0) >= 0) ObjectDelete(a_name_0);
}
//+--------------------------------------------------------------------------+
//| ObjectMakeLabel:                                                         |
//|                                                            P4L Clock.mq4 |
//| New rewrite by: Pips4life, a user at forexfactory.com                    |
//| 2014-Mar-19: v2_12  P4L Clock.mq4                                        |
//| For lastest version: http://www.forexfactory.com/showthread.php?t=109305 |
//| Previous names: Clock_v1_3.mq4, Clock.mq4, ...                           |
//| Previous version:   Jerome,  4xCoder@gmail.com, ...                      |
///+-------------------------------------------------------------------------+
int ObjectMakeLabel(string n, int xoff, int yoff)
{
    if (!WindowIsVisible(0)) return (-1);
    ObjectCreate(n, OBJ_LABEL, 0, 0, 0);
    ObjectSet(n, OBJPROP_CORNER, LabelCorner);
    ObjectSet(n, OBJPROP_XDISTANCE, xoff);
    ObjectSet(n, OBJPROP_YDISTANCE, yoff);
    ObjectSet(n, OBJPROP_BACK, false);
    ObjectSet(n, OBJPROP_SELECTABLE, false);
    ObjectSet(n, OBJPROP_HIDDEN, true);
    return (0);
}  // end of ObjectMakeLabel
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DisplayMode()
{
    string sR3, sR2, sR1, sPP, sS1, sS2, sS3, sPointer;
    sR3 = "";
    sR2 = "";
    sR1 = "";
    sPP = "";
    sS1 = "";
    sS2 = "";
    sS3 = "";
    if (LabelCorner < 2)
        sPointer = ">> ";
    else
        sPointer = "";
    double vbid = MarketInfo(NULL, MODE_BID);

    if (vbid >= xR3)
    {
        sR3 = sPointer;
    } else if (vbid >= xR2)
    {
        sR2 = sPointer;
    } else if (vbid >= xR1)
    {
        sR1 = sPointer;
    } else if (vbid > xS1)
    {
        sPP = sPointer;
    } else if (vbid <= xS3)
    {
        sS3 = sPointer;
    } else if (vbid <= xS2)
    {
        sS2 = sPointer;
    } else if (vbid <= xS1)
    {
        sS1 = sPointer;
    }
    string pivPeriod = "M" + IntegerToString(inpPeriod);
    if (inpPeriod >= 60) pivPeriod = "H" + IntegerToString(inpPeriod / 60);
    if (inpPeriod >= 1440) pivPeriod = "D1";
    if (inpPeriod >= 10080) pivPeriod = "WK";
    if (inpPeriod >= 43200) pivPeriod = "MN";

    string pivInfo = EnumToString(Pmode) + " (" + pivPeriod + ")";
    if (LabelCorner < 2)
    {
        ObjectSetText("pInfo", pivInfo, 16, "Arial", Black);
        ObjectSetText("lbR3", sR3 + "R3 = " + DoubleToStr(xR3, Digits), FontSize, Font, LevelR3);
        ObjectSetText("lbR2", sR2 + "R2 = " + DoubleToStr(xR2, Digits), FontSize, Font, LevelR2);
        ObjectSetText("lbR1", sR1 + "R1 = " + DoubleToStr(xR1, Digits), FontSize, Font, LevelR1);
        ObjectSetText("lbPP", sPP + "PP = " + DoubleToStr(xPP, Digits), FontSize, Font, LevelPP);
        ObjectSetText("lbS1", sS1 + "S1 = " + DoubleToStr(xS1, Digits), FontSize, Font, LevelS1);
        ObjectSetText("lbS2", sS2 + "S2 = " + DoubleToStr(xS2, Digits), FontSize, Font, LevelS2);
        ObjectSetText("lbS3", sS3 + "S3 = " + DoubleToStr(xS3, Digits), FontSize, Font, LevelS3);
    } else
    {
        ObjectSetText("pInfo", pivInfo, 8, "Arial", Black);
        ObjectSetText("lbR3", "R3 = " + DoubleToStr(xR3, Digits) + sR3, FontSize, Font, LevelR3);
        ObjectSetText("lbR2", "R2 = " + DoubleToStr(xR2, Digits) + sR2, FontSize, Font, LevelR2);
        ObjectSetText("lbR1", "R1 = " + DoubleToStr(xR1, Digits) + sR1, FontSize, Font, LevelR1);
        ObjectSetText("lbPP", "PP = " + DoubleToStr(xPP, Digits) + sPP, FontSize, Font, LevelPP);
        ObjectSetText("lbS1", "S1 = " + DoubleToStr(xS1, Digits) + sS1, FontSize, Font, LevelS1);
        ObjectSetText("lbS2", "S2 = " + DoubleToStr(xS2, Digits) + sS2, FontSize, Font, LevelS2);
        ObjectSetText("lbS3", "S3 = " + DoubleToStr(xS3, Digits) + sS3, FontSize, Font, LevelS3);
    }
}
//+------------------------------------------------------------------+

// clang-format off
void Notifications(double _price)
{
  if (!notifications) return;
  
	string text = "PRICE TOUCHED PIVOT PRICE VALUE: "+(string)NormalizeDouble(_price, _Digits);
  text += "in: "+ _Symbol;

	if(TimeCurrent() >= timeNextAlert)
	{
	  if (desktop_notifications) Alert(text);
	  if (push_notifications)    SendNotification(text);
	  if (email_notifications)   SendMail("MetaTrader Notification", text);
	
		timeNextAlert = TimeCurrent() + hoursBetweenAlerts *60*60;	
	}
}

void checkPricesForAlerts()
{

	for (int i = 0; i < ArraySize(prices); i++) 
	{	
		if(Ask >= prices[i] && Bid < prices[i])
		{
			Notifications(prices[i]);
		}
	}
	
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