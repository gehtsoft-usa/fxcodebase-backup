// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=73752

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
#define major   2
#define minor   0
//----
#property indicator_separate_window
#property indicator_buffers 7
#property indicator_color1 Black
#property indicator_color2 MediumBlue
#property indicator_color3 Yellow
#property indicator_width3 2
#property indicator_color4 MediumBlue
#property indicator_color5 Green
#property indicator_width5 2
#property indicator_color6 Red
#property indicator_color7 Aqua
#property indicator_style7 2
//----
extern string NoteGeneral=" --- General Options --- ";
extern bool Show_TrendVisuals=true;
extern bool Show_SignalArrows=true;
extern int SHIFT_Sideway=0;
extern int SHIFT_Up_Down=0;
//----
extern string NoteIndic=" --- Indicator Options --- ";
extern int RSI_Period=13;         //8-25
extern int RSI_Price=0;           //0-6
extern int Volatility_Band=34;    //20-40
extern int RSI_Price_Line=2;
extern int RSI_Price_Type=0;      //0-3
extern int Trade_Signal_Line=7;
extern bool SHOW_Trade_Signal_Line2=true;
extern int Trade_Signal_Line2=18;
extern int Trade_Signal_Type=0;   //0-3
//----
extern string NoteAlerts=" --- Alert Options --- ";
extern bool BuySellAlerts=true;
extern bool CautionAlerts=true;
extern bool MsgAlerts= true;
extern bool SoundAlerts= true;
extern string SoundAlertFile="alert.wav";
extern bool eMailAlerts= false;
//----
bool InitialLoad=True;
string prefix="TDIV_";
double RSIBuf[],UpZone[],MdZone[],DnZone[],MaBuf[],MbBuf[],McBuf[];
string Signal="", Signal2="", Signal3="",Signal4="";
color TDI_col,TDI_col2;
int LastAlert=0, LastAlertBar,SigCounter=0;
double BidCur;
datetime TimeCur;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorShortName("TDIVisual");
   SetIndexBuffer(0,RSIBuf);
   SetIndexBuffer(1,UpZone);
   SetIndexBuffer(2,MdZone);
   SetIndexBuffer(3,DnZone);
   SetIndexBuffer(4,MaBuf);
   SetIndexBuffer(5,MbBuf);
//----
   if(SHOW_Trade_Signal_Line2 ==true){SHOW_Trade_Signal_Line2=DRAW_LINE; }
   else {SHOW_Trade_Signal_Line2=DRAW_NONE; }
   SetIndexStyle(6,SHOW_Trade_Signal_Line2);
   SetIndexBuffer(6,McBuf);
   SetIndexStyle(0,DRAW_NONE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_LINE,0,2);
   SetIndexStyle(3,DRAW_LINE);
   SetIndexStyle(4,DRAW_LINE,0,2);
   SetIndexStyle(5,DRAW_LINE,0,1);
//----
   SetIndexLabel(0,NULL);
   SetIndexLabel(1,"VB High");
   SetIndexLabel(2,"Market Base Line");
   SetIndexLabel(3,"VB Low");
   SetIndexLabel(4,"RSI Price Line");
   SetIndexLabel(5,"Trade Signal Line");
   SetIndexLabel(6,"Trade Signal2 Line");
   LastAlertBar=Bars-1;
