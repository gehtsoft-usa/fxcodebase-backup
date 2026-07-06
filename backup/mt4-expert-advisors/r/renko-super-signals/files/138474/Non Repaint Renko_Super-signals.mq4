//Available @ http://fxcodebase.com

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
#property indicator_chart_window
#property indicator_buffers 8
#property indicator_color1 clrRed
#property indicator_color2 clrLime
#property indicator_color3 clrRed
#property indicator_color4 clrLime
#property indicator_color5 clrRed
#property indicator_color6 clrLime
#property indicator_color7 clrRed
#property indicator_color8 clrLime
#property indicator_width1 3
#property indicator_width2 3
#property indicator_width3 6
#property indicator_width4 6
#property indicator_width5 2
#property indicator_width6 2
#property indicator_width7 4
#property indicator_width8 4
#include<Controls/Button.mqh>

extern int  PeriodWeakChannel = 24;  // Period Weak Channel
extern int  PeriodMainChannel = 96;  // Period Main Channel

extern bool enabledOn       = true;  // Display Indicator
extern bool alertsOn        = true;  // Enabled Alerts
extern bool alertsMessage   = true;  // Enabled Message 
extern bool alertsSound     = false; // Enable Sound
extern bool alertsEmail     = false; // Enable Email
extern string soundFile     ="alert2.wav"; // Sound File

extern int        IndicatorOnX           = 0;              // Indicator On/Off Heigth Start
extern int        IndicatorOnX1          = 25;             // Indicator On/Off Button Heigth Finish
extern int        IndicatorOnY           = 100;            // Indicator On/Off Width Start
extern int        IndicatorOnY1          = 200;            // Indicator On/Off Button Width Finish


extern int        AlertsOnX              = 0;              // Alerts On/Off Heigth Start
extern int        AlertsOnX1             = 25;             // Alerts On/Off Button Heigth Finish
extern int        AlertsOnY              = 220;            // Alerts On/Off Button Width Start
extern int        AlertsOnY1             = 320;            // Alerts On/Off Button Width Finish

extern int        AlertsMessageX         = 35;             // Alerts Message On/Off Heigth Start
extern int        AlertsMessageX1        = 60;             // Alerts Message On/Off Button Heigth Finish
extern int        AlertsMessageY         = 100;            // Alerts Message On/Off Button Width Start
extern int        AlertsMessageY1        = 200;            // Alerts Message On/Off Button Width Finish

extern int        AlertsSoundX           = 35;             // Alerts Sound On/Off Heigth Start
extern int        AlertsSoundX1          = 60;             // Alerts Sound On/Off Button Heigth Finish
extern int        AlertsSoundY           = 220;            // Alerts Sound On/Off Button Width Start
extern int        AlertsSoundY1          = 320;            // Alerts Sound On/Off Button Width Finish

extern int        AlertsEmailX           = 35;             // Alerts Email On/Off Heigth Start
extern int        AlertsEmailX1          = 60;             // Alerts Email On/Off Button Heigth Finish
extern int        AlertsEmailY           = 340;            // Alerts Email On/Off Button Width Start
extern int        AlertsEmailY1          = 440;            // Alerts Email On/Off Button Width Finish



CButton indicator_on_button;
CButton alerts_on_button;
CButton alerts_message_button;
CButton alerts_sound_button;
CButton alerts_email_button;

string Indicator = "Indicator";
string Alerts = "Alerts";
string AlertsMessage = "Message";
string AlertsSound = "Sound";
string AlertsEmail = "Email";



string indicator_on_button_text = "indicator_on_button";
string alerts_on_button_text = "alerts_on_button";
string alerts_message_button_text = "alerts_message_button";
string alerts_sound_button_text = "alerts_sound_button";
string alerts_email_button_text = "alerts_email_button";

double b1[],b2[],b3[],b4[],b5[],b6[],b7[],b8[];
int    TimeFrame;
int    shift1=PeriodWeakChannel/2;
int    shift2=PeriodMainChannel/2;

//---------------------------

