//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=72707&p=159933#p159933

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

#property indicator_plots 0
#property indicator_chart_window
#property indicator_buffers 0

enum ENUM_FRACTAL_TYPE {
    FRACTAL_UPPER,
    FRACTAL_LOWER
};

//--- input parameters
input color color_long = clrLimeGreen;
input color color_short = clrDarkOrange;
input int line_width = 2;
input int arrow_size = 3;
input int arrow_code_up = 233;

//--- global variables
bool LONG, SHORT;
int buys, sells;
bool trade;
string id = "quazi";

datetime last_bar_time;
datetime alert_time;

int fractal_handle;
double fractal_upper[];
double fractal_lower[];
int fractal_count;

double fractal[];
int fractal_candle[];
int fractal_dir[];
int fractal_size;

int OnInit()
{
    // Initialize fractal handle
    fractal_handle = iFractals(_Symbol, _Period);
    if(fractal_handle == INVALID_HANDLE) {
        Print("Error creating fractal handle");
        return(INIT_FAILED);
    }
    
    ArraySetAsSeries(fractal_upper, true);
    ArraySetAsSeries(fractal_lower, true);
    
    last_bar_time = 0;
    alert_time = 0;
    
    return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
    if(fractal_handle != INVALID_HANDLE) {
        IndicatorRelease(fractal_handle);
    }
    remove_objects();
    Comment("");
}

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
    ArraySetAsSeries(time, true);
    
    // Check for new bar
    if(prev_calculated == 0 || time[0] != last_bar_time) {
        last_bar_time = time[0];
        buys = 0;
        sells = 0;
        
        // Process fractals
        check_fractals(rates_total);
        
        // Remove old objects before drawing new ones
        remove_objects();
        
        // Check patterns
        for(int s = 0; s < fractal_size - 5; s++) {
            check_long_short(s, time);
        }
    }
    
    return(rates_total);
}

void check_fractals(int rates_total)
{
    // Copy fractal data
    if(CopyBuffer(fractal_handle, 0, 0, rates_total, fractal_upper) < 0 ||
       CopyBuffer(fractal_handle, 1, 0, rates_total, fractal_lower) < 0) {
        Print("Error copying fractal buffers: ", GetLastError());
        return;
    }
    
    fractal_size = 0;
    ArrayResize(fractal, rates_total * 2);
    ArrayResize(fractal_candle, rates_total * 2);
    ArrayResize(fractal_dir, rates_total * 2);
    
    // Process upper and lower fractals
    for(int i = 0; i < rates_total; i++) {
        if(fractal_upper[i] != EMPTY_VALUE) {
            fractal[fractal_size] = fractal_upper[i];
            fractal_candle[fractal_size] = i;
            fractal_dir[fractal_size] = 1;
            fractal_size++;
        }
        if(fractal_lower[i] != EMPTY_VALUE) {
            fractal[fractal_size] = fractal_lower[i];
            fractal_candle[fractal_size] = i;
            fractal_dir[fractal_size] = -1;
            fractal_size++;
        }
    }
    
    // Resize arrays to actual size
    ArrayResize(fractal, fractal_size);
    ArrayResize(fractal_candle, fractal_size);
    ArrayResize(fractal_dir, fractal_size);
}

