//+------------------------------------------------------------+
//| Float.mq5                                                  |
//| Copyright © 2005  Barry Stander  Barry_Stander_4@yahoo.com |
//| http://www.4Africa.net/4meta/                              |
//| Float                                                      |
//| Copyright © 2025       Andriy Moraru  www.EarnForex.com    |
//| https://www.earnforex.com/                                 |
//+------------------------------------------------------------+
#property copyright "Copyright © 2025, EarnForex"
#property link      "https://www.earnforex.com/metatrader-indicators/Float/"
#property version   "1.03"

#property description "Float - Trend strength, volume, Fibonacci and Dinapoli levels."

#property indicator_separate_window
#property indicator_buffers 31
#property indicator_plots   31

#property indicator_color1  clrBlue
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_width1  1
#property indicator_label1 "Float Histogram"
#property indicator_color2  clrRed
#property indicator_type2   DRAW_LINE
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
#property indicator_label2 "Float Line"
#property indicator_type3  DRAW_NONE // Swing Top (price)
#property indicator_type4  DRAW_NONE // Swing Bottom (price)
#property indicator_type5  DRAW_NONE // High Distance (bars)
#property indicator_type6  DRAW_NONE // Low Distance (bars)
#property indicator_type7  DRAW_NONE // Swing Time (bars)
#property indicator_type8  DRAW_NONE // Float Volume (volume)
#property indicator_type9  DRAW_NONE // Float Left (volume)
#property indicator_type10 DRAW_NONE // Fibo23 (price)
#property indicator_type11 DRAW_NONE // Fibo38 (price)
#property indicator_type12 DRAW_NONE // Fibo50 (price)
#property indicator_type13 DRAW_NONE // Fibo62 (price)
#property indicator_type14 DRAW_NONE // Fibo76 (price)
#property indicator_type15 DRAW_NONE // Dinap0 (price)
#property indicator_type16 DRAW_NONE // Dinap1 (price)
#property indicator_type17 DRAW_NONE // Dinap2 (price)
#property indicator_type18 DRAW_NONE // Dinap3 (price)
#property indicator_type19 DRAW_NONE // Dinap4 (price)
#property indicator_type20 DRAW_NONE // Dinap5 (price)
#property indicator_type21 DRAW_NONE // CVSTART (datetime)
#property indicator_type22 DRAW_NONE // CVEND (datetime)
#property indicator_type23 DRAW_NONE // SwingEnd1 (datetime)
#property indicator_type24 DRAW_NONE // SwingEnd2 (datetime)
#property indicator_type25 DRAW_NONE // SwingEnd3 (datetime)
#property indicator_type26 DRAW_NONE // SwingEnd4 (datetime)
#property indicator_type27 DRAW_NONE // SwingEnd5 (datetime)
#property indicator_type28 DRAW_NONE // SwingEnd6 (datetime)
#property indicator_type29 DRAW_NONE // SwingEnd7 (datetime)
#property indicator_type30 DRAW_NONE // SwingEnd8 (datetime)
#property indicator_type31 DRAW_NONE // SwingEnd9 (datetime)

input int             Float = 200;
input string          ObjectPrefix = "FI-";
input bool            DisableDinapoli = false;
input bool            DisableFibonacci = false;
input bool            DrawVerticalLinesAsBackground = false;
input color           SwingBorderColor = clrBlue;
input int             SwingBorderWidth = 1;
input ENUM_LINE_STYLE SwingBorderStyle = STYLE_SOLID;
input color           SwingLinesColor = clrRed;
input int             SwingLinesWidth = 1;
input ENUM_LINE_STYLE SwingLinesStyle = STYLE_DOT;
input color           FiboColor = clrGreen;
input int             FiboWidth = 1;
input ENUM_LINE_STYLE FiboStyle = STYLE_DASH;
input color           DinapoliColor = clrRed;
input int             DinapoliWidth = 1;
input ENUM_LINE_STYLE DinapoliStyle = STYLE_DOT;

datetime PrevTime;
double Histogram[];
double Line[];

double bufSwingTop[], bufSwingBottom[];
double bufHighDistance[], bufLowDistance[], bufSwingTime[], bufFloatVolume[], bufFloatLeft[]; // int actually.

double bufFibo23[], bufFibo38[], bufFibo50[], bufFibo62[], bufFibo76[];
double bufDinap0[], bufDinap1[], bufDinap2[], bufDinap3[], bufDinap4[], bufDinap5[];

double bufCVSTART[], bufCVEND[], bufSwingEnd1[], bufSwingEnd2[], bufSwingEnd3[], bufSwingEnd4[], bufSwingEnd5[], bufSwingEnd6[], bufSwingEnd7[], bufSwingEnd8[], bufSwingEnd9[]; // datetime actually.

