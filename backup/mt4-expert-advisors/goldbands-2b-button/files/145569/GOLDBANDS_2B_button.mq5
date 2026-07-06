// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=72047

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
#property indicator_buffers 10
#property indicator_plots 10

#property indicator_label1  "GBbgd"
#property indicator_color1 C'100,150,180'
#property indicator_type1   DRAW_LINE
#property indicator_width1 12

#property indicator_label2  "GBupband"
#property indicator_color2 clrGold
#property indicator_type2   DRAW_LINE
#property indicator_width2 3

#property indicator_label3  "GBdnband"
#property indicator_color3 clrGold
#property indicator_type3   DRAW_LINE
#property indicator_width3 3

#property indicator_label4  "GBupTrend"
#property indicator_color4 clrBlue
#property indicator_type4   DRAW_LINE
#property indicator_width4 3

#property indicator_label5  "GBdnTrend"
#property indicator_color5 clrRed
#property indicator_type5   DRAW_LINE
#property indicator_width5 3

input int inpGBper = 10;                  //GBper
input int GBshuffle = 7;
input double GBdev = 3.618;
input bool AlertsOn = false;
input bool AlertsOnCurrent = true;
input bool AlertsMessage = false;
input bool AlertsSound = true;
input bool AlertsEmail = false;

input string             button_note1          = "------------------------------";
input ENUM_BASE_CORNER   btn_corner            = CORNER_LEFT_LOWER; // chart btn_corner for anchoring
input string             btn_text              = "Gold";
input string             btn_Font              = "Impact";
input int                btn_FontSize          = 10;                             //btn__font size
input color              btn_text_color        = clrWhite;
input color              btn_background_color  = clrDarkRed;
input color              btn_border_color      = clrBlack;
input int                button_x              = 240;                                     //btn__x
input int                button_y              = 20;                                     //btn__y
input int                btn_Width             = 60;                                 //btn__width
input int                btn_Height            = 20;                                //btn__height
input string             button_note2          = "------------------------------";

bool                      show_data             = true;

string IndicatorName, IndicatorObjPrefix;
int shift1 = 0;
int shift2 = 0;
double GBsignal[];
double GBshift[], GBbgd[];
double GBupTrend[];
double GBdnTrend[];
double GBupband[];
double GBdnband[];
double ExtBuffer01[];
int    GBtimeframe01;
string Str01;
string NothingStr = "nothing";
datetime GBTime01;
string buttonId;
bool recalc = true;
int GBper;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
   {
    handleButtonClicks();
   }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit(void)
   {
    IndicatorName = GenerateIndicatorName(btn_text);
    IndicatorObjPrefix = "__" + IndicatorName + "__";
    IndicatorSetString(INDICATOR_SHORTNAME, IndicatorName);
    IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
    double val;
    if(GlobalVariableGet(IndicatorName + "_visibility", val))
        show_data = val != 0;
    ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, 1);
    buttonId = IndicatorObjPrefix + "CloseButton";
    createButton(buttonId, btn_text, btn_Width, btn_Height, btn_Font, btn_FontSize, btn_background_color, btn_border_color, btn_text_color);
    ObjectSetInteger(0, buttonId, OBJPROP_YDISTANCE, button_y);
    ObjectSetInteger(0, buttonId, OBJPROP_XDISTANCE, button_x);
//
    if(GBper < 2)
        GBper = 12;
    int w = GBper - 1;
    string GoldBands01 = "GoldBands(";
    IndicatorSetString(INDICATOR_SHORTNAME, GoldBands01 + (string)GBper + ")");
