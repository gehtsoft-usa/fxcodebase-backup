// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=69295

//+------------------------------------------------------------------+
//|                               Copyright © 2019, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------+
//|                                Patreon :  https://goo.gl/GdXWeN  |
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2019, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property strict

#property indicator_separate_window
#property indicator_buffers 7
#property indicator_color1 Magenta
#property indicator_color2 Pink
#property indicator_color3 Orange
#property indicator_color4 Yellow
#property indicator_color5 DarkSeaGreen
           
double buffer1[];
double buffer2[];
double buffer3[];
double MA1buffer[];
double MA2buffer[];
double MA_sUP[];
double MA_sDN[];

double Min, Max;

extern int period=14;
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
extern int MA1period=9, MA2period=45;
extern string TypeHelp = "SMA- 0, EMA - 1, SMMA - 2, LWMA- 3";
extern string TypeHelp2 = "John Hyden settings TypeMA1=0, TypeMA2=3";
extern int TypeMA1=5;
extern int TypeMA2=0;

extern int SignalBar = 1; //�������� ������� �� ����. 0 - �� �������� ����, > 0 - �� ��������. 
extern int NumLine = 1; //����� ����� �� ���������
extern int  widthLine = 2;   //������� �����

//Signaler v 1.7
// More templates and snippets on https://github.com/sibvic/mq4-templates
input string   AlertsSection            = ""; // == Alerts ==
input bool     popup_alert              = false; // Popup message
input bool     notification_alert       = false; // Push notification
input bool     email_alert              = false; // Email
input bool     play_sound               = false; // Play sound on alert
input string   sound_file               = ""; // Sound file
input bool     start_program            = false; // Start inputal program
input string   program_path             = ""; // Path to the inputal program executable
input bool     advanced_alert           = false; // Advanced alert (Telegram/Discord/other platform (like another MT4))
input string   advanced_key             = ""; // Advanced alert key
input string   Comment2                 = "- You can get a key via @profit_robots_bot Telegram Bot. Visit ProfitRobots.com for discord/other platform keys -";
input string   Comment3                 = "- Allow use of dll in the indicator parameters window -";
input string   Comment4                 = "- Install AdvancedNotificationsLib.dll -";

// AdvancedNotificationsLib.dll could be downloaded here: http://profitrobots.com/Home/TelegramNotificationsMT4
#import "AdvancedNotificationsLib.dll"
void AdvancedAlert(string key, string text, string instrument, string timeframe);
#import
#import "shell32.dll"
int ShellExecuteW(int hwnd,string Operation,string File,string Parameters,string Directory,int ShowCmd);
#import

class Signaler
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   string _prefix;
public:
   Signaler(const string symbol, ENUM_TIMEFRAMES timeframe)
   {
      _symbol = symbol;
      _timeframe = timeframe;
   }

   void SetMessagePrefix(string prefix)
   {
      _prefix = prefix;
   }

   string GetSymbol()
   {
      return _symbol;
   }

   ENUM_TIMEFRAMES GetTimeframe()
   {
      return _timeframe;
   }

   string GetTimeframeStr()
   {
      switch (_timeframe)
      {
         case PERIOD_M1: return "M1";
         case PERIOD_M5: return "M5";
         case PERIOD_D1: return "D1";
         case PERIOD_H1: return "H1";
         case PERIOD_H4: return "H4";
         case PERIOD_M15: return "M15";
         case PERIOD_M30: return "M30";
         case PERIOD_MN1: return "MN1";
         case PERIOD_W1: return "W1";
      }
      return "M1";
   }

   void SendNotifications(const string subject, string message = NULL, string symbol = NULL, string timeframe = NULL)
   {
      if (message == NULL)
         message = subject;
      if (_prefix != "" && _prefix != NULL)
         message = _prefix + message;
      if (symbol == NULL)
         symbol = _symbol;
      if (timeframe == NULL)
         timeframe = GetTimeframeStr();

      if (start_program)
         ShellExecuteW(0, "open", program_path, "", "", 1);
      if (popup_alert)
         Alert(message);
      if (email_alert)
         SendMail(subject, message);
      if (play_sound)
         PlaySound(sound_file);
      if (notification_alert)
         SendNotification(message);
      if (advanced_alert && advanced_key != "" && !IsTesting())
         AdvancedAlert(advanced_key, message, symbol, timeframe);
   }
};

datetime alertBar=0;
Signaler* signaler;
double fish[], value[];
      
int init()
{
   if (!IsDllsAllowed() && advanced_alert)
   {
      Print("Error: Dll calls must be allowed!");
      return INIT_FAILED;
   }
   signaler = new Signaler(_Symbol, (ENUM_TIMEFRAMES)_Period);
   signaler.SetMessagePrefix(_Symbol + "/" + signaler.GetTimeframeStr() + ": ");
   IndicatorBuffers(9);
   SetIndexBuffer(0,buffer1);
   SetIndexBuffer(1,buffer2);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexLabel(2,"line");
   SetIndexBuffer(2,buffer3);
   SetIndexStyle(3,DRAW_LINE);
   SetIndexLabel(3,"MA1 "+MA1period);
   SetIndexStyle(4,DRAW_LINE);
   SetIndexLabel(4,"MA2 "+MA2period);
   SetIndexBuffer(3,MA1buffer);
   SetIndexBuffer(4,MA2buffer);
   
   SetIndexBuffer(5,MA_sUP);
   SetIndexStyle(5,DRAW_HISTOGRAM, EMPTY, widthLine, DeepSkyBlue);
   SetIndexBuffer(6,MA_sDN);
   SetIndexStyle(6,DRAW_HISTOGRAM, EMPTY, widthLine, Magenta);

   SetIndexStyle(7, DRAW_NONE);
   SetIndexBuffer(7, fish);

   SetIndexStyle(8, DRAW_NONE);
   SetIndexBuffer(8, value);
   
   return(0);
}

