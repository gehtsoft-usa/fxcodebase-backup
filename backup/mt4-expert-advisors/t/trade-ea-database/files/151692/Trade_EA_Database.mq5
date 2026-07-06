
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=73952

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

//+--------------------------------------------------------------------------+
//|                         Global variables                                 |
//+--------------------------------------------------------------------------+
// #property indicator_chart_window
// #define Indicator_Name "!  - i-Trade-EA-Data-Base"
// #define Indicator_Version "v1.00"

// #import "stdlib.ex4"
    // string ErrorDescription(int error_code); // Not sure of this
// #import

//+--------------------------------------------------------------------------+
//|                                 Settings                                 |
//+--------------------------------------------------------------------------+

input string        Copyright = "© 2015, !  - i-Trade-EA-Data-Base";
input string        Version = 1;
input string        Options = "<<<---------- Settings: ----------->>>";
input string        OrderHistoryFilePath = "Analyze_My_Trades";
input string        Comment_On_Chart = "Order History Logger";
input int           DaysBack = 7; // Days Back History:
input bool          Show_Rollover_Deposit = false;

//+--------------------------------------------------------------------------+
//|                                 Variables                                |
//+--------------------------------------------------------------------------+

int Value01 = 0;
int Value02 = 0;
int Value03 = 0;
double Value04 = 0.0;
double Value05 = 0.0;
int Value06 = 0;
int Value07 = 0;
datetime TheTime = 0;
string AccountNature;
string Commentnature;
string Which_day;
datetime NetTime;// Added to calculate Trade duration
int d, h, m, s;
string TimeStr = "";
string TimeStrSec = "";
string HourStr, MinStr, SecStr;

ulong tk;

//+--------------------------------------------------------------------------+
//| expert initialization function                                           |
//+--------------------------------------------------------------------------+
// int init()
int OnInit()
{
    Comment(Comment_On_Chart, " started.");
    LogOrderHistory(OrderHistoryFilePath);

    // return(0);
    return (INIT_SUCCEEDED);
}

//+--------------------------------------------------------------------------+
//| expert deinitialization function                                         |
//+--------------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    Comment("");
}

//+--------------------------------------------------------------------------+
//| expert start function                                                    |
//+--------------------------------------------------------------------------+
void OnTick() { ;}

//+--------------------------------------------------------------------------+
//| expert                                                                   |
//+--------------------------------------------------------------------------+

string GetCustomData()
{
    return ("");
}

//+--------------------------------------------------------------------------+
string GetExpertNameByMagicNumber(int Check)
{
    string MagicNB = "N/A";
    switch(Check) {
        case 1:
            MagicNB = "EA Name";
            break;
        case 2:
            MagicNB = "EA Name";
    }
    return (MagicNB);
}

//+--------------------------------------------------------------------------+
void LogOrderHistory(string CSVFileName)
{
    int _File;
    int i;
    string OrderDetails;
    string Headers; //Added for Headers
    int TotalHistory;
    if(BarCompleted() == 1) {
        _File = 0;
        i = 0;
        OrderDetails = "";
        TotalHistory = 0;
        Print("Saving Order History");

        HistorySelect(TimeCurrent()-(DaysBack*24*60*60), TimeCurrent());

        Print("HistoryOrdersTotal(): ", HistoryOrdersTotal());
        Print("HistoryDealsTotal(): ", HistoryDealsTotal());

        TotalHistory = HistoryOrdersTotal();
        // TotalHistory = OrdersHistoryTotal();

        CheckError(GetLastError(), __LINE__);
        
        _File = FileOpen("Analyze_ME/" + CSVFileName + "_" + AccountNumber() + ".csv", FILE_CSV | FILE_WRITE, ",");

        if(_File > 0)
        {
            CheckError(GetLastError(),__LINE__);

            Headers = GetHeaders(); //Added to get Headers                 
            FileWrite(_File, Headers); //Added to get Headers  


            for(i = 0; i < TotalHistory; i++)
            {
                tk = HistoryOrderGetTicket(i);

                // if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY) == true)
                if(tk > 0)
                {
                    if(OrderComment(tk) != "cancelled")
                    {
                        if(Show_Rollover_Deposit) // Added to allow option and avoid Rollover
                            if(GetOrderType(tk) != "Deposit") {
                                //if (GetOrderType() <= ORDER_TYPE_SELL_STOP) {               
                                OrderDetails = GetOrderDetails();
                                FileWrite(_File, OrderDetails);
                                FileFlush(_File);
                            }

                        if(!Show_Rollover_Deposit)
                            if(OrderType(tk) <= ORDER_TYPE_SELL_STOP) {
                                //if (GetOrderType() <= ORDER_TYPE_SELL_STOP) {               
                                OrderDetails = GetOrderDetails();
                                FileWrite(_File, OrderDetails);
                                FileFlush(_File);
                            }
                    }
                }
            }
        }
        FileClose(_File);
    }
}

