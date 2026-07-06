//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=64044&start=10

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC   | 
// |                                                                         http://fxcodebase.com   |
// |                                                               PayPal: https://goo.gl/9Rj74e     |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by: Mario Jemic     |                    
// |                                                                     mario.jemic@gmail.com       |
// |                                                                 https://mario-jemic.com/        | 
// |                                                             Patreon: http://tiny.cc/1ybwxz      |   
// |                                                      Buy Me a Coffee: http://tiny.cc/bj7vxz     |  
// +-----------------+----------------------+---------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                                |
// +-----------------+----------------------+---------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                     | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2           | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// +-----------------+----------------------+---------------------------------------------------------+


#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

 
#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 1
#property indicator_height 100
#property indicator_buffers 0
#property indicator_plots   0
int chart = 1;


input int    Offset_Hours = 0;
input bool   Show_Day_Date = true;
input string Comment0 = "-- Days of Week --";
input string Monday_Name = "Monday";
input string Tuesday_Name = "Tuesday";
input string Wednesday_Name = "Wednesday";
input string Thursday_Name = "Thursday";
input string Friday_Name = "Friday";
input string Saturday_Name = "Saturday";
input string Sunday_Name = "Sunday";
input string Comment1 = "-- Months of Year --";
input string January_Name = "January";
input string February_Name = "February";
input string March_Name = "March";
input string April_Name = "April";
input string May_Name = "May";
input string June_Name = "June";
input string July_Name = "July";
input string August_Name = "August";
input string September_Name = "September";
input string October_Name = "October";
input string November_Name = "November";
input string December_Name = "December";
input string Comment2 = "-- Styling --";

input bool Days_On = true; // Name days ?
input color  Days_Label_Clr = clrYellow;
input color  Days_Sep_Color = clrLime;
input ENUM_LINE_STYLE    Days_Sep_Style = STYLE_DOT;
input int    Days_Sep_Width = 0;
input bool Months_On = true; // Draw months ?
input color  Months_Label_Clr = clrRed;
input color  Months_Sep_Color = clrRed;
input ENUM_LINE_STYLE    Months_Sep_Style = STYLE_SOLID;
input int    Months_Sep_Width = 2;

string IndicatorName;
string IndicatorObjPrefix;

string GenerateIndicatorName(const string target)
{
    string name = target;
    int try = 2;
    while(ChartWindowFind(ChartID(), name) != -1)
    {
        name = target + " #" + IntegerToString(try++);
    }
    return name;
}

//+------------------------------------------------------------------+
int init()
{
    IndicatorName = GenerateIndicatorName("#Day_Of_Week_Labels");
    IndicatorObjPrefix = "__" + IndicatorName + "__";
    IndicatorSetString(INDICATOR_SHORTNAME, IndicatorName);

    IndicatorSetDouble(INDICATOR_MINIMUM, 0);
    IndicatorSetDouble(INDICATOR_MAXIMUM, 1);
    return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
int deinit()
{
    ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
    return(0);
}

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
    int limit = rates_total - prev_calculated - 1;
    if(prev_calculated == 0) limit = rates_total - 1;

    string Days[7];
    Days[0] = Sunday_Name;
    Days[1] = Monday_Name;
    Days[2] = Tuesday_Name;
    Days[3] = Wednesday_Name;
    Days[4] = Thursday_Name;
    Days[5] = Friday_Name;
    Days[6] = Saturday_Name;

    string Months[12];
    Months[0] = January_Name;
    Months[1] = February_Name;
    Months[2] = March_Name;
    Months[3] = April_Name;
    Months[4] = May_Name;
    Months[5] = June_Name;
    Months[6] = July_Name;
    Months[7] = August_Name;
    Months[8] = September_Name;
    Months[9] = October_Name;
    Months[10] = November_Name;
    Months[11] = December_Name;

    double pipSize = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
    if(SymbolInfoInteger("EURUSD", SYMBOL_DIGITS) == 5) pipSize = pipSize * 10;

    string Day_Date;
    ArraySetAsSeries(time, true);
    ArraySetAsSeries(high, true);

    for(int i = limit; i >= 0; i--){
        MqlDateTime dt;
        TimeToStruct(time[i], dt);
        
        if(dt.hour == Offset_Hours && dt.min == 0){
            if(Show_Day_Date) Day_Date = IntegerToString(dt.day); else Day_Date = "";

             Separator("S" + IntegerToString(i), time[i], Days_Sep_Color, Days_Sep_Width, Days_Sep_Style);

             if(Days_On){
                ObjectMakeText("Day" + IntegerToString(i), time[i] + (86400 / 2), 0.66, 
                              Days[dt.day_of_week] + " " + Day_Date, Days_Label_Clr, "Arial", 10);
            }

            if(Months_On && i < rates_total - 1){
                datetime monthTime1 = iTime(_Symbol, PERIOD_MN1, iBarShift(_Symbol, PERIOD_MN1, time[i], false));
                datetime monthTime2 = iTime(_Symbol, PERIOD_MN1, iBarShift(_Symbol, PERIOD_MN1, time[i + 1], false));
                
                if(monthTime1 != monthTime2){
                     Separator("SM" + IntegerToString(i), time[i], Months_Sep_Color, Months_Sep_Width, Months_Sep_Style);
                    ObjectMakeText("Month" + IntegerToString(i), time[i] + (86400 / 2), 0.33, 
                                  Months[dt.mon - 1] + " " + IntegerToString(dt.year), Months_Label_Clr, "Arial", 14);
                }
            }
        }
    }

    return(rates_total);
}
//+------------------------------------------------------------------+

