//+------------------------------------------------------------------+
//|                                      FractalsMarketStructure.mq5 |
//|                                         Copyright 2024, rpanchyk |
//|                                      https://github.com/rpanchyk |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2024, rpanchyk"
#property link        "https://github.com/rpanchyk"
#property version     "1.00"
#property description "Indicator shows market structure based on fractals"

#property indicator_chart_window
#property indicator_plots 2
#property indicator_buffers 2

// types
enum ENUM_ARROW_SIZE
  {
   SMALL_ARROW_SIZE = 1, // Small
   REGULAR_ARROW_SIZE = 2, // Regular
   BIG_ARROW_SIZE = 3, // Big
   HUGE_ARROW_SIZE = 4 // Huge
  };

// buffers
double ExtHighPriceBuffer[]; // Higher price
double ExtLowPriceBuffer[]; // Lower price

// config
input group "Section :: Main";
input int InpPeriod = 10; // Period

input group "Section :: Style";
input int InpArrowShift = 10; // Arrow shift
input ENUM_ARROW_SIZE InpArrowSize = REGULAR_ARROW_SIZE; // Arrow size
input color InpHigherHighColor = clrGreen; // Higher high color
input color InpLowerLowColor = clrRed; // Lower low color

input group "Section :: Dev";
input bool InpDebugEnabled = false; // Enable debug (verbose logging)

// runtime
int highIdx;
int lowIdx;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(InpDebugEnabled)
     {
      Print("FractalsMarketStructure indicator initialization started");
     }

   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);

   ArrayInitialize(ExtHighPriceBuffer, EMPTY_VALUE);
   SetIndexBuffer(0, ExtHighPriceBuffer, INDICATOR_DATA);
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetString(0, PLOT_LABEL, "High");
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_ARROW);
   PlotIndexSetInteger(0, PLOT_ARROW, 159);
   PlotIndexSetInteger(0, PLOT_ARROW_SHIFT, -InpArrowShift);
   PlotIndexSetInteger(0, PLOT_LINE_WIDTH, InpArrowSize);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, InpHigherHighColor);

   ArrayInitialize(ExtLowPriceBuffer, EMPTY_VALUE);
   SetIndexBuffer(1, ExtLowPriceBuffer, INDICATOR_DATA);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, EMPTY_VALUE);
   PlotIndexSetString(1, PLOT_LABEL, "Low");
   PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_ARROW);
   PlotIndexSetInteger(1, PLOT_ARROW, 159);
   PlotIndexSetInteger(1, PLOT_ARROW_SHIFT, InpArrowShift);
   PlotIndexSetInteger(1, PLOT_LINE_WIDTH, InpArrowSize);
   PlotIndexSetInteger(1, PLOT_LINE_COLOR, InpLowerLowColor);

   highIdx = 0;
   lowIdx = 0;

   if(InpDebugEnabled)
     {
      Print("FractalsMarketStructure indicator initialization finished");
     }
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(InpDebugEnabled)
     {
      Print("FractalsMarketStructure indicator deinitialization started");
     }

   ArrayFill(ExtHighPriceBuffer, 0, ArraySize(ExtHighPriceBuffer), EMPTY_VALUE);
   ArrayResize(ExtHighPriceBuffer, 0);
   ArrayFree(ExtHighPriceBuffer);

   ArrayFill(ExtLowPriceBuffer, 0, ArraySize(ExtLowPriceBuffer), EMPTY_VALUE);
   ArrayResize(ExtLowPriceBuffer, 0);
   ArrayFree(ExtLowPriceBuffer);

   if(InpDebugEnabled)
     {
      Print("FractalsMarketStructure indicator deinitialization finished");
     }
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
   if(rates_total == prev_calculated)
     {
      return rates_total;
     }

   if(InpDebugEnabled)
     {
      PrintFormat("RatesTotal: %i, PrevCalculated: %i, HighIndex: %i, LowIndex: %i", rates_total, prev_calculated, highIdx, lowIdx);
     }

   for(int i = (prev_calculated == 0 ? 1 : prev_calculated) - 1; i < rates_total; i++)
     {
      if(high[i] > high[highIdx])
        {
         SetHigh(time, high, low, i);
        }
      if(low[i] < low[lowIdx])
        {
         SetLow(time, high, low, i);
        }
     }

   return rates_total;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetHigh(const datetime &time[], const double &high[], const double &low[], int i)
  {
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SetLow(const datetime &time[], const double &high[], const double &low[], int i)
  {
  }
//+------------------------------------------------------------------+