int deinit()
{
   delete signaler;
   signaler = NULL;
   int i;
   for (i=0;i>Bars;i++)
   {
      ObjectDelete("SELL SIGNAL: "+DoubleToStr(i,0));
      ObjectDelete("BUY SIGNAL: "+DoubleToStr(i,0));
      ObjectDelete("EXIT: "+DoubleToStr(i,0));
   }
   return(0);
}

int start()
{
   double Threshold=1.2; 
   int counted_bars = IndicatorCounted();
   int limit = MathMin(Bars - 1 - 2, Bars - counted_bars - 1);
   for (int i = limit; i >= 0; i--)
   {
      double MaxH = High[Highest(NULL,0,MODE_HIGH,period,i)];
      double MinL = Low[Lowest(NULL,0,MODE_LOW,period,i)];
      double _price;
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
      double Value1 = value[i + 1] == EMPTY_VALUE ? 0 : value[i + 1];
      value[i] = 0.33*2*((_price-MinL)/(MaxH-MinL)-0.5) + 0.67 * Value1;     
      value[i] = MathMin(MathMax(value[i], -0.999), 0.999); 
      double Fish1 = fish[i + 1] == EMPTY_VALUE ? 0 : fish[i + 1];
      fish[i] = 0.5 * MathLog((1 + value[i]) / (1 - value[i])) + 0.5 * Fish1;
      buffer1[i] = 0;
      buffer2[i] = 0;
      if (fish[i] < 0 && Fish1 > 0) 
      {
         if (Signals)
         {
            ObjectCreate("EXIT: "+DoubleToStr(i,0),OBJ_TEXT,0,Time[i],_price);
            ObjectSetText("EXIT: "+DoubleToStr(i,0),"EXIT AT "+DoubleToStr(_price,4),8,"Arial",PowderBlue);
         }
      }   
      if (fish[i] > 0 && Fish1 < 0)
      {
         if (Signals)
         {
            ObjectCreate("EXIT: "+DoubleToStr(i,0),OBJ_TEXT,0,Time[i],_price);
            ObjectSetText("EXIT: "+DoubleToStr(i,0),"EXIT AT "+DoubleToStr(_price,4),8,"Arial",Plum);
         }
      }        
      if (fish[i] >= 0)
      {
         buffer1[i] = fish[i];
         buffer3[i] = fish[i];
      }
      else
      {
         buffer2[i] = fish[i];
         buffer3[i] = fish[i];
      }
      
      double Fish2 = fish[i + 2] == 0 ? 0 : fish[i + 2];
      if ((fish[i] < -Threshold) && (fish[i] > Fish1) && (Fish1 <= Fish2))
      {     
         if (Signals)
         {
            ObjectCreate("SELL SIGNAL: "+DoubleToStr(i,0),OBJ_TEXT,0,Time[i],_price);
            ObjectSetText("SELL SIGNAL: "+DoubleToStr(i,0),"SELL AT "+DoubleToStr(_price,4),8,"Arial",Magenta);
         }
      }

      if ((fish[i] > Threshold) && (fish[i] < Fish1) && (Fish1 >= Fish2))
      {
         if (Signals)
         {
            ObjectCreate("BUY SIGNAL: "+DoubleToStr(i,0),OBJ_TEXT,0,Time[i],_price);
            ObjectSetText("BUY SIGNAL: "+DoubleToStr(i,0),"BUY AT "+DoubleToStr(_price,4),8,"Arial",DeepSkyBlue);
         }
      }
      MA1buffer[i]=iMAOnArray(buffer3,Bars,MA1period,0,TypeMA1,i);
      MA2buffer[i]=iMAOnArray(MA1buffer,Bars,MA2period,0,TypeMA2,i);
      MA_sUP[i] = EMPTY_VALUE;
      MA_sDN[i] = EMPTY_VALUE;
      if(NumLine <= 1 ||NumLine > 3) 
      {
         if(buffer3[i] > 0 && buffer3[i+1] < 0) MA_sUP[i] = INDICATOR_MAXIMUM;
         if(buffer3[i] < 0 && buffer3[i+1] > 0) MA_sDN[i] = -INDICATOR_MINIMUM;
      }
      if(NumLine == 2) 
      {
         if(MA1buffer[i] > 0 && MA1buffer[i+1] < 0) MA_sUP[i] = INDICATOR_MAXIMUM;
         if(MA1buffer[i] < 0 && MA1buffer[i+1] > 0) MA_sDN[i] = -INDICATOR_MINIMUM;
      }
      if(NumLine == 3) 
      {
         if(MA2buffer[i] > 0 && MA2buffer[i+1] < 0) MA_sUP[i] = INDICATOR_MAXIMUM;
         if(MA2buffer[i] < 0 && MA2buffer[i+1] > 0) MA_sDN[i] = -INDICATOR_MINIMUM;
      }
   }
   if (MA_sDN[0] != EMPTY_VALUE)
   {   
      if (Time[0] > alertBar)
      {
         signaler.SendNotifications("Down");
         alertBar = Time[0];
      }
   }
   if (MA_sUP[0] != EMPTY_VALUE)
   {
      if (Time[0] > alertBar) 
      {
         signaler.SendNotifications("Up");
         alertBar = Time[0];
      }
   } 
   return(0);
}
