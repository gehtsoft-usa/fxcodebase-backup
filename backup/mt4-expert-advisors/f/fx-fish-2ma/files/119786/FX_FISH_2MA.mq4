// Id: 21634
// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=66239


//+------------------------------------------------------------------+
//|                               Copyright © 2018, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  | 
//|                                    Paypal: https://goo.gl/9Rj74e |
//+------------------------------------------------------------------+
//|                                Patreon :  https://goo.gl/GdXWeN  |  
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
//|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
//+------------------------------------------------------------------+


#property copyright "Copyright © 2018, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1 Lime
#property indicator_color2 Red
#property indicator_color3 Black
#property indicator_color4 White
#property indicator_color5 White
#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 1
#property indicator_width4 1
#property indicator_width5 1
           
double buffer1[];
double buffer2[];
double buffer3[];
double MA1buffer[];
double MA2buffer[];

extern int period=30;
extern int price=0; // 0 or other = (H+L)/2
                    // 1 = Open
                    // 2 = Close
                    // 3 = High
                    // 4 = Low
                    // 5 = (H+L+C)/3
                    // 6 = (O+C+H+L)/4
                    // 7 = (O+C)/2
extern bool Mode_Fast= False;
extern bool Signals= False;
extern int MA1period=1, MA2period=5;
extern string TypeHelp = "SMA- 0, EMA - 1, SMMA - 2, LWMA- 3";
extern string TypeHelp2 = "John Hyden settings TypeMA1=1, TypeMA2=1";
extern int TypeMA1=0;
extern int TypeMA2=0;
extern double TriggerValue = 0;
extern bool     Sound_Alert              = true;
extern bool     Email_Alert              = false;
extern bool     External_Alert           = false;
extern string   External_Alert_Key       = "";
extern string   Comment2                 = "- This will allow you to send an alert into you Telegram account or Telegram Channel -";
extern string   Comment3                 = "- You can get a external alert key by starting a dialog with @profit_robots_bot -";
extern string   Comment4                 = "- Also, you need to install TelegramNotificationsLib.dll and allow use of dll in the indicator parameters window -";

#import "TelegramNotificationsLib.dll"
void AlertTelegram(string key, string text, string instrument, string timeframe);
#import

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
  IndicatorName = GenerateIndicatorName("FX_FISH_2MA");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
    SetIndexStyle(0,DRAW_HISTOGRAM,STYLE_SOLID);//,2,SteelBlue);
    SetIndexBuffer(0,buffer1);
    SetIndexStyle(1,DRAW_HISTOGRAM,STYLE_SOLID);//,2,Orange);
    SetIndexBuffer(1,buffer2);
    SetIndexStyle(2,DRAW_LINE,STYLE_DOT);
    SetIndexLabel(2,"line");
    SetIndexBuffer(2,buffer3);
    SetIndexStyle(3,DRAW_LINE,STYLE_DOT);
    SetIndexLabel(3,"MA1 "+MA1period);
    SetIndexStyle(4,DRAW_LINE,STYLE_DOT);
    SetIndexLabel(4,"MA2 "+MA2period);
    SetIndexBuffer(3,MA1buffer);
    SetIndexBuffer(4,MA2buffer);
    return(0);
}

int deinit()
{
    ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
    return(0);
}


double Value=0,Value1=0,Value2=0,Fish=0,Fish1=0,Fish2=0;

int buy=0,sell=0;