//+--------------------------------------------------------------------------
string GetHeaders()
{
    string Headers = "Order_Ticket";
    
    StringAdd(Headers, ",Account_Number");
    StringAdd(Headers, ",Account_Company");
    StringAdd(Headers, ",Company_Name");
    StringAdd(Headers, ",Account_Name");
    StringAdd(Headers, ",Account_Currency");
    StringAdd(Headers, ",Client_Terminal_Name");
    StringAdd(Headers, ",IS_Demo");
    StringAdd(Headers, ",Server_Address");
    StringAdd(Headers, ",Magic_Number");
    StringAdd(Headers, ",Expert_Advisor");
    StringAdd(Headers, ",Comments");
    StringAdd(Headers, ",Order_Type");
    StringAdd(Headers, ",Order_Type_Buy");
    StringAdd(Headers, ",Order_Type_Sell");
    StringAdd(Headers, ",Order_Size");
    StringAdd(Headers, ",Order_Size_Buy");
    StringAdd(Headers, ",Order_Size_Sell");
    StringAdd(Headers, ",Order_Symbol");
    StringAdd(Headers, ",Spread");
    StringAdd(Headers, ",Date_Entry");
    StringAdd(Headers, ",Hour_entry");
    StringAdd(Headers, ",Price_Entry");
    StringAdd(Headers, ",Date_Exit");
    StringAdd(Headers, ",Hour_Exit");
    StringAdd(Headers, ",Price_Exit");
    StringAdd(Headers, ",Trade_Duration");
    StringAdd(Headers, ",Stop_Loss");
    StringAdd(Headers, ",Take_Profit");
    StringAdd(Headers, ",Commission");
    StringAdd(Headers, ",Swap");
    StringAdd(Headers, ",Number_of_Trades");
    StringAdd(Headers, ",NB_Plus");
    StringAdd(Headers, ",NB_Minus");
    StringAdd(Headers, ",Profit");
    StringAdd(Headers, ",Profit_Plus");
    StringAdd(Headers, ",Profit_Minus");
    StringAdd(Headers, ",Pips_Result");
    StringAdd(Headers, ",Pips_Plus");
    StringAdd(Headers, ",Pips_Minus");
    StringAdd(Headers, ",Export_Local_Date_Time");
    StringAdd(Headers, ",Export_Broke_Date_Time");
    StringAdd(Headers, ",Hour_Only");
    StringAdd(Headers, ",Day_of_Week");
    StringAdd(Headers, ",Week_Number");
    StringAdd(Headers, ",Day_Number");
    StringAdd(Headers, ",Month_Number");
    StringAdd(Headers, ",Year_Number");
    StringAdd(Headers, ",Split_Deposit_Rollover");

    Print(__FUNCTION__, " Headers: ", Headers);

    return (Headers);
}