int init()
{

   indicator_on_button.Create(0,indicator_on_button_text,0,IndicatorOnY,IndicatorOnX,IndicatorOnY1,IndicatorOnX1);
   indicator_on_button.FontSize(12);
   indicator_on_button.Color(clrWhite);
   setButton(indicator_on_button, Indicator,enabledOn);
      
   alerts_on_button.Create(0,alerts_on_button_text,AlertsOnX,AlertsOnY,0,AlertsOnY1,AlertsOnX1);
   alerts_on_button.FontSize(12);
   alerts_on_button.Color(clrWhite);
   setButton(alerts_on_button, Alerts,alertsOn);   
   
   alerts_message_button.Create(0,alerts_message_button_text,0,AlertsMessageY,AlertsMessageX,AlertsMessageY1,AlertsMessageX1);
   alerts_message_button.FontSize(12);
   alerts_message_button.Color(clrWhite);
   setButton(alerts_message_button, AlertsMessage, alertsMessage);
   
   alerts_sound_button.Create(0,alerts_sound_button_text,0,AlertsSoundY,AlertsSoundX,AlertsSoundY1,AlertsSoundX1);
   alerts_sound_button.FontSize(12);
   alerts_sound_button.Color(clrWhite);
   setButton(alerts_sound_button, AlertsSound, alertsSound);
   
   alerts_email_button.Create(0,alerts_email_button_text,0,AlertsEmailY,AlertsEmailX,AlertsEmailY1,AlertsEmailX1);
   alerts_email_button.FontSize(12);
   alerts_email_button.Color(clrWhite);
   setButton(alerts_email_button, AlertsEmail, alertsEmail);   
   
   TimeFrame = MathMax(TimeFrame,_Period);
   IndicatorBuffers(8);
   SetIndexBuffer(0,b1); SetIndexStyle(0,DRAW_ARROW); SetIndexArrow(0,164);
   SetIndexBuffer(1,b2); SetIndexStyle(1,DRAW_ARROW); SetIndexArrow(1,164);
   SetIndexBuffer(2,b3); SetIndexStyle(2,DRAW_ARROW); SetIndexArrow(2,164);
   SetIndexBuffer(3,b4); SetIndexStyle(3,DRAW_ARROW); SetIndexArrow(3,164);
   SetIndexBuffer(4,b5); SetIndexLabel(4,"Upper weak channel");
   SetIndexBuffer(5,b6); SetIndexLabel(5,"Lower weak channel");
   SetIndexBuffer(6,b7); SetIndexLabel(6,"Upper Main channel");
   SetIndexBuffer(7,b8); SetIndexLabel(7,"Lower Main channel");
   IndicatorShortName(timeFrameToString(TimeFrame)+" Super-signals ("+PeriodWeakChannel+","+PeriodMainChannel+")");
   return(0);
}

//----------------------------

int temp_limit=0;
int start()
{
   if( IsVisualMode() )
   {
      long   lparam = 0;
      double dparam = 0.0;
      string sparam = "";  
      
      sparam = "indicator_on_button";
      if( bool( ObjectGetInteger( 0, sparam, OBJPROP_STATE ) ) )
        OnChartEvent( CHARTEVENT_OBJECT_CLICK, lparam, dparam, sparam );
        
      sparam = "alerts_on_button";
      if( bool( ObjectGetInteger( 0, sparam, OBJPROP_STATE ) ) )
        OnChartEvent( CHARTEVENT_OBJECT_CLICK, lparam, dparam, sparam );
        
      sparam = "alerts_message_button";
      if( bool( ObjectGetInteger( 0, sparam, OBJPROP_STATE ) ) )
        OnChartEvent( CHARTEVENT_OBJECT_CLICK, lparam, dparam, sparam );
        
      sparam = "alerts_sound_button";
      if( bool( ObjectGetInteger( 0, sparam, OBJPROP_STATE ) ) )
        OnChartEvent( CHARTEVENT_OBJECT_CLICK, lparam, dparam, sparam );
        
      sparam = "alerts_email_button";
      if( bool( ObjectGetInteger( 0, sparam, OBJPROP_STATE ) ) )
        OnChartEvent( CHARTEVENT_OBJECT_CLICK, lparam, dparam, sparam );
   }
   
   
   if(!enabledOn)
   {
   
      clear();
      return 0;
   }
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
           int limit=Bars-counted_bars;
           limit=MathMax(limit,PeriodMainChannel);
   temp_limit = limit;
   draw();
//-------------------------------------------------------------
 
   if (alertsOn)
      {
         if (b1[1] != EMPTY_VALUE && b3[1] != EMPTY_VALUE) doAlert(" @ MAIN channel");
         if (b2[1] != EMPTY_VALUE && b4[1] != EMPTY_VALUE) doAlert(" @ MAIN channel");
         if (b1[1] != EMPTY_VALUE && b3[1] == EMPTY_VALUE) doAlert(" @ WEAK channel");
         if (b2[1] != EMPTY_VALUE && b4[1] == EMPTY_VALUE) doAlert(" @ WEAK channel");
      }
   return(0);
}