//
    SetIndexBuffer(0, GBbgd, INDICATOR_DATA);
    PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, w);
    PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_LINE);
    PlotIndexSetInteger(0, PLOT_SHIFT, shift2);
    SetIndexBuffer(1, GBupband, INDICATOR_DATA);
    PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, w);
    PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_LINE);
    PlotIndexSetInteger(1, PLOT_SHIFT, shift2);
    SetIndexBuffer(2, GBdnband, INDICATOR_DATA);
    PlotIndexSetInteger(2, PLOT_DRAW_BEGIN, w);
    PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_LINE);
    PlotIndexSetInteger(2, PLOT_SHIFT, shift2);
    SetIndexBuffer(3, GBupTrend, INDICATOR_DATA);
    PlotIndexSetInteger(3, PLOT_DRAW_BEGIN, w);
    PlotIndexSetInteger(3, PLOT_DRAW_TYPE, DRAW_LINE);
    PlotIndexSetInteger(3, PLOT_SHIFT, shift2);
    SetIndexBuffer(4, GBdnTrend, INDICATOR_DATA);
    PlotIndexSetInteger(4, PLOT_DRAW_BEGIN, w);
    PlotIndexSetInteger(4, PLOT_DRAW_TYPE, DRAW_LINE);
    PlotIndexSetInteger(4, PLOT_SHIFT, shift2);
    SetIndexBuffer(5, GBsignal, INDICATOR_CALCULATIONS);
    PlotIndexSetInteger(5, PLOT_SHOW_DATA, false);
    PlotIndexSetInteger(5, PLOT_DRAW_BEGIN, w);
    PlotIndexSetInteger(5, PLOT_SHIFT, shift2);
    SetIndexBuffer(6, GBshift, INDICATOR_CALCULATIONS);
    PlotIndexSetInteger(6, PLOT_SHOW_DATA, false);
    PlotIndexSetInteger(6, PLOT_DRAW_BEGIN, w);
    PlotIndexSetInteger(6, PLOT_SHIFT, shift2);
    SetIndexBuffer(7, ExtBuffer01, INDICATOR_CALCULATIONS);
    ArraySetAsSeries(GBbgd, true);
    ArraySetAsSeries(GBupband, true);
    ArraySetAsSeries(GBdnband, true);
    ArraySetAsSeries(GBupTrend, true);
    ArraySetAsSeries(GBdnTrend, true);
    ArraySetAsSeries(GBsignal, true);
    ArraySetAsSeries(GBshift, true);
    ArraySetAsSeries(ExtBuffer01, true);
    switch(GBtimeframe01)
       {
        case PERIOD_M1:
            Str01 = " M1";
            break;
        case PERIOD_M5:
            Str01 = " M5";
            break;
        case PERIOD_M15:
            Str01 = " M15";
            break;
        case PERIOD_M30:
            Str01 = " M30";
            break;
        case PERIOD_H1:
            Str01 = " H1";
            break;
        case PERIOD_H4:
            Str01 = " H4";
            break;
        case PERIOD_D1:
            Str01 = " D1";
            break;
        case PERIOD_W1:
            Str01 = " W1";
            break;
        case PERIOD_MN1:
            Str01 = " MN1";
            break;
        default:
            GBtimeframe01 = Period();
            return (0);
       }
    return(INIT_SUCCEEDED);
   }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
   {
    ObjectsDeleteAll(0, IndicatorObjPrefix, -1, -1);
    ObjectsDeleteAll(0, 0, OBJ_LABEL);
   }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
   {
    start();
    return(rates_total);
   }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void start()
   {
    int i;
    int bars = iBars(_Symbol, _Period);
    handleButtonClicks();
    recalc = false;
    int w;
    double total, signal, sum2, sum1;
    GoldBands();
    sma();
    if(bars <= GBshuffle * 2)
       {
        return;
       }
    int countedbars;
    bool newbar = IsNewBar();
    if(newbar)
        countedbars = 12;
    else
        countedbars = bars - 12;
    for(i = 1; i <= GBshuffle; i++)
       {
        GBshift[bars - i] = EMPTY_VALUE;
        GBupband[bars - i] = EMPTY_VALUE;
        GBdnband[bars - i] = EMPTY_VALUE;
        GBupTrend[bars - i] = EMPTY_VALUE;
        GBdnTrend[bars - i] = EMPTY_VALUE;
       }
    int x = bars - countedbars;
    if(countedbars > 0)
        x++;
    i = bars - GBshuffle + 1;
    if(countedbars > GBshuffle - 1)
        i = bars - countedbars - 1;
    while(i >= 0)
       {
        signal = 0.0;
        w = i + GBshuffle - 1;
        sum2 = GBshift[i];
        while(w >= i)
           {
            sum1 = GBsignal[w] - sum2;
            signal += sum1 * sum1;
            w--;
           }
        total = GBdev * MathSqrt(signal / GBshuffle);
        GBupband[i] = sum2 + total;
        GBdnband[i] = sum2 - total;
        i--;
       }
    i = bars - GBshuffle + 1;
    if(countedbars > GBshuffle - 1)
        i = bars - countedbars - 1;
    while(i >= 0)
       {
        if(GBshift[i] < GBsignal[i])
           {
            GBupTrend[i] = GBshift[i];
            GBdnTrend[i] = EMPTY_VALUE;
            if(GBupTrend[i + 1] == EMPTY_VALUE)
                GBupTrend[i + 1] = GBshift[i + 1];
           }
        else
           {
            if(GBshift[i] > GBsignal[i])
               {
                GBdnTrend[i] = GBshift[i];
                GBupTrend[i] = EMPTY_VALUE;
                if(GBdnTrend[i + 1] == EMPTY_VALUE)
                    GBdnTrend[i + 1] = GBshift[i + 1];
               }
           }
        GBbgd[i] = GBshift[i];
        i--;
        manageAlerts();
       }
    int banzai;
    if(show_data)
       {
        for(banzai = 0; banzai < 5; banzai++)
            PlotIndexSetInteger(banzai, PLOT_DRAW_TYPE, DRAW_LINE);
       }
    else
       {
        for(banzai = 0; banzai < 5; banzai++)
            PlotIndexSetInteger(banzai, PLOT_DRAW_TYPE, DRAW_NONE);
       }
   }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GenerateIndicatorName(const string target)
   {
    string name = target;
    int try
            = 2;
    while(ChartWindowFind(0, name) != -1)
       {
        name = target + " #" + IntegerToString(try
                                                   ++);
       }
    return name;
   }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void handleButtonClicks()
   {
    if(ObjectGetInteger(0, buttonId, OBJPROP_STATE))
       {
        ObjectSetInteger(0, buttonId, OBJPROP_STATE, false);
        show_data = !show_data;
        GlobalVariableSet(IndicatorName + "_visibility", show_data ? 1.0 : 0.0);
        recalc = true;
        start();
        ChartRedraw();
       }
   }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void GoldBands()
   {
    double close;
    double sum = 0.0;
    double Band2 = 0.0;
    int bars = 0;
    int limit3 = iBars(_Symbol, _Period) - shift1 - 1;
    if(limit3 < GBper)
        limit3 = GBper;
    int j = 1;
    while(j <= GBper)
       {
        close = iClose(_Symbol, _Period, limit3);
        sum += close * j;
        Band2 += close;
        bars += j;
        j++;
        limit3--;
       }
    limit3++;
    j = limit3 + GBper;
    while(limit3 >= 0)
       {
        GBsignal[limit3] = sum / bars;
        if(limit3 == 0)
            break;
        limit3--;
        j--;
        close = iClose(_Symbol, _Period, limit3);
        sum = sum - Band2 + close * GBper;
        Band2 -= iClose(_Symbol, _Period, j);
        Band2 += close;
       }
    if(shift1 < 1)
        for(j = 1; j < GBper; j++)
            GBsignal[iBars(_Symbol, _Period) - j] = 0;
   }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void sma()
   {
    double sum = 0;
    int limit2 = iBars(_Symbol, _Period) - shift1 - 1;
    if(limit2 < GBshuffle)
        limit2 = GBshuffle;
    int k = 1;
    while(k < GBshuffle)
       {
        sum += GBsignal[limit2];
        k++;
        limit2--;
       }
    while(limit2 >= 0)
       {
        sum += GBsignal[limit2];
        GBshift[limit2] = sum / GBshuffle;
        sum -= GBsignal[limit2 + GBshuffle - 1];
        limit2--;
       }
    if(shift1 < 1)
        for(k = 1; k < GBshuffle; k++)
            GBshift[iBars(_Symbol, _Period) - k] = 0;
   }