//+--------------------------------------------------------------------------
string GetOrderDetails()
{

    if(IsDemo() == true) AccountNature = "Demo";
    else AccountNature = "Live";

    string Informations = "";
    SetOrderDurationValues();

  // Added to have trade duration
 //+--------------------------------------------------------------------------+
    if(OrderCloseTime(tk) != 0) NetTime = OrderCloseTime(tk) - OrderOpenTime(tk);
    else NetTime = TimeCurrent() - OrderOpenTime(tk); // or should it be: NetTime = 0;

    s = NetTime % 60;  // Although calculated, the s value is not reported (but see SecStr below).
    m = ((NetTime - s) / 60) % 60;
    h = ((NetTime - s - m * 60) / 3600) % 24;
    d = (NetTime - s - m * 60 - h * 3600) / 86400; //1day=86400sec

    if(h < 10) StringConcatenate(HourStr, "0", (string) h); else HourStr = h;
    if(m < 10) StringConcatenate(MinStr, "0",  (string) m); else MinStr = m;
    if(s < 10) StringConcatenate(SecStr, "0",  (string) s); else SecStr = s;

    //FYI, TimeStrSec is always used in output, w/o leading ", "
    if(d > 0) StringConcatenate(TimeStrSec, (string)d, "_", (string)HourStr, ":", (string)MinStr, ":", (string)SecStr);
    else StringConcatenate(TimeStrSec, (string)HourStr, ":", (string)MinStr, ":", (string)SecStr);

    if(d > 0) StringConcatenate(TimeStr, (string)d, "_", (string)HourStr, ":", (string)MinStr);
    else StringConcatenate(TimeStr, (string)HourStr, ":", (string)MinStr);

    // if (d>0) TimeStr = StringConcatenate(", ",d,"_",HourStr,":",MinStr);
    // else TimeStr = StringConcatenate(", ",HourStr,":",MinStr);
//+--------------------------------------------------------------------------+   

// NOTE: Info de la cuenta    
    // Informations = OrderTicket();
    Informations = (string) tk;
    StringAdd(Informations, ",");
    StringAdd(Informations, (string) AccountNumber());
    StringAdd(Informations, ",");
    // StringAdd(Informations, FormatCSVExportValue(AccountCompany()));
    StringAdd(Informations, AccountCompany());
    StringAdd(Informations, ",");
    StringAdd(Informations, TerminalCompany());
    StringAdd(Informations, ",");
    StringAdd(Informations, AccountName());
    StringAdd(Informations, ",");
    StringAdd(Informations, AccountCurrency());
    StringAdd(Informations, ",");
    StringAdd(Informations, TerminalName());
    StringAdd(Informations, ",");
    StringAdd(Informations, AccountNature);
    StringAdd(Informations, ",");
    StringAdd(Informations, AccountServer());
    StringAdd(Informations, ",");
    StringAdd(Informations, (string)OrderMagicNumber(tk));
    StringAdd(Informations, ",");
    StringAdd(Informations, GetExpertNameByMagicNumber(OrderMagicNumber(tk)));
    StringAdd(Informations, ",");
    StringAdd(Informations, OrderComment(tk));
    StringAdd(Informations, ",");

    //Type of order
    StringAdd(Informations, GetOrderType(tk));
    StringAdd(Informations, ",");

    string Type_of_Order = "";
    Type_of_Order = GetOrderType(tk);

    if((Type_of_Order == "Buy") || (Type_of_Order == "Buy Limit") || (Type_of_Order == "Buy Stop"))
        StringAdd(Informations, "1"); else StringAdd(Informations, "0");
    StringAdd(Informations, ",");

    if((Type_of_Order == "Sell") || (Type_of_Order == "Sell Limit") || (Type_of_Order == "Sell Stop"))
         StringAdd(Informations, "1"); else StringAdd(Informations, "0");
    StringAdd(Informations, ",");

    //Orders syze
    StringAdd(Informations, OrderLots(tk));
    StringAdd(Informations, ",");

    string buyLots = "0";
    string sellLots = "0";

    if((Type_of_Order == "Buy") || (Type_of_Order == "Buy Limit") || (Type_of_Order == "Buy Stop"))
        buyLots = (string) OrderLots(tk);

    StringAdd(Informations, buyLots);
    StringAdd(Informations, ",");

    if((Type_of_Order == "Sell") || (Type_of_Order == "Sell Limit") || (Type_of_Order == "Sell Stop"))
        sellLots = (string) OrderLots(tk);

    StringAdd(Informations, sellLots);
    StringAdd(Informations, ",");

    
    StringAdd(Informations, OrderSymbol(tk));
    StringAdd(Informations, ",");
    StringAdd(Informations, (string)GetSpread());
    StringAdd(Informations, ",");
    StringAdd(Informations, StringSubstr(TimeToString(OrderOpenTime(tk), TIME_DATE), 8, 2) + "-" + StringSubstr(TimeToString(OrderOpenTime(tk), TIME_DATE), 5, 2) + "-" + StringSubstr(TimeToString(OrderOpenTime(tk), TIME_DATE), 0, 4));
    StringAdd(Informations, ",");
    StringAdd(Informations, TimeToString(OrderOpenTime(tk), TIME_SECONDS));
    StringAdd(Informations, ",");
    StringAdd(Informations, DoubleToString(OrderOpenPrice(tk), 5));
    StringAdd(Informations, ",");
    StringAdd(Informations, StringSubstr(TimeToString(OrderCloseTime(tk), TIME_DATE), 8, 2) + "-" + StringSubstr(TimeToString(OrderCloseTime(tk), TIME_DATE), 5, 2) + "-" + StringSubstr(TimeToString(OrderCloseTime(tk), TIME_DATE), 0, 4));
    StringAdd(Informations, ",");
    StringAdd(Informations, TimeToString(OrderCloseTime(tk), TIME_SECONDS));
    StringAdd(Informations, ",");
    StringAdd(Informations, DoubleToString(OrderClosePrice(tk), 5));
    StringAdd(Informations, ",");
    StringAdd(Informations, TimeStr);//Trade Duration   
    StringAdd(Informations, ",");
    StringAdd(Informations, DoubleToString(OrderStopLoss(tk), 5));
    StringAdd(Informations, ",");
    StringAdd(Informations, DoubleToString(OrderTakeProfit(tk), 5));
    StringAdd(Informations, ",");
    StringAdd(Informations, DoubleToString(OrderCommission(tk), 5));
    StringAdd(Informations, ",");
    StringAdd(Informations, DoubleToString(OrderSwap(tk), 5));
    StringAdd(Informations, ",");
    StringAdd(Informations, "1");//Nimber of trade
    StringAdd(Informations, ",");
    
    if(GetProfitLossInPips() > 0) StringAdd(Informations, "1"); else StringAdd(Informations, "0");
    StringAdd(Informations, ",");

    if(GetProfitLossInPips() < 0) StringAdd(Informations, "1"); else StringAdd(Informations, "0");
    StringAdd(Informations, ",");

    StringAdd(Informations, DoubleToString(OrderProfit(tk), 2)); //Profit Result
    StringAdd(Informations, ",");

    if(OrderProfit(tk) > 0) StringAdd(Informations, DoubleToString(OrderProfit(tk), 2)); else StringAdd(Informations, "0");
    StringAdd(Informations, ",");

    if(OrderProfit(tk) < 0) StringAdd(Informations, DoubleToString(OrderProfit(tk), 2)); else StringAdd(Informations, "0");
    StringAdd(Informations, ",");

    StringAdd(Informations, GetProfitLossInPips());//Pips Result   
    StringAdd(Informations, ",");

    if(GetProfitLossInPips() > 0) StringAdd(Informations, GetProfitLossInPips()); else StringAdd(Informations, "0");
    StringAdd(Informations, ",");
    if(GetProfitLossInPips() < 0) StringAdd(Informations, GetProfitLossInPips()); else StringAdd(Informations, "0");
    StringAdd(Informations, ",");

    StringAdd(Informations, TimeToString(TimeCurrent()));
    StringAdd(Informations, ",");
    StringAdd(Informations, TimeToString(TimeLocal()));
    StringAdd(Informations, ",");
    StringAdd(Informations, StringSubstr(TimeToString(OrderOpenTime(tk), TIME_SECONDS), 0, 2));
    StringAdd(Informations, ":00");
    StringAdd(Informations, ",");

    Which_day = "";
    if(TimeDayOfWeek(OrderOpenTime(tk)) == 0) Which_day = "Sunday";
    if(TimeDayOfWeek(OrderOpenTime(tk)) == 1) Which_day = "Monday";
    if(TimeDayOfWeek(OrderOpenTime(tk)) == 2) Which_day = "Tuesday";
    if(TimeDayOfWeek(OrderOpenTime(tk)) == 3) Which_day = "Wednesday";
    if(TimeDayOfWeek(OrderOpenTime(tk)) == 4) Which_day = "Thursday";
    if(TimeDayOfWeek(OrderOpenTime(tk)) == 5) Which_day = "Friday";
    if(TimeDayOfWeek(OrderOpenTime(tk)) == 6) Which_day = "Saturday";

    StringAdd(Informations, Which_day);
    StringAdd(Informations, ",");
    StringAdd(Informations, StdWeek());
    StringAdd(Informations, ",");
    StringAdd(Informations, StringSubstr(TimeToString(OrderOpenTime(tk), TIME_DATE), 8, 2));
    StringAdd(Informations, ",");
    StringAdd(Informations, StringSubstr(TimeToString(OrderOpenTime(tk), TIME_DATE), 5, 2));
    StringAdd(Informations, ",");
    StringAdd(Informations, StringSubstr(TimeToString(OrderOpenTime(tk), TIME_DATE), 0, 4));
    StringAdd(Informations, ",");

    Commentnature = "Trade";
    if(StringFind(OrderComment(tk), "Rollover") >= 0) Commentnature = "Rollover";
    if(StringFind(OrderComment(tk), "Deposit") >= 0) Commentnature = "Deposit";
    StringAdd(Informations, Commentnature);

    //  Not used at the moment
    //   ------------------------------------------------------------------------
    //   Informations = StringAdd(Informations, ",", Value03);//Total Volume
    //   Informations = StringAdd(Informations, ",", Value02);//Avg. Volume
    //   Informations = StringAdd(Informations, ",", Value04);//Highest Price
    //   Informations = StringAdd(Informations, ",", Value05);//Lowest Price
    //   Informations = StringAdd(Informations, ",", Value06);//Highest Profit Pips
    //   Informations = StringAdd(Informations, ",", Value07);//Highest Loss Pips
    //   Informations = StringAdd(Informations, ",", GetProfitLossInPips());
    //+--------------------------------------------------------------------------+

    // Informations = StringAdd(Informations, ",", GetCustomData());
    StringTrimLeft(Informations);
    StringTrimRight(Informations);
    
    ResetOrderDurationValues();

    Print(__FUNCTION__, "Informations: ", Informations);

    return (Informations);
}