void Separator(string Nombre, datetime tiempo1, color sesscolor, int ancho, int style)
{
    ObjectDelete(ChartID(), IndicatorObjPrefix + Nombre);
    ObjectCreate(ChartID(), IndicatorObjPrefix + Nombre, OBJ_VLINE, chart, tiempo1, 0);
    ObjectSetInteger(ChartID(), IndicatorObjPrefix + Nombre, OBJPROP_COLOR, sesscolor);
    ObjectSetInteger(ChartID(), IndicatorObjPrefix + Nombre, OBJPROP_STYLE, style);
    ObjectSetInteger(ChartID(), IndicatorObjPrefix + Nombre, OBJPROP_WIDTH, ancho);
    ObjectSetInteger(ChartID(), IndicatorObjPrefix + Nombre, OBJPROP_BACK, true);
}

void ObjectMakeText(string nm, datetime tiempo1, double precio1, string Texto, color TColor, string Font = "Arial", int FSize = 7)
{
    string fullName = IndicatorObjPrefix + nm;
    ObjectDelete(ChartID(), fullName);
    int window = ChartWindowFind(ChartID(), IndicatorName);
    ObjectCreate(ChartID(), fullName, OBJ_TEXT, window, tiempo1, precio1);
    ObjectSetString(ChartID(), fullName, OBJPROP_TEXT, Texto);
    ObjectSetString(ChartID(), fullName, OBJPROP_FONT, Font);
    ObjectSetInteger(ChartID(), fullName, OBJPROP_FONTSIZE, FSize);
    ObjectSetInteger(ChartID(), fullName, OBJPROP_COLOR, TColor);
    ObjectSetInteger(ChartID(), fullName, OBJPROP_TIME, tiempo1);
    ObjectSetDouble(ChartID(), fullName, OBJPROP_PRICE, precio1);
    ObjectSetInteger(ChartID(), fullName, OBJPROP_ANCHOR, ANCHOR_CENTER);
}


void OnChartEvent(const int id, const long& lparam, const double& dparam, const string& sparam)
{
    if(id == CHARTEVENT_CHART_CHANGE)
    {
        setTextsPosition();
    }
}

void setTextsPosition()
{
    for(int i = 0; i < ObjectsTotal(ChartID(), -1, OBJ_TEXT); i++)
    {
        string n = ObjectName(ChartID(), i, -1, OBJ_TEXT);
        if(ObjectGetInteger(ChartID(), n, OBJPROP_TYPE) != OBJ_TEXT) continue;
        
    }
}
 
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=64044&start=10

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC   | 
// |                                                                         http://fxcodebase.com   |
// |                                                               PayPal: https://goo.gl/9Rj74e     |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by: Mario Jemic     |                    
// |                                                                     mario.jemic@gmail.com       |
// |                                                                 https://mario-jemic.com/        | 
// |                                                             Patreon: http://tiny.cc/1ybwxz      |   
// |                                                      Buy Me a Coffee: http://tiny.cc/bj7vxz     |  
// +-----------------+----------------------+---------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                                |
// +-----------------+----------------------+---------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                     | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2           | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// +-----------------+----------------------+---------------------------------------------------------+