void OnInit()
{
    IndicatorSetString(INDICATOR_SHORTNAME, "Float");

    SetIndexBuffer(0, Histogram, INDICATOR_DATA);
    SetIndexBuffer(1, Line, INDICATOR_DATA);

    SetIndexBuffer(2, bufSwingTop, INDICATOR_DATA);
    SetIndexBuffer(3, bufSwingBottom, INDICATOR_DATA);
    SetIndexBuffer(4, bufHighDistance, INDICATOR_DATA);
    SetIndexBuffer(5, bufLowDistance, INDICATOR_DATA);
    SetIndexBuffer(6, bufSwingTime, INDICATOR_DATA);
    SetIndexBuffer(7, bufFloatVolume, INDICATOR_DATA);
    SetIndexBuffer(8, bufFloatLeft, INDICATOR_DATA);
    SetIndexBuffer(9, bufFibo23, INDICATOR_DATA);
    SetIndexBuffer(10, bufFibo38, INDICATOR_DATA);
    SetIndexBuffer(11, bufFibo50, INDICATOR_DATA);
    SetIndexBuffer(12, bufFibo62, INDICATOR_DATA);
    SetIndexBuffer(13, bufFibo76, INDICATOR_DATA);
    SetIndexBuffer(14, bufDinap0, INDICATOR_DATA);
    SetIndexBuffer(15, bufDinap1, INDICATOR_DATA);
    SetIndexBuffer(16, bufDinap2, INDICATOR_DATA);
    SetIndexBuffer(17, bufDinap3, INDICATOR_DATA);
    SetIndexBuffer(18, bufDinap4, INDICATOR_DATA);
    SetIndexBuffer(19, bufDinap5, INDICATOR_DATA);
    SetIndexBuffer(20, bufCVSTART, INDICATOR_DATA);
    SetIndexBuffer(21, bufCVEND, INDICATOR_DATA);
    SetIndexBuffer(22, bufSwingEnd1, INDICATOR_DATA);
    SetIndexBuffer(23, bufSwingEnd2, INDICATOR_DATA);
    SetIndexBuffer(24, bufSwingEnd3, INDICATOR_DATA);
    SetIndexBuffer(25, bufSwingEnd4, INDICATOR_DATA);
    SetIndexBuffer(26, bufSwingEnd5, INDICATOR_DATA);
    SetIndexBuffer(27, bufSwingEnd6, INDICATOR_DATA);
    SetIndexBuffer(28, bufSwingEnd7, INDICATOR_DATA);
    SetIndexBuffer(29, bufSwingEnd8, INDICATOR_DATA);
    SetIndexBuffer(30, bufSwingEnd9, INDICATOR_DATA);

    ArraySetAsSeries(Histogram, true);
    ArraySetAsSeries(Line, true);
    ArraySetAsSeries(bufSwingTop, true);
    ArraySetAsSeries(bufSwingBottom, true);
    ArraySetAsSeries(bufHighDistance, true);
    ArraySetAsSeries(bufLowDistance, true);
    ArraySetAsSeries(bufSwingTime, true);
    ArraySetAsSeries(bufFloatVolume, true);
    ArraySetAsSeries(bufFloatLeft, true);
    ArraySetAsSeries(bufFibo23, true);
    ArraySetAsSeries(bufFibo38, true);
    ArraySetAsSeries(bufFibo50, true);
    ArraySetAsSeries(bufFibo62, true);
    ArraySetAsSeries(bufFibo76, true);
    ArraySetAsSeries(bufDinap0, true);
    ArraySetAsSeries(bufDinap1, true);
    ArraySetAsSeries(bufDinap2, true);
    ArraySetAsSeries(bufDinap3, true);
    ArraySetAsSeries(bufDinap4, true);
    ArraySetAsSeries(bufDinap5, true);
    ArraySetAsSeries(bufCVSTART, true);
    ArraySetAsSeries(bufCVEND, true);
    ArraySetAsSeries(bufSwingEnd1, true);
    ArraySetAsSeries(bufSwingEnd2, true);
    ArraySetAsSeries(bufSwingEnd3, true);
    ArraySetAsSeries(bufSwingEnd4, true);
    ArraySetAsSeries(bufSwingEnd5, true);
    ArraySetAsSeries(bufSwingEnd6, true);
    ArraySetAsSeries(bufSwingEnd7, true);
    ArraySetAsSeries(bufSwingEnd8, true);
    ArraySetAsSeries(bufSwingEnd9, true);

    PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, Float * 2);
    PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, Float * 2);
    
    PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, 0);
    PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, 0);
}