//+--------------------------------------------------------------------------
string FormatCSVExportValue(string CyName)
{
    string cName;
    StringConcatenate(cName, CharToString(34), CyName, CharToString(34));
    return (cName);
}

//+--------------------------------------------------------------------------
void ResetOrderDurationValues()
{
    Value01 = 0;
    Value02 = 0;
    Value03 = 0;
    Value04 = 0;
    Value05 = 0;
    Value06 = 0;
    Value07 = 0;
}

//+--------------------------------------------------------------------------
void SetOrderDurationValues()
{
    int str2time_36;
    double TheOpen = NormalizeDouble(OrderOpenPrice(tk), Digits());
    int str2time_8 = StringToTime(TimeToString(OrderOpenTime(tk)));
    int str2time_12 = StringToTime(TimeToString(OrderCloseTime(tk)));
    string TheSymbol = OrderSymbol(tk);
    int Limit = 0;
    int i = 1;
    // int TheTimeframe = 1;
    ENUM_TIMEFRAMES TheTimeframe = PERIOD_M1;
    double TheHigh = 0;
    double TheLow = 0;
    Limit = iBars(TheSymbol, TheTimeframe);
    Value04 = TheOpen;
    Value05 = TheOpen;
    for(i = 1; i <= Limit; i++) {
        str2time_36 = StringToTime(TimeToString(iTime(TheSymbol, TheTimeframe, i)));
        if(str2time_36 >= str2time_8 && str2time_36 <= str2time_12) {
            Value01++;
            Value03 = Value03 + iVolume(TheSymbol, TheTimeframe, i);
            TheHigh = NormalizeDouble(iHigh(TheSymbol, TheTimeframe, i), Digits());
            TheLow = NormalizeDouble(iLow(TheSymbol, TheTimeframe, i), Digits());
            if(TheHigh > Value04) Value04 = TheHigh;
            if(TheLow < Value05) Value05 = TheLow;
        }
        else
            if(str2time_36 < str2time_8) break;
    }
    if(Value01 > 0) Value02 = Value03 / Value01;
    if(GetPrimaryOrderType() == "BUY") {
        Value06 = ConvertDecimalPipsToWhole(Value04 - TheOpen);
        Value07 = ConvertDecimalPipsToWhole(Value05 - TheOpen);
    }
    else {
        if(GetPrimaryOrderType() == "SELL") {
            Value06 = ConvertDecimalPipsToWhole(TheOpen - Value05);
            Value07 = ConvertDecimalPipsToWhole(TheOpen - Value04);
        }
    }
    if(Value06 < 0) Value06 = 0;
    if(Value07 > 0) Value07 = 0;
}