void check_long_short(int shift, const datetime &time_array[])
{
    bool up = false;
    bool dn = false;
    
    // Pattern detection conditions
    up = (
        fractal_dir[shift] == -1 && 
        fractal_dir[shift+1] == 1 && 
        fractal_dir[shift+2] == -1 &&
        fractal_dir[shift+3] == 1 &&
        fractal_dir[shift+4] == -1 &&
        
        fractal[shift] < fractal[shift+1] &&
        fractal[shift] > fractal[shift+2] &&
        fractal[shift] < fractal[shift+3] &&
        fractal[shift] > fractal[shift+4] &&
        
        fractal[shift+1] > fractal[shift+2] &&
        fractal[shift+1] > fractal[shift+3] &&
        fractal[shift+1] > fractal[shift+4]
    );
    
    dn = (
        fractal_dir[shift] == 1 && 
        fractal_dir[shift+1] == -1 && 
        fractal_dir[shift+2] == 1 &&
        fractal_dir[shift+3] == -1 &&
        fractal_dir[shift+4] == 1 &&
        
        fractal[shift] > fractal[shift+1] &&
        fractal[shift] < fractal[shift+2] &&
        fractal[shift] > fractal[shift+3] &&
        fractal[shift] < fractal[shift+4] &&
        
        fractal[shift+1] < fractal[shift+2] &&
        fractal[shift+1] < fractal[shift+3] &&
        fractal[shift+1] < fractal[shift+4]
    );
    
    // Pattern found
    if(up || dn) {
        color clr = clrBlue;
        if(up) {
            clr = color_long;
            buys++;
        }
        if(dn) {
            clr = color_short;
            sells++;
        }
        
        // Draw trend lines
        for(int t = shift; t < shift + 4; t++) {
            datetime t1 = time_array[fractal_candle[t]];
            datetime t2 = time_array[fractal_candle[t+1]];
            make_trend(IntegerToString(t1), t1, fractal[t], t2, fractal[t+1], clr, line_width, STYLE_SOLID);
        }
        
        // Draw arrow and alert
        if(up) {
            make_arrow("BUY" + IntegerToString(time_array[fractal_candle[shift]]), 
                       fractal[shift], 
                       time_array[fractal_candle[shift]], 
                       arrow_size, arrow_code_up, color_long);
            
            if(fractal_candle[shift] < 3 && TimeCurrent() != alert_time) {
                LONG = true;
                Alert(StringFormat("%s LONG | Candle: %d | Period: %d | Time: %s",
                      _Symbol, fractal_candle[shift], _Period, TimeToString(time_array[fractal_candle[shift]])));
                PlaySound("alert.wav");
                alert_time = TimeCurrent();
            }
        }
        
        if(dn) {
            make_arrow("SELL" + IntegerToString(time_array[fractal_candle[shift]]), 
                       fractal[shift], 
                       time_array[fractal_candle[shift]], 
                       arrow_size, arrow_code_up + 1, color_short);
            
            if(fractal_candle[shift] < 3 && TimeCurrent() != alert_time) {
                SHORT = true;
                Alert(StringFormat("%s SHORT | Candle: %d | Period: %d | Time: %s",
                      _Symbol, fractal_candle[shift], _Period, TimeToString(time_array[fractal_candle[shift]])));
                PlaySound("alert.wav");
                alert_time = TimeCurrent();
            }
        }
    }
}

void remove_objects()
{
    for(int i = ObjectsTotal(0, 0, -1) - 1; i >= 0; i--) {
        string name = ObjectName(0, i);
        if(StringFind(name, id) >= 0) {
            ObjectDelete(0, name);
        }
    }
}

void make_trend(string name, datetime t1, double p1, datetime t2, double p2, color clr, int width, int style)
{
    name = id + name;
    ObjectCreate(0, name, OBJ_TREND, 0, t1, p1, t2, p2);
    ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
    ObjectSetInteger(0, name, OBJPROP_WIDTH, width);
    ObjectSetInteger(0, name, OBJPROP_STYLE, style);
    ObjectSetInteger(0, name, OBJPROP_RAY, false);
}

void make_arrow(string name, double price, datetime time, int size, int code, color clr)
{
    name = id + name;

    ObjectCreate(0, name, OBJ_ARROW, 0, time, price);
    ObjectSetInteger(0, name, OBJPROP_ARROWCODE, code);
    ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
    ObjectSetInteger(0, name, OBJPROP_WIDTH, size);
    ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
    if (code == 234)
    {
        ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_LOWER);
    }
    
}
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=72707&p=159933#p159933

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