//+------------------------------------------------------------------+
void manageAlerts()
   {
    int w;
    if(AlertsOn)
       {
        if(AlertsOnCurrent)
            w = 0;
        else
            w = 1;
        w = iBarShift(NULL, 0, iTime(NULL, 0, w));
        if(ExtBuffer01[w] != ExtBuffer01[w + 1])
           {
            if(ExtBuffer01[w] == 1.0)
                doAlert(w, "up");
            if(ExtBuffer01[w] == -1.0)
                doAlert(w, "down");
           }
       }
   }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void doAlert(int Yoda, string aStr02)
   {
    string zard777;
    if(NothingStr != aStr02 || GBTime01 != iTime(_Symbol, _Period, Yoda))
       {
        NothingStr = aStr02;
        GBTime01 = iTime(_Symbol, _Period, Yoda);
        zard777 = Symbol() + " " + Str01 + " GoldBands : direction changed to " + aStr02;
        if(AlertsMessage)
            Alert(zard777);
        if(AlertsEmail)
           {
            SendMail(zard777, zard777
                     + "\nLocal time " + TimeToString(TimeLocal(), TIME_SECONDS) + ""
                     + "\nBroker time " + TimeToString(TimeCurrent(), TIME_SECONDS));
           }
        if(AlertsSound)
            PlaySound("good-bad-ugly.wav");
       }
   }