//+--------------------------------------------------------------------------
int ConvertDecimalPipsToWhole(double TheValue)
{
    bool Result = false;
    int MyDig = 0;
    bool TheSym = false;
    // TheSym = MarketInfo(OrderSymbol(), MODE_DIGITS);
    TheSym = Digits();
    switch(TheSym) {
        case 1:
            MyDig = 100;
            break;
        case 2:
            MyDig = 1000;
            break;
        case 3:
            MyDig = 10000;
            break;
        case 4:
            MyDig = 100000;
            break;
        case 5:
            MyDig = 1000000;
            break;
        case 6:
            MyDig = 10000000;
    }
    Result = MathRound(TheValue * MyDig);
    return (Result);
}

//+--------------------------------------------------------------------------
string GetOrderSymbol()
{
    string sym = "";
    string symbol = "";
    symbol = OrderSymbol(tk);
    if(StringLen(symbol) == 7) symbol = StringSubstr(symbol, 0, 6);

    StringConcatenate(sym, StringSubstr(symbol, 0, 3), "/", StringSubstr(symbol, 3, 3));

    return (sym);
}

//+--------------------------------------------------------------------------
double GetProfitLossInPips()
{

    double  ProfitLossPips;
    double multiplier;

    //Added to get the correct multiplier   
    if(Digits() == 5) multiplier = 10000;
    if(Digits() == 4) multiplier = 10000;
    if(Digits() == 3) multiplier = 100;
    if(Digits() == 2) multiplier = 100;

    if(GetPrimaryOrderType() == "BUY") ProfitLossPips = ((OrderClosePrice(tk) - OrderOpenPrice(tk)) * multiplier);
    else
        if(GetPrimaryOrderType() == "SELL") ProfitLossPips = ((OrderOpenPrice(tk) - OrderClosePrice(tk)) * multiplier);

    return (ProfitLossPips);
}

