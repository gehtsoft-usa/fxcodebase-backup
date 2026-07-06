//Available @ https://fxcodebase.com/code/viewtopic.php?f=38&p=150943

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
 
#property copyright "Copyright (c) 2016, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

// #property indicator_chart_window
#property indicator_separate_window
int chart = 1;


extern int    Offset_Hours = 0;
extern bool   Show_Day_Date = true;
extern string Comment0 = "-- Days of Week --";
extern string Monday_Name = "Monday";
extern string Tuesday_Name = "Tuesday";
extern string Wednesday_Name = "Wednesday";
extern string Thursday_Name = "Thursday";
extern string Friday_Name = "Friday";
extern string Saturday_Name = "Saturday";
extern string Sunday_Name = "Sunday";
extern string Comment1 = "-- Months of Year --";
extern string January_Name = "January";
extern string February_Name = "February";
extern string March_Name = "March";
extern string April_Name = "April";
extern string May_Name = "May";
extern string June_Name = "June";
extern string July_Name = "July";
extern string August_Name = "August";
extern string September_Name = "September";
extern string October_Name = "October";
extern string November_Name = "November";
extern string December_Name = "December";
extern string Comment2 = "-- Styling --";

extern bool Days_On = true; // Name days ?
extern color  Days_Label_Clr = clrYellow;
extern color  Days_Sep_Color = clrLime;
extern int    Days_Sep_Style = STYLE_DOT;
extern int    Days_Sep_Width = 0;
extern bool Months_On = true; // Draw months ?
extern color  Months_Label_Clr = clrRed;
extern color  Months_Sep_Color = clrRed;
extern int    Months_Sep_Style = STYLE_SOLID;
extern int    Months_Sep_Width = 2;

string IndicatorName;
string IndicatorObjPrefix;

string GenerateIndicatorName(const string target)
{
    string name = target;
    int try = 2;
    while(WindowFind(name) != -1)
    {
        name = target + " #" + IntegerToString(try++);
    }
    return name;
}

//+------------------------------------------------------------------+
int init()
{
    IndicatorName = GenerateIndicatorName("#Day_Of_Week_Lables");
    IndicatorObjPrefix = "__" + IndicatorName + "__";
    IndicatorShortName(IndicatorName);

    IndicatorSetDouble(INDICATOR_MINIMUM, 0);
    IndicatorSetDouble(INDICATOR_MAXIMUM, 1);
    return(0);
}

//+------------------------------------------------------------------+
int deinit()
{
    ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
    return(0);
}

//+------------------------------------------------------------------+
int start()
{

    int i;
    int counted_bars = IndicatorCounted();
    int limit = Bars - counted_bars - 1;

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

    double pipSize = MarketInfo(Symbol(), MODE_POINT);
    if(MarketInfo("EURUSD", MODE_DIGITS) == 5) pipSize = pipSize * 10; // I take the EURUSD as an example to check if it is 5 digits instead of 4, if so, I multiply it by 10

    string Day_Date;

    for(i = limit; i >= 0; i--){
        if(TimeToStr(Time[i], TIME_MINUTES) == "0" + Offset_Hours + ":00"){

            if(Show_Day_Date) Day_Date = TimeDay(Time[i]); else Day_Date = "";

            // Day Separator
            Separator("S" + i, Time[i], Days_Sep_Color, Days_Sep_Width, Days_Sep_Style);

            // Day Label
            if(Days_On)
                ObjectMakeText("Day" + i, Time[i] + (86400 / 2), iHigh(NULL, PERIOD_D1, iBarShift(NULL, PERIOD_D1, Time[i])) + (20 * pipSize), Days[TimeDayOfWeek(Time[i])] + " " + Day_Date, Days_Label_Clr, "Arial", 10);


            if(Months_On)
                if(iTime(NULL, PERIOD_MN1, iBarShift(NULL, PERIOD_MN1, Time[i])) != iTime(NULL, PERIOD_MN1, iBarShift(NULL, PERIOD_MN1, Time[i + 1])))
                {
                    // Month Separator
                    Separator("SM" + i, Time[i], Months_Sep_Color, Months_Sep_Width, Months_Sep_Style);
                    // Month Label
                    ObjectMakeText("Month" + i, Time[i] + (86400 / 2), iHigh(NULL, PERIOD_D1, iBarShift(NULL, PERIOD_D1, Time[i])) + (30 * pipSize), Months[TimeMonth(Time[i]) - 1], Months_Label_Clr, "Arial", 14);
                }
        }
    }

    return(0);
}
//+------------------------------------------------------------------+

void Separator(string Nombre, datetime tiempo1, color sesscolor, int ancho, int style)
{
    
    ObjectDelete(IndicatorObjPrefix + Nombre);
    ObjectCreate(IndicatorObjPrefix + Nombre, OBJ_VLINE, 0, tiempo1, WindowPriceMax());
    ObjectSet(IndicatorObjPrefix + Nombre, OBJPROP_COLOR, sesscolor);
    ObjectSet(IndicatorObjPrefix + Nombre, OBJPROP_STYLE, style);
    ObjectSet(IndicatorObjPrefix + Nombre, OBJPROP_WIDTH, ancho);
    ObjectSet(IndicatorObjPrefix + Nombre, OBJPROP_BACK, True);
}

void ObjectMakeText(string nm, datetime tiempo1, double precio1, string Texto, color TColor, string Font = "Arial", int FSize = 7)
{
    ObjectDelete(IndicatorObjPrefix + nm);
    ObjectCreate(IndicatorObjPrefix + nm, OBJ_TEXT, chart, tiempo1, precio1);
    ObjectSetText(IndicatorObjPrefix + nm, Texto, FSize, Font, TColor);
    ObjectSet(IndicatorObjPrefix + nm, OBJPROP_TIME1, tiempo1);

    setPosition(IndicatorObjPrefix + nm);
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
    for(int i = 0;i < ObjectsTotal(0, chart, OBJ_TEXT);i++)
    {
        string n = ObjectName(i);
        if(ObjectType(n) != OBJ_TEXT)continue;
        setPosition(n);
    }
}

void setPosition(string name)
{
    // double min = ChartGetDouble(chart, CHART_PRICE_MIN, 0);
    // double max = ChartGetDouble(chart, CHART_PRICE_MAX, 0);

    // ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LOWER);
    ObjectSetInteger(chart, name, OBJPROP_ANCHOR, ANCHOR_UPPER);
    // ObjectSet(name, OBJPROP_PRICE1, min);
    // ObjectSet(name, OBJPROP_PRICE1, max);
    ObjectSet(name, OBJPROP_PRICE1, 1);

    if(StringFind(name, "Month", 0) > 0)
    {
        // ObjectSetInteger(chart, name, OBJPROP_ANCHOR, ANCHOR_UPPER);
        ObjectSetInteger(chart, name, OBJPROP_ANCHOR, ANCHOR_LOWER);
        // ObjectSet(name, OBJPROP_PRICE1, max);
        ObjectSet(name, OBJPROP_PRICE1, 0.5);
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