void OnDeinit(const int reason)
{
    ObjectsDeleteAll(ChartID(), ObjectPrefix);
    Comment("");
}

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &Time[],
                const double &open[],
                const double &High[],
                const double &Low[],
                const double &close[],
                const long &Volume[],
                const long &real_volume[],
                const int &spread[])
{
    ArraySetAsSeries(High, true);
    ArraySetAsSeries(Low, true);
    ArraySetAsSeries(Volume, true);
    ArraySetAsSeries(Time, true);

    if (Time[0] == PrevTime) return rates_total; // Recalculate only on new bars.
    PrevTime = Time[0];

    bool first = true;
    long cumulativeV = 0;
    double FLOATV = 0, high_bar = 0, low_bar = 0;
    int bars_high = 0, bars_low = 0, shift, swing_time = 0, cvstart = 0, cvend = 0;

    int loopbegin1 = rates_total - Float;
    // Find bar counts.
    bars_high = iHighest(Symbol(), Period(), MODE_HIGH, Float, 1);
    bars_low = iLowest(Symbol(), Period(), MODE_LOW, Float, 1);

    // Find the high and low values over the period.
    high_bar = High[bars_high];
    low_bar  =  Low[bars_low];

    // Find cumulative volume for float period.
    if (bars_high < bars_low) // Uptrend.
    {
        cvstart = bars_low;
        cvend = bars_high;
    }
    else // Downtrend.
    {
        cvstart = bars_high;
        cvend = bars_low;
    }

    if ((first) && (FLOATV == 0))
    {
        for (shift = cvstart; shift >= cvend; shift--)
        {
            FLOATV += (double)Volume[shift];
            first = false;
        }
    }

    // Find float time barcount.
    swing_time = MathAbs(bars_low - bars_high);

    // Initialize historic values.
    if (prev_calculated == 0)
    {
        for (int i = cvstart; i < rates_total; i++)
        {
            Histogram[i] = 0;
            Line[i] = 0;
        }
    }

    // Find cumulative volume since last turnover.
    for (shift = cvstart; shift >= 0; shift--)
    {
        cumulativeV += Volume[shift];

        if (cumulativeV >= FLOATV) cumulativeV = 0;

        Histogram[shift] = cumulativeV * 0.001; // Blue histogram.
        Line[shift] = FLOATV * 0.001; // Red line.
    }

    bufSwingTop[0] = high_bar;
    bufSwingBottom[0] = low_bar;

    Comment(
        "\n", "High was   ", bars_high, "  bars ago",
        "\n", "Low was    ", bars_low, " bars ago", "\n",
        "\n", "Float time was    = ", swing_time, " bars",
        "\n", "Float volume left = ", FLOATV - cumulativeV,
        "\n", "Float volume      = ", FLOATV);

    bufHighDistance[0] = bars_high;
    bufLowDistance[0] = bars_low;
    bufSwingTime[0] = swing_time;
    bufFloatVolume[0] = FLOATV - cumulativeV;
    bufFloatLeft[0] = FLOATV;

    ObjectDelete(0, ObjectPrefix + "Swingtop");
    ObjectCreate(0, ObjectPrefix + "Swingtop", OBJ_TREND, 0, Time[cvstart], high_bar, Time[1], high_bar);
    ObjectSetInteger(0, ObjectPrefix + "Swingtop", OBJPROP_STYLE, SwingBorderStyle);
    ObjectSetInteger(0, ObjectPrefix + "Swingtop", OBJPROP_COLOR, SwingBorderColor);
    ObjectSetInteger(0, ObjectPrefix + "Swingtop", OBJPROP_RAY_LEFT, 0);
    ObjectSetInteger(0, ObjectPrefix + "Swingtop", OBJPROP_WIDTH, SwingBorderWidth);

    ObjectDelete(0, ObjectPrefix + "Swingbottom");
    ObjectCreate(0, ObjectPrefix + "Swingbottom", OBJ_TREND, 0, Time[cvstart], low_bar, Time[1], low_bar);
    ObjectSetInteger(0, ObjectPrefix + "Swingbottom", OBJPROP_STYLE, SwingBorderStyle);
    ObjectSetInteger(0, ObjectPrefix + "Swingbottom", OBJPROP_COLOR, SwingBorderColor);
    ObjectSetInteger(0, ObjectPrefix + "Swingbottom", OBJPROP_RAY_LEFT, 0);
    ObjectSetInteger(0, ObjectPrefix + "Swingbottom", OBJPROP_WIDTH, SwingBorderWidth);

    if ((!DisableDinapoli) || (!DisableFibonacci))
    {
        // Fibonacci.
        ObjectDelete(0, ObjectPrefix + "Fib23");
        ObjectDelete(0, ObjectPrefix + "Fib38");
        ObjectDelete(0, ObjectPrefix + "Fib50");
        ObjectDelete(0, ObjectPrefix + "Fib62");
        ObjectDelete(0, ObjectPrefix + "Fib76");

        ObjectDelete(0, ObjectPrefix + "Dinap0");
        ObjectDelete(0, ObjectPrefix + "Dinap1");
        ObjectDelete(0, ObjectPrefix + "Dinap2");
        ObjectDelete(0, ObjectPrefix + "Dinap3");
        ObjectDelete(0, ObjectPrefix + "Dinap4");
        ObjectDelete(0, ObjectPrefix + "Dinap5");

        double Fib23 = ((high_bar - low_bar) * 0.236) + low_bar;
        double Fib38 = ((high_bar - low_bar) * 0.382) + low_bar;
        double Fib50 = ((high_bar - low_bar) / 2) + low_bar;
        double Fib62 = ((high_bar - low_bar) * 0.618) + low_bar;
        double Fib76 = ((high_bar - low_bar) * 0.764) + low_bar;
        bufFibo23[0] = Fib23;
        bufFibo38[0] = Fib38;
        bufFibo50[0] = Fib50;
        bufFibo62[0] = Fib62;
        bufFibo76[0] = Fib76;

        if (!DisableFibonacci)
        {
            ObjectCreate(0, ObjectPrefix + "Fib23", OBJ_TREND, 0, Time[cvstart], Fib23, Time[1], Fib23);
            ObjectSetInteger(0, ObjectPrefix + "Fib23", OBJPROP_STYLE, FiboStyle);
            ObjectSetInteger(0, ObjectPrefix + "Fib23", OBJPROP_COLOR, FiboColor);
            ObjectSetInteger(0, ObjectPrefix + "Fib23", OBJPROP_RAY_LEFT, 0);
            ObjectSetInteger(0, ObjectPrefix + "Fib23", OBJPROP_WIDTH, FiboWidth);
            ObjectCreate(0, ObjectPrefix + "Fib23t", OBJ_TEXT, 0, Time[1], Fib23);
            ObjectSetString(0, ObjectPrefix + "Fib23t", OBJPROP_TEXT, "23.6");
            ObjectSetInteger(0, ObjectPrefix + "Fib23t", OBJPROP_FONTSIZE, 8);
            ObjectSetString(0, ObjectPrefix + "Fib23t", OBJPROP_FONT, "Arial");
            ObjectSetInteger(0, ObjectPrefix + "Fib23t", OBJPROP_COLOR, FiboColor);
    
            ObjectCreate(0, ObjectPrefix + "Fib38", OBJ_TREND, 0, Time[cvstart], Fib38, Time[1], Fib38);
            ObjectSetInteger(0, ObjectPrefix + "Fib38", OBJPROP_STYLE, FiboStyle);
            ObjectSetInteger(0, ObjectPrefix + "Fib38", OBJPROP_COLOR, FiboColor);
            ObjectSetInteger(0, ObjectPrefix + "Fib38", OBJPROP_RAY_LEFT, 0);
            ObjectSetInteger(0, ObjectPrefix + "Fib38", OBJPROP_WIDTH, FiboWidth);
            ObjectCreate(0, ObjectPrefix + "Fib38t", OBJ_TEXT, 0, Time[1], Fib38);
            ObjectSetString(0, ObjectPrefix + "Fib38t", OBJPROP_TEXT, "38.2");
            ObjectSetInteger(0, ObjectPrefix + "Fib38t", OBJPROP_FONTSIZE, 8);
            ObjectSetString(0, ObjectPrefix + "Fib38t", OBJPROP_FONT, "Arial");
            ObjectSetInteger(0, ObjectPrefix + "Fib38t", OBJPROP_COLOR, FiboColor);
            
            ObjectCreate(0, ObjectPrefix + "Fib50", OBJ_TREND, 0, Time[cvstart], Fib50, Time[1], Fib50);
            ObjectSetInteger(0, ObjectPrefix + "Fib50", OBJPROP_STYLE, STYLE_SOLID);
            ObjectSetInteger(0, ObjectPrefix + "Fib50", OBJPROP_COLOR, FiboColor);
            ObjectSetInteger(0, ObjectPrefix + "Fib50", OBJPROP_RAY_LEFT, 0);
            ObjectSetInteger(0, ObjectPrefix + "Fib50", OBJPROP_WIDTH, FiboWidth + 1);
            ObjectCreate(0, ObjectPrefix + "Fib50t", OBJ_TEXT, 0, Time[1], Fib50);
            ObjectSetString(0, ObjectPrefix + "Fib50t", OBJPROP_TEXT, "50.0");
            ObjectSetInteger(0, ObjectPrefix + "Fib50t", OBJPROP_FONTSIZE, 8);
            ObjectSetString(0, ObjectPrefix + "Fib50t", OBJPROP_FONT, "Arial");
            ObjectSetInteger(0, ObjectPrefix + "Fib50t", OBJPROP_COLOR, FiboColor);
    
            ObjectCreate(0, ObjectPrefix + "Fib62", OBJ_TREND, 0, Time[cvstart], Fib62, Time[1], Fib62);
            ObjectSetInteger(0, ObjectPrefix + "Fib62", OBJPROP_STYLE, FiboStyle);
            ObjectSetInteger(0, ObjectPrefix + "Fib62", OBJPROP_COLOR, FiboColor);
            ObjectSetInteger(0, ObjectPrefix + "Fib62", OBJPROP_RAY_LEFT, 0);
            ObjectSetInteger(0, ObjectPrefix + "Fib62", OBJPROP_WIDTH, FiboWidth);
            ObjectCreate(0, ObjectPrefix + "Fib62t", OBJ_TEXT, 0, Time[1], Fib62);
            ObjectSetString(0, ObjectPrefix + "Fib62t", OBJPROP_TEXT, "61.8");
            ObjectSetInteger(0, ObjectPrefix + "Fib62t", OBJPROP_FONTSIZE, 8);
            ObjectSetString(0, ObjectPrefix + "Fib62t", OBJPROP_FONT, "Arial");
            ObjectSetInteger(0, ObjectPrefix + "Fib62t", OBJPROP_COLOR, FiboColor);
    
            ObjectCreate(0, ObjectPrefix + "Fib76", OBJ_TREND, 0, Time[cvstart], Fib76, Time[1], Fib76);
            ObjectSetInteger(0, ObjectPrefix + "Fib76", OBJPROP_STYLE, FiboStyle);
            ObjectSetInteger(0, ObjectPrefix + "Fib76", OBJPROP_COLOR, FiboColor);
            ObjectSetInteger(0, ObjectPrefix + "Fib76", OBJPROP_RAY_LEFT, 0);
            ObjectSetInteger(0, ObjectPrefix + "Fib76", OBJPROP_WIDTH, FiboWidth);
            ObjectCreate(0, ObjectPrefix + "Fib76t", OBJ_TEXT, 0, Time[1], Fib76);
            ObjectSetString(0, ObjectPrefix + "Fib76t", OBJPROP_TEXT, "76.4");
            ObjectSetInteger(0, ObjectPrefix + "Fib76t", OBJPROP_FONTSIZE, 8);
            ObjectSetString(0, ObjectPrefix + "Fib76t", OBJPROP_FONT, "Arial");
            ObjectSetInteger(0, ObjectPrefix + "Fib76t", OBJPROP_COLOR, FiboColor);
        }
        
        // Dinapoli.
        if (!DisableDinapoli)
        {
            double Dinap0 = (low_bar + Fib23) / 2;
            double Dinap1 = (Fib23 + Fib38) / 2;
            double Dinap2 = (Fib38 + Fib50) / 2;
            double Dinap3 = (Fib50 + Fib62) / 2;
            double Dinap4 = (Fib62 + Fib76) / 2;
            double Dinap5 = (high_bar + Fib76) / 2;
            bufDinap0[0] = Dinap0;
            bufDinap1[0] = Dinap1;
            bufDinap2[0] = Dinap2;
            bufDinap3[0] = Dinap3;
            bufDinap4[0] = Dinap4;
            bufDinap5[0] = Dinap5;
    
            ObjectCreate(0, ObjectPrefix + "Dinap0", OBJ_TREND, 0, Time[cvstart], Dinap0, Time[1], Dinap0);
            ObjectSetInteger(0, ObjectPrefix + "Dinap0", OBJPROP_STYLE, DinapoliStyle);
            ObjectSetInteger(0, ObjectPrefix + "Dinap0", OBJPROP_COLOR, DinapoliColor);
            ObjectSetInteger(0, ObjectPrefix + "Dinap0", OBJPROP_RAY_LEFT, 0);
            ObjectSetInteger(0, ObjectPrefix + "Dinap0", OBJPROP_WIDTH, DinapoliWidth);
    
            ObjectCreate(0, ObjectPrefix + "Dinap1", OBJ_TREND, 0, Time[cvstart], Dinap1, Time[1], Dinap1);
            ObjectSetInteger(0, ObjectPrefix + "Dinap1", OBJPROP_STYLE, DinapoliStyle);
            ObjectSetInteger(0, ObjectPrefix + "Dinap1", OBJPROP_COLOR, DinapoliColor);
            ObjectSetInteger(0, ObjectPrefix + "Dinap1", OBJPROP_RAY_LEFT, 0);
            ObjectSetInteger(0, ObjectPrefix + "Dinap1", OBJPROP_WIDTH, DinapoliWidth);
    
            ObjectCreate(0, ObjectPrefix + "Dinap2", OBJ_TREND, 0, Time[cvstart], Dinap2, Time[1], Dinap2);
            ObjectSetInteger(0, ObjectPrefix + "Dinap2", OBJPROP_STYLE, DinapoliStyle);
            ObjectSetInteger(0, ObjectPrefix + "Dinap2", OBJPROP_COLOR, DinapoliColor);
            ObjectSetInteger(0, ObjectPrefix + "Dinap2", OBJPROP_RAY_LEFT, 0);
            ObjectSetInteger(0, ObjectPrefix + "Dinap2", OBJPROP_WIDTH, DinapoliWidth);
    
            ObjectCreate(0, ObjectPrefix + "Dinap3", OBJ_TREND, 0, Time[cvstart], Dinap3, Time[1], Dinap3);
            ObjectSetInteger(0, ObjectPrefix + "Dinap3", OBJPROP_STYLE, DinapoliStyle);
            ObjectSetInteger(0, ObjectPrefix + "Dinap3", OBJPROP_COLOR, DinapoliColor);
            ObjectSetInteger(0, ObjectPrefix + "Dinap3", OBJPROP_RAY_LEFT, 0);
            ObjectSetInteger(0, ObjectPrefix + "Dinap3", OBJPROP_WIDTH, DinapoliWidth);
    
            ObjectCreate(0, ObjectPrefix + "Dinap4", OBJ_TREND, 0, Time[cvstart], Dinap4, Time[1], Dinap4);
            ObjectSetInteger(0, ObjectPrefix + "Dinap4", OBJPROP_STYLE, DinapoliStyle);
            ObjectSetInteger(0, ObjectPrefix + "Dinap4", OBJPROP_COLOR, DinapoliColor);
            ObjectSetInteger(0, ObjectPrefix + "Dinap4", OBJPROP_RAY_LEFT, 0);
            ObjectSetInteger(0, ObjectPrefix + "Dinap4", OBJPROP_WIDTH, DinapoliWidth);
    
            ObjectCreate(0, ObjectPrefix + "Dinap5", OBJ_TREND, 0, Time[cvstart], Dinap5, Time[1], Dinap5);
            ObjectSetInteger(0, ObjectPrefix + "Dinap5", OBJPROP_STYLE, DinapoliStyle);
            ObjectSetInteger(0, ObjectPrefix + "Dinap5", OBJPROP_COLOR, clrRed);
            ObjectSetInteger(0, ObjectPrefix + "Dinap5", OBJPROP_RAY_LEFT, 0);
            ObjectSetInteger(0, ObjectPrefix + "Dinap5", OBJPROP_WIDTH, 1);
        }
    }

    // Vertical float lines. These draw the lines that calculate the float.
    // If you change "trendline" to "vertical line", it will draw through oscillators too. Might be fun.
    ObjectDelete(0, ObjectPrefix + "CVSTART");
    ObjectCreate(0, ObjectPrefix + "CVSTART", OBJ_TREND, 0, Time[cvstart], high_bar, Time[cvstart], low_bar * _Point);
    ObjectSetInteger(0, ObjectPrefix + "CVSTART", OBJPROP_STYLE, SwingBorderStyle);
    ObjectSetInteger(0, ObjectPrefix + "CVSTART", OBJPROP_COLOR, SwingBorderColor);
    ObjectSetInteger(0, ObjectPrefix + "CVSTART", OBJPROP_RAY_LEFT, 0);
    ObjectSetInteger(0, ObjectPrefix + "CVSTART", OBJPROP_WIDTH, SwingBorderWidth);
    ObjectSetInteger(0, ObjectPrefix + "CVSTART", OBJPROP_BACK, DrawVerticalLinesAsBackground);

    ObjectDelete(0, ObjectPrefix + "CVEND");
    ObjectCreate(0, ObjectPrefix + "CVEND", OBJ_TREND, 0, Time[cvend], high_bar, Time[cvend], low_bar * _Point);
    ObjectSetInteger(0, ObjectPrefix + "CVEND", OBJPROP_STYLE, SwingBorderStyle);
    ObjectSetInteger(0, ObjectPrefix + "CVEND", OBJPROP_COLOR, SwingBorderColor);
    ObjectSetInteger(0, ObjectPrefix + "CVEND", OBJPROP_RAY_LEFT, 0);
    ObjectSetInteger(0, ObjectPrefix + "CVEND", OBJPROP_WIDTH, SwingBorderWidth);
    ObjectSetInteger(0, ObjectPrefix + "CVEND", OBJPROP_BACK, DrawVerticalLinesAsBackground);

    bufCVSTART[0] = (double)Time[cvstart];
    bufCVEND[0] = (double)Time[cvend];

    // Vertical float predictions. These are time-based only.
    // See blue histogram for real float values.
    // If you change "trendline" to "vertical line", it will draw through oscillators too. Might be fun.
    
    ObjectDelete(0, ObjectPrefix + "Swingend");
    if (cvend - swing_time > 0)
    {
        ObjectCreate(0, ObjectPrefix + "Swingend", OBJ_TREND, 0, Time[(cvend - swing_time) + 5], high_bar, Time[cvend - swing_time + 5], low_bar);
        ObjectSetInteger(0, ObjectPrefix + "Swingend", OBJPROP_STYLE, SwingLinesStyle);
        ObjectSetInteger(0, ObjectPrefix + "Swingend", OBJPROP_COLOR, SwingLinesColor);
        ObjectSetInteger(0, ObjectPrefix + "Swingend", OBJPROP_RAY_LEFT, 0);
        ObjectSetInteger(0, ObjectPrefix + "Swingend", OBJPROP_WIDTH, SwingLinesWidth);
        bufSwingEnd1[0] = (double)Time[(cvend - swing_time) + 5];
    }

    ObjectDelete(0, ObjectPrefix + "Swingend2");
    if (cvend - (swing_time * 2) > 0)
    {
        ObjectCreate(0, ObjectPrefix + "Swingend2", OBJ_TREND, 0, Time[(cvend - (swing_time * 2)) + 5], high_bar, Time[cvend - (swing_time * 2) + 5], low_bar);
        ObjectSetInteger(0, ObjectPrefix + "Swingend2", OBJPROP_STYLE, SwingLinesStyle);
        ObjectSetInteger(0, ObjectPrefix + "Swingend2", OBJPROP_COLOR, SwingLinesColor);
        ObjectSetInteger(0, ObjectPrefix + "Swingend2", OBJPROP_RAY_LEFT, 0);
        ObjectSetInteger(0, ObjectPrefix + "Swingend2", OBJPROP_WIDTH, SwingLinesWidth);
        bufSwingEnd2[0] = (double)Time[(cvend - swing_time * 2) + 5];
    }

    ObjectDelete(0, ObjectPrefix + "Swingend3");
    if (cvend - (swing_time * 3) > 0)
    {
        ObjectCreate(0, ObjectPrefix + "Swingend3", OBJ_TREND, 0, Time[(cvend - (swing_time * 3)) + 5], high_bar, Time[cvend - (swing_time * 3) + 5], low_bar);
        ObjectSetInteger(0, ObjectPrefix + "Swingend3", OBJPROP_STYLE, SwingLinesStyle);
        ObjectSetInteger(0, ObjectPrefix + "Swingend3", OBJPROP_COLOR, SwingLinesColor);
        ObjectSetInteger(0, ObjectPrefix + "Swingend3", OBJPROP_RAY_LEFT, 0);
        ObjectSetInteger(0, ObjectPrefix + "Swingend3", OBJPROP_WIDTH, SwingLinesWidth);
        bufSwingEnd3[0] = (double)Time[(cvend - swing_time * 3) + 5];
    }

    ObjectDelete(0, ObjectPrefix + "Swingend4");
    if (cvend - (swing_time * 4) > 0)
    {
        ObjectCreate(0, ObjectPrefix + "Swingend4", OBJ_TREND, 0, Time[(cvend - (swing_time * 4)) + 5], high_bar, Time[cvend - (swing_time * 4) + 5], low_bar);
        ObjectSetInteger(0, ObjectPrefix + "Swingend4", OBJPROP_STYLE, SwingLinesStyle);
        ObjectSetInteger(0, ObjectPrefix + "Swingend4", OBJPROP_COLOR, SwingLinesColor);
        ObjectSetInteger(0, ObjectPrefix + "Swingend4", OBJPROP_RAY_LEFT, 0);
        ObjectSetInteger(0, ObjectPrefix + "Swingend4", OBJPROP_WIDTH, SwingLinesWidth);
        bufSwingEnd4[0] = (double)Time[(cvend - swing_time * 4) + 5];
    }

    ObjectDelete(0, ObjectPrefix + "Swingend5");
    if (cvend - (swing_time * 5) > 0)
    {
        ObjectCreate(0, ObjectPrefix + "Swingend5", OBJ_TREND, 0, Time[(cvend - (swing_time * 5)) + 5], high_bar, Time[cvend - (swing_time * 5) + 5], low_bar);
        ObjectSetInteger(0, ObjectPrefix + "Swingend5", OBJPROP_STYLE, SwingLinesStyle);
        ObjectSetInteger(0, ObjectPrefix + "Swingend5", OBJPROP_COLOR, SwingLinesColor);
        ObjectSetInteger(0, ObjectPrefix + "Swingend5", OBJPROP_RAY_LEFT, 0);
        ObjectSetInteger(0, ObjectPrefix + "Swingend5", OBJPROP_WIDTH, SwingLinesWidth);
        bufSwingEnd5[0] = (double)Time[(cvend - swing_time * 5) + 5];
    }

    ObjectDelete(0, ObjectPrefix + "Swingend6");
    if (cvend - (swing_time * 6) > 0)
    {
        ObjectCreate(0, ObjectPrefix + "Swingend6", OBJ_TREND, 0, Time[cvend - (swing_time * 6) + 5], high_bar, Time[cvend - (swing_time * 6) + 5], low_bar);
        ObjectSetInteger(0, ObjectPrefix + "Swingend6", OBJPROP_STYLE, SwingLinesStyle);
        ObjectSetInteger(0, ObjectPrefix + "Swingend6", OBJPROP_COLOR, SwingLinesColor);
        ObjectSetInteger(0, ObjectPrefix + "Swingend6", OBJPROP_RAY_LEFT, 0);
        ObjectSetInteger(0, ObjectPrefix + "Swingend6", OBJPROP_WIDTH, SwingLinesWidth);
        bufSwingEnd6[0] = (double)Time[(cvend - swing_time * 6) + 5];
    }

    ObjectDelete(0, ObjectPrefix + "Swingend7");
    if (cvend - (swing_time * 7) > 0)
    {
        ObjectCreate(0, ObjectPrefix + "Swingend7", OBJ_TREND, 0, Time[cvend - (swing_time * 7) + 5], high_bar, Time[cvend - (swing_time * 7) + 5], low_bar);
        ObjectSetInteger(0, ObjectPrefix + "Swingend7", OBJPROP_STYLE, SwingLinesStyle);
        ObjectSetInteger(0, ObjectPrefix + "Swingend7", OBJPROP_COLOR, SwingLinesColor);
        ObjectSetInteger(0, ObjectPrefix + "Swingend7", OBJPROP_RAY_LEFT, 0);
        ObjectSetInteger(0, ObjectPrefix + "Swingend7", OBJPROP_WIDTH, SwingLinesWidth);
        bufSwingEnd7[0] = (double)Time[(cvend - swing_time * 7) + 5];
    }

    ObjectDelete(0, ObjectPrefix + "Swingend8");
    if (cvend - (swing_time * 8) > 0)
    {
        ObjectCreate(0, ObjectPrefix + "Swingend8", OBJ_TREND, 0, Time[cvend - (swing_time * 8) + 5], high_bar, Time[cvend - (swing_time * 8) + 5], low_bar);
        ObjectSetInteger(0, ObjectPrefix + "Swingend8", OBJPROP_STYLE, SwingLinesStyle);
        ObjectSetInteger(0, ObjectPrefix + "Swingend8", OBJPROP_COLOR, SwingLinesColor);
        ObjectSetInteger(0, ObjectPrefix + "Swingend8", OBJPROP_RAY_LEFT, 0);
        ObjectSetInteger(0, ObjectPrefix + "Swingend8", OBJPROP_WIDTH, SwingLinesWidth);
        bufSwingEnd8[0] = (double)Time[(cvend - swing_time * 8) + 5];
    }

    ObjectDelete(0, ObjectPrefix + "Swingend9");
    if (cvend - (swing_time * 9) > 0)
    {
        ObjectCreate(0, ObjectPrefix + "Swingend9", OBJ_TREND, 0, Time[cvend - (swing_time * 9) + 5], high_bar, Time[cvend - (swing_time * 9) + 5], low_bar);
        ObjectSetInteger(0, ObjectPrefix + "Swingend9", OBJPROP_STYLE, SwingLinesStyle);
        ObjectSetInteger(0, ObjectPrefix + "Swingend9", OBJPROP_COLOR, SwingLinesColor);
        ObjectSetInteger(0, ObjectPrefix + "Swingend9", OBJPROP_RAY_LEFT, 0);
        ObjectSetInteger(0, ObjectPrefix + "Swingend9", OBJPROP_WIDTH, SwingLinesWidth);
        bufSwingEnd9[0] = (double)Time[(cvend - swing_time * 9) + 5];
    }

    return rates_total;
}
//+------------------------------------------------------------------+