void draw()
{
      for (int i=temp_limit;i>=0;i--)
      {
         int hhb1 = Highest(NULL,0,MODE_HIGH,PeriodWeakChannel,i);
         int llb1 = Lowest(NULL,0,MODE_LOW,PeriodWeakChannel,i);
         int hhb2 = Highest(NULL,0,MODE_HIGH,PeriodMainChannel,i);
         int llb2 = Lowest(NULL,0,MODE_LOW,PeriodMainChannel,i);

         b1[i] = EMPTY_VALUE;
         b2[i] = EMPTY_VALUE;
         b3[i] = EMPTY_VALUE;
         b4[i] = EMPTY_VALUE;
         b5[i] = High[hhb1];
         b6[i] = Low[llb1];
         b7[i] = High[hhb2];
         b8[i] = Low[llb2];
      
         if (i==hhb1) b1[i]=High[hhb1];
         if (i==llb1) b2[i]=Low[llb1];
         if (i==hhb2) b3[i]=High[hhb2];
         if (i==llb2) b4[i]=Low[llb2] ;
      }

}

//-------------------------------------------------------------------------------------

void doAlert(string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
      if (previousAlert != doWhat || previousTime != Time[0]) {
          previousAlert  = doWhat;
          previousTime   = Time[0];

          message = timeFrameToString(TimeFrame)+" Super-signals "+Symbol()+doWhat;
             if (alertsMessage) Alert(message);
             if (alertsEmail)   SendMail(StringConcatenate(Symbol(),"Super-signals "),message);
             if (alertsSound)   PlaySound(soundFile);
      }
}

//-------------------------------------------------------------------------------------

string sTfTable[] = {"M1","M2","M3","M5","M10","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,2,3,5,10,15,30,60,240,1440,10080,43200};

string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}

//------------------------------------------------------ -------------------------------





void OnChartEvent(const int id,         
                  const long& lparam,   
                  const double& dparam, 
                  const string& sparam)
{

   if(id == CHARTEVENT_OBJECT_CLICK)
   { 
      if (sparam == indicator_on_button_text) 
      {
         indicator_on_button.Pressed(false);
         enabledOn = !enabledOn;
         if(enabledOn) draw();
         else clear();
         setButton(indicator_on_button, Indicator,enabledOn);
      }
      
      if (sparam == alerts_on_button_text) 
      {
         alerts_on_button.Pressed(false);
         alertsOn = !alertsOn;
         setButton(alerts_on_button, Alerts,alertsOn);
      }
      
      
      if (sparam == alerts_sound_button_text) 
      {
         alerts_sound_button.Pressed(false);
         alertsSound = !alertsSound;
         setButton(alerts_sound_button, AlertsSound,alertsSound);
      }
      
      if (sparam == alerts_message_button_text) 
      {
         alerts_message_button.Pressed(false);
         alertsMessage = !alertsMessage;
         setButton(alerts_message_button, AlertsMessage,alertsMessage);
      }
      
      
      if (sparam == alerts_email_button_text) 
      {
         alerts_email_button.Pressed(false);
         alertsEmail = !alertsEmail;
         setButton(alerts_email_button, AlertsEmail,alertsEmail);
      }
    
   }

}

void setButton(CButton& button, string text, bool state = false)
{
   if(state)
   {      
      button.ColorBackground(clrRed);
      button.Text(text + " Off");
   }
   else
   {
      button.ColorBackground(clrGreen);
      button.Text(text + " On");
   }
   
}


void clear()
{
   

   for (int i=temp_limit;i>=0;i--)
      {       

         b1[i] = EMPTY_VALUE;
         b2[i] = EMPTY_VALUE;
         b3[i] = EMPTY_VALUE;
         b4[i] = EMPTY_VALUE;
         b5[i] = EMPTY_VALUE;
         b6[i] = EMPTY_VALUE;
         b7[i] = EMPTY_VALUE;
         b8[i] = EMPTY_VALUE;
      
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