//----
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
  {
   int total=ObjectsTotal();
   for(int i=total-1; i>=0; i--)
     {
      string name=ObjectName(i);
      if (StringFind(name, prefix)==0) ObjectDelete(name);
     }
//----   
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   int Win=WindowFind("TDIVisual");
   if (Win==- 1) Win=0;
//----
   double MA,RSI[];
   ArrayResize(RSI,Volatility_Band);
   int counted_bars = IndicatorCounted();
   if(counted_bars < 0)  return(-1);
   if(counted_bars > 0)   counted_bars--;
   int limit = Bars - counted_bars;
   if(counted_bars==0) limit-=1+Volatility_Band;
//----
   for(int i=limit; i>=0; i--)
     {
      RSIBuf[i]=(iRSI(NULL,0,RSI_Period,RSI_Price,i));
      MA=0;
      for(int x=i; x<i+Volatility_Band; x++)
        {
         RSI[x-i]=RSIBuf[x];
         MA+=RSIBuf[x]/Volatility_Band;
        }
      UpZone[i]=(MA + (1.6185 * StDev(RSI,Volatility_Band)));
      DnZone[i]=(MA - (1.6185 * StDev(RSI,Volatility_Band)));
      MdZone[i]=((UpZone[i] + DnZone[i])/2);
     }
   for(i=limit-1;i>=0;i--)
     {
      MaBuf[i]=(iMAOnArray(RSIBuf,0,RSI_Price_Line,0,RSI_Price_Type,i));
      MbBuf[i]=(iMAOnArray(RSIBuf,0,Trade_Signal_Line,0,Trade_Signal_Type,i));
      McBuf[i]=(iMAOnArray(RSIBuf,0,Trade_Signal_Line2,0,Trade_Signal_Type,i));
      BidCur=Close[i]; //Could use bid however no good when using visual back tester
      TimeCur=Time[i];
      if(Show_TrendVisuals)
        {
         //signals
         if((MaBuf[i]>MbBuf[i])&&(MbBuf[i]<MdZone[i])&&(MaBuf[i]< MdZone[i])&&(MaBuf[i]>32)&&(MaBuf[i]<68))
           {
            Signal2="Weak Buy";
            Signal="é";
            TDI_col=SeaGreen;
           }
         else if((MaBuf[i]<MbBuf[i])&&(MbBuf[i]> MdZone[i])&&(MaBuf[i]> MdZone[i])&&(MaBuf[i]>32)&&(MaBuf[i]<68))
              {
               Signal2="Weak Sell";
               Signal="ê";
               TDI_col=Orange;
              }
            else if((MaBuf[i]>MbBuf[i])&&(MbBuf[i]> MdZone[i])&&(MaBuf[i]>32)&&(MaBuf[i]<68))
                 {
                  Signal2="Strong Buy";
                  Signal="é";
                  TDI_col=Lime;
                 }
               else if((MaBuf[i]>MbBuf[i])&&(MaBuf[i]> MdZone[i])&&(MbBuf[i]< MdZone[i])&&(MaBuf[i]>32)&&(MaBuf[i]<68))
                    {
                     Signal2="Medium Buy";
                     Signal="é";
                     TDI_col=Green;
                    }
                  else if((MaBuf[i]<MbBuf[i])&&(MbBuf[i]< MdZone[i])&&(MaBuf[i]>32)&&(MaBuf[i]<68))
                       {
                        Signal2="Strong Sell";
                        Signal="ê";
                        TDI_col=Red;
                       }
                     else if((MaBuf[i]<MbBuf[i])&&(MaBuf[i]< MdZone[i])&&(MbBuf[i]> MdZone[i])&&(MaBuf[i]>32)&&(MaBuf[i]<68))
                          {
                           Signal2="Medium Sell";
                           Signal="ê";
                           TDI_col=Tomato;
                          }
         // reversals
                        else if(MaBuf[i]>=68)
                             {
                              Signal2="Caution !";
                              Signal="ê";
                              TDI_col=Red;
                             }
                           else if(MaBuf[i]<=32)
                                {
                                 Signal2="Caution !";
                                 Signal="é";
                                 TDI_col=Red;
                                }
         //TDI - Trend Signals     
         if((MbBuf[i]>MdZone[i])&&(MaBuf[i]<MdZone[i]))
           {
            Signal4= "Weak Up";
            Signal3="é";
            TDI_col2=Green;
           }
         else if (MbBuf[i]>MdZone[i])
              {
               Signal4= "Strong UP";
               Signal3="é";
               TDI_col2=Lime;
              }
         if((MbBuf[i]<=MdZone[i])&&(MaBuf[i]>=MdZone[i]))
           {
            Signal4= "Weak Down";
            Signal3="é";
            TDI_col2=Orange;
           }
         else if (MbBuf[i]<=MdZone[i])
              {
               Signal4= "Strong Down";
               Signal3="ê";
               TDI_col2=Red;
              }
         //ranging
         if(UpZone[i]-DnZone[i]<20)
           {
            Signal4="Consolidation";
            Signal3="h";
            TDI_col2=Silver;
           }
         string Subj=Symbol()+ ", " + TF2Str(Period()) + " " + Signal2;
         string Msg;
         //ALERTS
         if (Signal2=="Strong Buy" && Signal4=="Strong UP" && LastAlert!=1)
           {
            Msg=Subj + " @ "+DoubleToStr(Close[i],Digits) + ", @ " + TimeToStr(TimeLocal(),TIME_SECONDS);
            if (Bars>LastAlertBar)
              {
               LastAlertBar=Bars;
               if (BuySellAlerts) DoAlerts(Msg,Subj);
              }
            LastAlert=1; //Last trend Alert was Up Trend Buy Alert
//----
            if (Show_SignalArrows)
              {
               CreateText(prefix+"En"+SigCounter,0," B",10,"Arial Bold",Lime,Time[i],Low[i]-SignalArrowSpacer(),false);
               SigCounter++;
              }
            //Print("Text: " + TimeToStr(Time[i],TIME_MINUTES) + ", High: " + High[i]);
           }
         else if  (Signal2=="Strong Sell" && Signal4=="Strong Down" && LastAlert!=2)
              {
               Msg=Subj + " @ "+DoubleToStr(Close[i],Digits) + ", @ " + TimeToStr(TimeLocal(),TIME_SECONDS);
               if (Bars>LastAlertBar)
                 {
                  LastAlertBar=Bars;
                  if(BuySellAlerts) DoAlerts(Msg,Subj);
                 }
               LastAlert=2; //Last trend Alert was Down Trend Buy Alert
               if (Show_SignalArrows)
                 {
                  CreateText(prefix+"En"+SigCounter,0," S",10,"Arial Bold",Red,Time[i],High[i]+SignalArrowSpacer(),false);
                  SigCounter++;
                 }
               //Print("Text: " + TimeToStr(Time[i],TIME_MINUTES) + ", High: " + High[i]);
              }
            else if ((LastAlert==1 || LastAlert==2) && Signal2=="Caution !")
                 {
                  Subj=Symbol()+ ", " + TF2Str(Period()) + ". Trend Caution Alert!";
                  if (LastAlert==2) Subj=Symbol()+ ", " + TF2Str(Period()) + ". Trend Caution Alert!";
//----
                  Msg=Subj + " @ "+DoubleToStr(Close[i],Digits) + ", @ " + TimeToStr(TimeLocal(),TIME_SECONDS);
                  if (Bars>LastAlertBar)
                    {
                     LastAlertBar=Bars;
                     if (CautionAlerts) DoAlerts(Msg,Subj);
                    }
                  if (Show_SignalArrows)
                    {
                     if (LastAlert==1)
                       {
                        CreateText(prefix+"En"+SigCounter,0,"*",25,"Arial Bold",Gold,Time[i],High[i]+SignalArrowSpacer(),false);
                        SigCounter++;
                       }
                     else
                       {
                        CreateText(prefix+"En"+SigCounter,0,"*",25,"Arial Bold",Gold,Time[i],Low[i]-SignalArrowSpacer(),false);
                        SigCounter++;
                       }
                    }
                  LastAlert=3; //Last trend Alert was Down Trend Buy Alert
                 } // End Alerts
        }//End If Show Trend Visuals  
     } //End For Loop 
   if(Show_TrendVisuals)
     {
      for(i=1;i<=12;i++) //Create the Visuals
        {
         switch(i)
           {
            case 1 : CreateLabel(prefix+"SIG"+i,Win,Signal,25,"Wingdings",TDI_col,1,80+SHIFT_Sideway,20+SHIFT_Up_Down); break;
            case 2 : CreateLabel(prefix+"SIG"+i,Win," @ "+DoubleToStr(BidCur,Digits),13,"Tahoma Narrow",TDI_col,1,125+SHIFT_Sideway,32+SHIFT_Up_Down); break;
            case 3 : CreateLabel(prefix+"SIG"+i,Win,Signal2,15,"Tahoma Narrow",TDI_col,1,120+SHIFT_Sideway,10+SHIFT_Up_Down); break;
            case 4 : CreateLabel(prefix+"SIG"+i,Win,"TDI Trend",15,"Tahoma Narrow",TDI_col2,1,120+SHIFT_Sideway,60+SHIFT_Up_Down); break;
            case 5 : CreateLabel(prefix+"SIG"+i,Win,Signal3,25,"Wingdings",TDI_col2,1,80+SHIFT_Sideway,60+SHIFT_Up_Down); break;
            case 6 : CreateLabel(prefix+"SIG"+i,Win,Signal4,15,"Tahoma Narrow",TDI_col2,1,115+SHIFT_Sideway,82+SHIFT_Up_Down); break;
            case 7 : CreateText(prefix+"SIG"+i,Win,"          68 ",7,"Tahoma Narrow",CadetBlue,TimeCur,70,true); break;
            case 8 : CreateText(prefix+"SIG"+i,Win,"          50 ",7,"Tahoma Narrow",CadetBlue,TimeCur,52,true); break;
            case 9 : CreateText(prefix+"SIG"+i,Win,"          32 ",7,"Tahoma Narrow",CadetBlue,TimeCur,34,true); break;
            case 10: Createline(prefix+"UPPERLINE", Win, 68, 68,DarkSlateGray); break;
            case 11: Createline(prefix+"LOWERLINE", Win, 50, 50,DarkSlateGray); break;
            case 12: Createline(prefix+"MEDLINE", Win, 32, 32,DarkSlateGray); break;
           }
        }
     }//End if(Show_TrendVisuals)
   //If the indicator has just been loaded force a redraw as the Visual labels
   //don't update properly until the first tick after loading.   
   if (InitialLoad)
     {
      InitialLoad=false;
      if (Show_TrendVisuals) WindowRedraw();
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Createline(string objName, int Window, double start, double end, color clr)
  {
   ObjectDelete(objName);
   ObjectCreate(objName, OBJ_TREND,Window,0, start, Time[0], end);
   ObjectSet(objName, OBJPROP_COLOR, clr);
   ObjectSet(objName, OBJPROP_STYLE, 2);
   ObjectSet(objName, OBJPROP_RAY, false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateLabel(string LblName, int Window, string LblTxt, int FontSz, string FontName, color FontColor, int Corner, int xPos, int yPos)
  {
   if(ObjectFind(LblName)!=0) ObjectCreate(LblName, OBJ_LABEL, Window, 0, 0);
   ObjectSetText(LblName, LblTxt, FontSz, FontName, FontColor);
   ObjectSet(LblName, OBJPROP_CORNER, Corner);
   ObjectSet(LblName, OBJPROP_XDISTANCE, xPos);
   ObjectSet(LblName, OBJPROP_YDISTANCE, yPos);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CreateText(string TextName, int Window, string LabelText, int FontSz, string FontName, color TextColor, datetime Time1, double Price1, bool delete_flag)
  {
   if (delete_flag) ObjectDelete(TextName);
   if(ObjectFind(TextName)!=0)
     {
      ObjectCreate(TextName, OBJ_TEXT, Window, Time1, Price1);
      ObjectSetText(TextName, LabelText, FontSz, FontName, TextColor);
     }
   else
      ObjectMove(TextName, 0, Time1, Price1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double StDev(double& Data[], int Per)
  {
   return(MathSqrt(Variance(Data,Per)));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Variance(double& Data[], int Per)
  {
   double sum, ssum;
   for(int i=0; i<Per; i++)
     {
      sum+=Data[i];
      ssum+=MathPow(Data[i],2);
     }
   return((ssum*Per - sum*sum)/(Per*(Per-1)));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string TF2Str(int period)
  {
   switch(period)
     {
      case PERIOD_M1: return("M1");
      case PERIOD_M5: return("M5");
      case PERIOD_M15: return("M15");
      case PERIOD_M30: return("M30");
      case PERIOD_H1: return("H1");
      case PERIOD_H4: return("H4");
      case PERIOD_D1: return("D1");
      case PERIOD_W1: return("W1");
      case PERIOD_MN1: return("MN");
     }
   return(Period());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DoAlerts(string msgText,string eMailSub)
  {
   if (MsgAlerts) Alert(msgText);
   if (SoundAlerts)  PlaySound(SoundAlertFile);
   if (eMailAlerts) SendMail(eMailSub, msgText);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double SignalArrowSpacer()
  {
   switch(Period())
     {
      case PERIOD_M1: return(5*Point); break;
      case PERIOD_M5: return(10*Point); break;
      case PERIOD_M15: return(15*Point); break;
      case PERIOD_M30: return(20*Point); break;
      case PERIOD_H1: return(15*Point); break;
      case PERIOD_H4: return(40*Point); break;
      case PERIOD_D1: return(80*Point); break;
      case PERIOD_W1: return(150*Point); break;
      case PERIOD_MN1: return(200*Point); break;
     }
  }
//+------------------------------------------------------------------+


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