//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&p=150850#p150850
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
//-----
#property indicator_separate_window
#property indicator_buffers 3
//#property indicator_minimum 0

#property indicator_color1 Lime
#property indicator_color2 Red
//#property indicator_color3 Blue

extern string  FNAME_SPREAD = "Tick_Volume_Data"; // better to have no spaces or periods in file name
extern bool    LOG_VOLUMES = false;
extern bool    EMAIL_SENT = false;
input bool showBars = false; // Show Bars?

double UpTicks [];
double DownTicks [];
double dXecn = 1;
double Diff;

double line [];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
    IndicatorShortName("TicksSeparateVolumeDif(" + Symbol() + ")");

    SetIndexBuffer(0, UpTicks);
    SetIndexBuffer(1, DownTicks);
    //SetIndexBuffer(0,Diff);

    SetIndexStyle(0, DRAW_HISTOGRAM, 0, 3);
    SetIndexStyle(1, DRAW_HISTOGRAM, 0, 2);
    //SetIndexStyle(0,DRAW_HISTOGRAM,0,3);


    SetIndexLabel(0, "UpTicks");
    SetIndexLabel(1, "DownTicks");
    //SetIndexLabel(0,"Diff");

    if(!showBars)
    {
        SetIndexStyle(0, DRAW_NONE);
        SetIndexStyle(1, DRAW_NONE);
    }

    SetIndexBuffer(2, line);
    SetIndexStyle(2, DRAW_LINE);

    if(Digits == 3 || Digits == 5){
        dXecn = 10;
    }

    return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
{

    ObjectDelete("UpTicks1");
    ObjectDelete("DownTicks1");
    ObjectDelete("UpTicks2");
    ObjectDelete("DownTicks2");

    Comment("");

    return(0);
}
//+------------------------------------------------------------------+
//| Ticks Volume Indicator                                           |
//+------------------------------------------------------------------+
int start()
{


    ObjectDelete("UpTicks1");
    ObjectDelete("DownTicks1");
    ObjectDelete("UpTicks2");
    ObjectDelete("DownTicks2");

    int i, counted_bars = IndicatorCounted();
    //---- check for possible errors
    if(counted_bars < 0) return(-1);
    //---- last counted bar will be recounted
    if(counted_bars > 0) counted_bars--;
    int limit = Bars - counted_bars;


    //----
    for(i = 0; i < limit; i++)
    {
        //UpTicks[i]=(Volume[i]+(Close[i]-Open[i])/Point/dXecn)/2;
        //DownTicks[i]=Volume[i]-UpTicks[i];
        Diff = ((Volume[i] + (Close[i] - Open[i]) / Point / dXecn) / 2) - (Volume[i] - ((Volume[i] + (Close[i] - Open[i]) / Point / dXecn) / 2));

        if(Diff > 0){ UpTicks[i] = Diff; DownTicks[i] = 0; line[i] = Diff; }
        if(Diff < 0){ DownTicks[i] = Diff; UpTicks[i] = 0; line[i] = Diff; }
        if(Diff == 0){ DownTicks[i] = 0; UpTicks[i] = 0; line[i] = Diff; }


    }
    if((UpTicks[0] > 60 || DownTicks[0] > 60) && EMAIL_SENT == false){
        // send email 
        SendMail("Volume over 60", "Volume over 60 @ " + TimeToStr(TimeCurrent()));
        EMAIL_SENT = true;
    }
    if(NewBar() && LOG_VOLUMES){
        double dRange = (High[1] - Low[1]) / Point / dXecn;
        RefreshRates();
        WriteToFile(StringConcatenate(UpTicks[1], ",", DownTicks[1], ",", dRange, ",", MarketInfo(Symbol(), MODE_SPREAD) / dXecn));
    }

    string BV = "BUYERS VOLUME: " + DoubleToStr(UpTicks[0], 0) + "";
    string SV = "SELLERS VOLUME: " + DoubleToStr(DownTicks[0] * (-1), 0) + "";


    ObjectCreate("UpTicks2", OBJ_LABEL, WindowFind("TicksSeparateVolumeDif(" + Symbol() + ")"), 0, 0);
    ObjectSetText("UpTicks2", StringSubstr((BV), 0), 10, "Tahoma Bold", White);
    ObjectSet("UpTicks2", OBJPROP_CORNER, 0);
    ObjectSet("UpTicks2", OBJPROP_XDISTANCE, 5);
    ObjectSet("UpTicks2", OBJPROP_YDISTANCE, 16);

    ObjectCreate("DownTicks2", OBJ_LABEL, WindowFind("TicksSeparateVolumeDif(" + Symbol() + ")"), 0, 0);
    ObjectSetText("DownTicks2", StringSubstr((SV), 0), 10, "Tahoma Bold", White);
    ObjectSet("DownTicks2", OBJPROP_CORNER, 0);
    ObjectSet("DownTicks2", OBJPROP_XDISTANCE, 5);
    ObjectSet("DownTicks2", OBJPROP_YDISTANCE, 30);

    //----
    return(0);
}
//+------------------------------------------------------------------+

void WriteToFile(string sText)
{
    int iHandle;
    iHandle = FileOpen(FNAME_SPREAD + ".csv", FILE_CSV | FILE_READ | FILE_WRITE, ',');
    if(iHandle > 0){
        FileSeek(iHandle, 0, SEEK_END);
        FileWrite(iHandle, TimeToStr(TimeCurrent() - 60), Symbol(), Period(), sText);
        FileClose(iHandle);
    }
}

bool NewBar()
{
    // check for new bar 
    static datetime LastTime = 0;

    if(Time[0] != LastTime) {
        LastTime = Time[0];
        return (true);
    }
    else
        return (false);
}

//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&p=150850#p150850
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