//+------------------------------------------------------------------+
void createButton(string buttonID, string buttonText, int width, int height, string font, int fontSize, color bgColor, color borderColor, color txtColor)
   {
    ObjectDelete(0, buttonID);
    ObjectCreate(0, buttonID, OBJ_BUTTON, 0, 0, 0);
    ObjectSetInteger(0, buttonID, OBJPROP_COLOR, txtColor);
    ObjectSetInteger(0, buttonID, OBJPROP_BGCOLOR, bgColor);
    ObjectSetInteger(0, buttonID, OBJPROP_BORDER_COLOR, borderColor);
    ObjectSetInteger(0, buttonID, OBJPROP_BORDER_TYPE, BORDER_RAISED);
    ObjectSetInteger(0, buttonID, OBJPROP_XSIZE, width);
    ObjectSetInteger(0, buttonID, OBJPROP_YSIZE, height);
    ObjectSetString(0, buttonID, OBJPROP_FONT, font);
    ObjectSetString(0, buttonID, OBJPROP_TEXT, buttonText);
    ObjectSetInteger(0, buttonID, OBJPROP_FONTSIZE, fontSize);
    ObjectSetInteger(0, buttonID, OBJPROP_SELECTABLE, 0);
    ObjectSetInteger(0, buttonID, OBJPROP_CORNER, btn_corner);
    ObjectSetInteger(0, buttonID, OBJPROP_HIDDEN, 1);
    ObjectSetInteger(0, buttonID, OBJPROP_XDISTANCE, 9999);
    ObjectSetInteger(0, buttonID, OBJPROP_YDISTANCE, 9999);
   }
//+------------------------------------------------------------------+
bool IsNewBar()
   {
    static datetime lastbar;
    datetime curbar = (datetime)SeriesInfoInteger(_Symbol, _Period, SERIES_LASTBAR_DATE);
    if(lastbar != curbar)
       {
        lastbar = curbar;
        return true;
       }
    return false;
   }
//+------------------------------------------------------------------+