//+--------------------------------------------------------------------------
double GetSpread()
{
    double spread = 0;
    // spread = MarketInfo(OrderSymbol(tk), MODE_SPREAD);
    spread = SymbolInfoInteger(OrderSymbol(tk), SYMBOL_SPREAD);
    return (spread);
}

//+--------------------------------------------------------------------------
string GetOrderType(ulong tk)
{
    int type = 0;
    string MagicNB = "";
    string comment = "";

    comment = OrderComment(tk);
    type = OrderType(tk);
    
    switch(type) {
        case ORDER_TYPE_BUY:
            MagicNB = "Buy";
            break;
        case ORDER_TYPE_BUY_LIMIT:
            MagicNB = "Buy Limit";
            break;
        case ORDER_TYPE_BUY_STOP:
            MagicNB = "Buy Stop";
            break;
        case ORDER_TYPE_SELL:
            MagicNB = "Sell";
            break;
        case ORDER_TYPE_SELL_LIMIT:
            MagicNB = "Sell Limit";
            break;
        case ORDER_TYPE_SELL_STOP:
            MagicNB = "Sell Stop";
            break;
        default:
            MagicNB = "Unknown";
    }
    if(StringFind(comment, "deposit") >= 0) MagicNB = "Deposit";
    return (MagicNB);
}

//+--------------------------------------------------------------------------
string GetPrimaryOrderType()
{
    int type = 0;
    string MagicNB = "";
    string comment = "";
    type = OrderType(tk);
    comment = OrderComment(tk);
    switch(type) {
        case ORDER_TYPE_BUY:
            MagicNB = "BUY";
            break;
        case ORDER_TYPE_BUY_LIMIT:
            MagicNB = "BUY";
            break;
        case ORDER_TYPE_BUY_STOP:
            MagicNB = "BUY";
            break;
        case ORDER_TYPE_SELL:
            MagicNB = "SELL";
            break;
        case ORDER_TYPE_SELL_LIMIT:
            MagicNB = "SELL";
            break;
        case ORDER_TYPE_SELL_STOP:
            MagicNB = "SELL";
            break;
        default:
            MagicNB = "UNKNOWN";
    }
    if(StringFind(comment, "deposit") >= 0) MagicNB = "DEPOSIT";
    return (MagicNB);
}