int start()
{
  int counted_bars=IndicatorCounted();
  int i;
  int barras;
  double _price;
  double tmp;
  
  double MinL=0;
  double MaxH=0;
  
  double Threshold=1.2; 

  if(counted_bars>0) counted_bars--;

  //barras = Bars;�
  barras = Bars-counted_bars;
  if (Mode_Fast)
    barras = 100;
  i = 0;
  while(i<barras)
  {
    MaxH = High[Highest(NULL,0,MODE_HIGH,period,i)];
    MinL = Low[Lowest(NULL,0,MODE_LOW,period,i)];
    
    switch (price)
    {
      case 1: _price = Open[i]; break;
      case 2: _price = Close[i]; break;
      case 3: _price = High[i]; break;
      case 4: _price = Low[i]; break;
      case 5: _price = (High[i]+Low[i]+Close[i])/3; break;
      case 6: _price = (Open[i]+High[i]+Low[i]+Close[i])/4; break;
      case 7: _price = (Open[i]+Close[i])/2; break;
      default: _price = (High[i]+Low[i])/2; break;
    }
    
          
    Value = 0.33*2*((_price-MinL)/(MaxH-MinL)-0.5) + 0.67*Value1;     
    Value=MathMin(MathMax(Value,-0.999),0.999); 
    Fish = 0.5*MathLog((1+Value)/(1-Value))+0.5*Fish1;
    
    buffer1[i]= 0;
    buffer2[i]= 0;
    
    if ( (Fish<0) && (Fish1>0)) 
    {
      if (Signals)
      {
        ObjectCreate(IndicatorObjPrefix + "EXIT: "+DoubleToStr(i,0),OBJ_TEXT,0,Time[i],_price);
        ObjectSetText(IndicatorObjPrefix + "EXIT: "+DoubleToStr(i,0),"EXIT AT "+DoubleToStr(_price,4),7,"Arial",White);
      }
      buy = 0;
    }   
    if ((Fish>0) && (Fish1<0))
    {
      if (Signals)
      {
        ObjectCreate(IndicatorObjPrefix + "EXIT: "+DoubleToStr(i,0),OBJ_TEXT,0,Time[i],_price);
        ObjectSetText(IndicatorObjPrefix + "EXIT: "+DoubleToStr(i,0),"EXIT AT "+DoubleToStr(_price,4),7,"Arial",White);
      }
      sell = 0;
    }        
      
    if (Fish>=0)
    {
      buffer1[i] = Fish;
      buffer3[i]= Fish;
    }
    else
    {
      buffer2[i] = Fish;  
      buffer3[i]= Fish;
    }
      
    tmp = i;
    if ((Fish<-Threshold) && 
        (Fish>Fish1) && 
        (Fish1<=Fish2))
    {     
      if (Signals)
      {
        ObjectCreate(IndicatorObjPrefix + "SELL SIGNAL: "+DoubleToStr(i,0),OBJ_TEXT,0,Time[i],_price);
        ObjectSetText(IndicatorObjPrefix + "SELL SIGNAL: "+DoubleToStr(i,0),"SELL AT "+DoubleToStr(_price,4),7,"Arial",Red);
      }
      sell = 1;
    }

    if ((Fish>Threshold) && 
        (Fish<Fish1) && 
        (Fish1>=Fish2))
    {
      if (Signals)
      {
        ObjectCreate(IndicatorObjPrefix + "BUY SIGNAL: "+DoubleToStr(i,0),OBJ_TEXT,0,Time[i],_price);
        ObjectSetText(IndicatorObjPrefix + "BUY SIGNAL: "+DoubleToStr(i,0),"BUY AT "+DoubleToStr(_price,4),7,"Arial",Lime);
      }
      buy=1;
    }

    Value1 = Value;
    Fish2 = Fish1;  
    Fish1 = Fish;

    i++;
  }
  
  for(i=0; i<barras; i++)
    MA1buffer[i]=iMAOnArray(buffer3,Bars,MA1period,0,TypeMA1,i);
  for(i=0; i<barras; i++)
    MA2buffer[i]=iMAOnArray(MA1buffer,Bars,MA2period,0,TypeMA2,i);
  Comment("BUFFER 2 =",buffer3[0]); 

  if (Open[0] >= TriggerValue)
  {
    SendNotifications("price is equal or above the specified value when new candle opens");
  }

  return(0);
}

datetime _lastDatetime;
void SendNotifications(const string message)
{
    datetime currentTime = iTime(_Symbol, _Period, 0);
    if (_lastDatetime == currentTime)
        return;

    _lastDatetime = currentTime;
    if (Sound_Alert)
        Alert(message);
    if (Email_Alert)
        SendMail(message, message);
    if (External_Alert && External_Alert_Key != "")
        AlertTelegram(External_Alert_Key, message, _Symbol, _Period);
}
//+------------------------------------------------------------------+