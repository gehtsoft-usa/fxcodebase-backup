// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=64340

//+------------------------------------------------------------------+
//|                               Copyright © 2018, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                    Paypal: https://goo.gl/9Rj74e |
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2018, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 0

extern bool CurrentSymbolOnly=false;
extern bool ShowPendingOrders=true;
extern bool ShowOpenPrice=true;
extern bool ShowStopPrice=true;
extern bool ShowLimitPrice=true;
extern bool ShowProfit=true;
extern color LabelsColor = clrWhite;
extern color LabelFontSize = 10;
extern int Corner = 1;

string IndicatorName;
string IndicatorObjPrefix;

string GenerateIndicatorName(const string target)
{
   string name = target;
   int try = 2;
   while (WindowFind(name) != -1)
   {
      name = target + " #" + IntegerToString(try++);
   }
   return name;
}

int init()
{
    IndicatorName = GenerateIndicatorName("Open_Positions");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
     IndicatorDigits(Digits);
    
     return(0);
}

int deinit()
{
    ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
    return(0);
}

string Dir(int OP)
{
    if (OP==OP_BUY) return ("BUY");
    if (OP==OP_SELL) return ("SELL");
    if (OP==OP_BUYLIMIT) return ("BUY LIMIT");
    if (OP==OP_BUYSTOP) return ("BUY STOP");
    if (OP==OP_SELLLIMIT) return ("SELL LIMIT");
    if (OP==OP_SELLSTOP) return ("SELL STOP");
    return ("");
}

class TextMaxSizeCalculator
{
    int _width;
    int _height;
public:
    TextMaxSizeCalculator()
    {
        _width = 0;
        _height = 0;
    }

    void AddText(const string text)
    {
        int width;
        int height;
        TextGetSize(text, width, height);
        if (_width < width)
        {
            _width = width;
        }
        if (_height < height)
        {
            _height = height;
        }
    }

    int GetWidth()
    {
        return _width;
    }
    int GetHeight()
    {
        return _height;
    }
};

int start()
{
    if(Bars<=3) return(0);
    int ExtCountedBars=IndicatorCounted();
    if (ExtCountedBars<0) return(-1);
    
    TextMaxSizeCalculator col0;
    col0.AddText("Symbol");
    TextMaxSizeCalculator col1;
    col1.AddText("Direction");
    TextMaxSizeCalculator col2;
    col2.AddText("Open price");
    TextMaxSizeCalculator col3;
    col3.AddText("Stop price");
    TextMaxSizeCalculator col4;
    col4.AddText("Limit price");
    TextMaxSizeCalculator col5;
    col5.AddText("Profit");
    int i;
    int y = 50;
    int x = 50;
    for (i=0;i<OrdersTotal();i++)
    {
        if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
        
        if (!CurrentSymbolOnly || OrderSymbol()==Symbol())
        {
            if (ShowPendingOrders || OrderType()==OP_BUY || OrderType()==OP_SELL)
            {
                col0.AddText(OrderSymbol());
                col1.AddText(Dir(OrderType()));
                if (ShowOpenPrice)
                {
                    col2.AddText(OrderOpenPrice());
                }
                
                if (ShowStopPrice)
                {
                    col3.AddText(OrderStopLoss());
                }
                
                if (ShowLimitPrice)
                {
                    col4.AddText(OrderTakeProfit());
                }
                
                if (ShowProfit)
                {
                    col5.AddText(OrderProfit());
                }
            }
        }
    }
    int col0_x = x;
    int col1_x = col0_x + col0.GetWidth() * 1.1;
    int col2_x = col1_x + col1.GetWidth() * 1.1;
    int col3_x = col2_x + col2.GetWidth() * 1.1;
    int col4_x = col3_x + col3.GetWidth() * 1.1;
    int col5_x = col4_x + col4.GetWidth() * 1.1;
    ObjectMakeLabel("Col_0", col0_x, y, "Symbol", LabelsColor, Corner, 0, "Arial", LabelFontSize);
    ObjectMakeLabel("Col_1", col1_x, y, "Direction", LabelsColor, Corner, 0, "Arial", LabelFontSize);
    ObjectMakeLabel("Col_2", col2_x, y, "Open price", LabelsColor, Corner, 0, "Arial", LabelFontSize);
    ObjectMakeLabel("Col_3", col3_x, y, "Stop price", LabelsColor, Corner, 0, "Arial", LabelFontSize);
    ObjectMakeLabel("Col_4", col4_x, y, "Limit price", LabelsColor, Corner, 0, "Arial", LabelFontSize);
    ObjectMakeLabel("Col_5", col5_x, y, "Profit", LabelsColor, Corner, 0, "Arial", LabelFontSize);
    y = y + col0.GetHeight() * 1.1;
    for (i=0;i<OrdersTotal();i++)
    {
        if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
        
        if (!CurrentSymbolOnly || OrderSymbol()==Symbol())
        {
            if (ShowPendingOrders || OrderType()==OP_BUY || OrderType()==OP_SELL)
            {
                ObjectMakeLabel("Order_0_" + IntegerToString(i), col0_x, y, OrderSymbol(), LabelsColor, Corner, 0, "Arial", LabelFontSize);
                ObjectMakeLabel("Order_1_" + IntegerToString(i), col1_x, y, Dir(OrderType()), LabelsColor, Corner, 0, "Arial", LabelFontSize);
                if (ShowOpenPrice)
                {
                    ObjectMakeLabel("Order_2_" + IntegerToString(i), col2_x, y, OrderOpenPrice(), LabelsColor, Corner, 0, "Arial", LabelFontSize);
                }
                
                if (ShowStopPrice)
                {
                    ObjectMakeLabel("Order_3_" + IntegerToString(i), col3_x, y, OrderStopLoss(), LabelsColor, Corner, 0, "Arial", LabelFontSize);
                }
                
                if (ShowLimitPrice)
                {
                    ObjectMakeLabel("Order_4_" + IntegerToString(i), col4_x, y, OrderTakeProfit(), LabelsColor, Corner, 0, "Arial", LabelFontSize);
                }
                
                if (ShowProfit)
                {
                    ObjectMakeLabel("Order_5_" + IntegerToString(i), col5_x, y, OrderProfit(), LabelsColor, Corner, 0, "Arial", LabelFontSize);
                }
                int width;
                int height;
                TextGetSize(OrderSymbol(), width, height);
                y = y + height * 1.1;
            }
        }
    }

    return(0);
}

void ObjectMakeLabel( string nm, int xoff, int yoff, string LabelTexto, color LabelColor, int LabelCorner=1, int Window = 0, string Font = "Arial", int FSize = 8 )
{
    ObjectDelete(IndicatorObjPrefix + nm);
    ObjectCreate(IndicatorObjPrefix +  nm, OBJ_LABEL, Window, 0, 0 );
    ObjectSet(IndicatorObjPrefix +  nm, OBJPROP_CORNER, LabelCorner );
    ObjectSet(IndicatorObjPrefix +  nm, OBJPROP_XDISTANCE, xoff );
    ObjectSet(IndicatorObjPrefix +  nm, OBJPROP_YDISTANCE, yoff );
    ObjectSet(IndicatorObjPrefix +  nm, OBJPROP_BACK, false );
    ObjectSetText(IndicatorObjPrefix +  nm, LabelTexto, FSize, Font, LabelColor );
    return;
}