//+--------------------------------------------------------------------------
int BarCompleted()
{
    bool barok = false;
    if(TheTime == iTime(NULL, 0, 0)) barok = false;
    else {
        barok = true;
        TheTime = iTime(NULL, 0, 0);
    }
    return (barok);
}

//+--------------------------------------------------------------------------+
void CheckError(int Check, int ln)
{
    // if(Check != 0) Print("Last Error Occurred (", Check, "): ", ErrorDescription(Check));
    if(Check != 0) Print("Last Error Occurred (", Check, "): ... linea: ", ln);
}

// Added to get Week Number
//+--------------------------------------------------------------------------+
int StdWeek()
{
    MqlDateTime dt;
    
    // int iDay = (DayOfWeek() + 6) % 7 + 1,                    // convert day to standard index (1=Mon,...,7=Sun)
    // iWeek = (DayOfYear() - iDay + 10) / 7;                // calculate standard week number

    int iWeek = (dt.day_of_year - dt.day_of_week + 10) / 7;
    return(iWeek);
}





    // Informations = StringConcatenate(Informations, ",", OrderMagicNumber(tk));
    // Informations = StringConcatenate(Informations, ",", GetExpertNameByMagicNumber(OrderMagicNumber(tk)));
    // Informations = StringConcatenate(Informations, ",", OrderComment(tk));


// NOTE: Funciones de Conversión MT4 a MT5
// ------------------------------------------------------------------
// Account Info
int AccountNumber() { return AccountInfoInteger(ACCOUNT_LOGIN); }
string AccountCompany() { return AccountInfoString(ACCOUNT_COMPANY); }
string AccountCurrency() { return AccountInfoString(ACCOUNT_CURRENCY); }
string AccountName() { return AccountInfoString(ACCOUNT_NAME); }
string AccountServer() { return AccountInfoString(ACCOUNT_SERVER); }

// Terminal Info
string TerminalCompany() { return TerminalInfoString(TERMINAL_COMPANY); }
string TerminalName() { return TerminalInfoString(TERMINAL_NAME); }
bool IsDemo() { return AccountInfoInteger(ACCOUNT_TRADE_MODE) == ACCOUNT_TRADE_MODE_DEMO; }

int TimeDayOfWeek(datetime _dt)
{
    MqlDateTime dt;
    if(TimeToStruct(_dt, dt))
    {
        return dt.day_of_week;
    }
    return 0;
}


// NOTE: Informacion de las ordenes
// ------------------------------------------------------------------
string OrderComment(ulong tk) { return HistoryOrderGetString(tk, ORDER_COMMENT); }
ENUM_ORDER_TYPE OrderType(ulong tk) { return HistoryOrderGetInteger(tk, ORDER_TYPE); }
datetime OrderOpenTime(ulong tk) { return HistoryOrderGetInteger(tk, ORDER_TIME_DONE); }
int OrderMagicNumber(ulong tk) { return HistoryOrderGetInteger(tk, ORDER_MAGIC); }
double OrderLots(ulong tk) { return HistoryOrderGetDouble(tk, ORDER_VOLUME_INITIAL); }
string OrderSymbol(ulong tk) { return HistoryOrderGetString(tk, ORDER_SYMBOL); }
double OrderOpenPrice(ulong tk) { return HistoryOrderGetDouble(tk, ORDER_PRICE_OPEN); }
double OrderStopLoss(ulong tk) { return HistoryOrderGetDouble(tk, ORDER_SL); }
double OrderTakeProfit(ulong tk) { return HistoryOrderGetDouble(tk, ORDER_TP); }

// posibles mal (o buscar por Deals)
double OrderProfit(ulong tk) { return 0; }
double OrderClosePrice(ulong tk) { return HistoryOrderGetDouble(tk, ORDER_PRICE_CURRENT); }
int OrderCloseTime(ulong tk) { return TimeCurrent(); }
double OrderCommission(ulong tk) { return 0; }
double OrderSwap(ulong tk) { return 0; }
// ------------------------------------------------------------------
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