// ignore_for_file: unused_field, unused_local_variable, unnecessary_null_comparison, must_be_immutable, non_constant_identifier_names

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:simple_gesture_detector/simple_gesture_detector.dart';
import 'package:adaptive_date_picker/adaptive_date_picker.dart';
import '../scrollable_bottomsheet_datepicker.dart';
import 'widgets/calendar_header.dart';
import 'widgets/cell_content.dart';
import "package:jiffy/jiffy.dart";

int? monthindex;

/// Signature for `onDaySelected` callback. Contains the selected day and focused day.
typedef OnDaySelected = void Function(
    DateTime selectedDay, DateTime focusedDay);

/// Signature for `onRangeSelected` callback.
/// Contains start and end of the selected range, as well as currently focused day.
typedef OnRangeSelected = void Function(
    DateTime? start, DateTime? end, DateTime focusedDay);

/// Modes that range selection can operate in.
enum RangeSelectionMode { disabled, toggledOff, toggledOn, enforced }

/// Highly customizable, feature-packed Flutter calendar with gestures, animations and multiple formats.
class TableCalendar<T> extends StatefulWidget {
  /// Locale to format `TableCalendar` dates with, for example: `'en_US'`.
  ///
  /// If nothing is provided, a default locale will be used.
  final dynamic locale;

  /// The start of the selected day range.
  final DateTime? rangeStartDay;

  /// The end of the selected day range.
  final DateTime? rangeEndDay;

  /// DateTime that determines which days are currently visible and focused.
  final DateTime focusedDay;

  /// The first active day of `TableCalendar`.
  /// Blocks swiping to days before it.
  ///
  /// Days before it will use `disabledStyle` and trigger `onDisabledDayTapped` callback.
  final DateTime firstDay;

  /// The last active day of `TableCalendar`.
  /// Blocks swiping to days after it.
  ///
  /// Days after it will use `disabledStyle` and trigger `onDisabledDayTapped` callback.
  final DateTime lastDay;

  /// DateTime that will be treated as today. Defaults to `DateTime.now()`.
  ///
  /// Overriding this property might be useful for testing.
  final DateTime? currentDay;

  /// List of days treated as weekend days.
  /// Use built-in `DateTime` weekday constants (e.g. `DateTime.monday`) instead of `int` literals (e.g. `1`).
  final List<int> weekendDays;

  /// Specifies `TableCalendar`'s current format.
  final CalendarFormat calendarFormat;

  /// `Map` of `CalendarFormat`s and `String` names associated with them.
  /// Those `CalendarFormat`s will be used by internal logic to manage displayed format.
  ///
  /// To ensure proper vertical swipe behavior, `CalendarFormat`s should be in descending order (i.e. from biggest to smallest).
  ///
  /// For example:
  /// ```dart
  /// availableCalendarFormats: const {
  ///   CalendarFormat.month: 'Month',
  ///   CalendarFormat.week: 'Week',
  /// }
  /// ```
  final Map<CalendarFormat, String> availableCalendarFormats;

  /// Determines the visibility of calendar header.
  final bool headerVisible;

  /// Determines the visibility of the row of days of the week.
  final bool daysOfWeekVisible;

  /// When set to true, tapping on an outside day in `CalendarFormat.month` format
  /// will jump to the calendar page of the tapped month.
  final bool pageJumpingEnabled;

  /// When set to true, updating the `focusedDay` will display a scrolling animation
  /// if the currently visible calendar page is changed.
  final bool pageAnimationEnabled;

  /// When set to true, `CalendarFormat.month` will always display six weeks,
  /// even if the content would fit in less.
  final bool sixWeekMonthsEnforced;

  /// When set to true, `TableCalendar` will fill available height.
  final bool shouldFillViewport;

  /// Whether to display week numbers on calendar.
  final bool weekNumbersVisible;

  /// Used for setting the height of `TableCalendar`'s rows.
  final double rowHeight;

  /// Used for setting the height of `TableCalendar`'s days of week row.
  final double daysOfWeekHeight;

  /// Specifies the duration of size animation that takes place whenever `calendarFormat` is changed.
  final Duration formatAnimationDuration;

  /// Specifies the curve of size animation that takes place whenever `calendarFormat` is changed.
  final Curve formatAnimationCurve;

  /// Specifies the duration of scrolling animation that takes place whenever the visible calendar page is changed.
  final Duration pageAnimationDuration;

  /// Specifies the curve of scrolling animation that takes place whenever the visible calendar page is changed.
  final Curve pageAnimationCurve;

  /// `TableCalendar` will start weeks with provided day.
  ///
  /// Use `StartingDayOfWeek.monday` for Monday - Sunday week format.
  /// Use `StartingDayOfWeek.sunday` for Sunday - Saturday week format.
  final StartingDayOfWeek startingDayOfWeek;

  /// `HitTestBehavior` for every day cell inside `TableCalendar`.
  final HitTestBehavior dayHitTestBehavior;

  /// Specifies swipe gestures available to `TableCalendar`.
  /// If `AvailableGestures.none` is used, the calendar will only be interactive via buttons.
  final AvailableGestures availableGestures;

  /// Configuration for vertical swipe detector.
  final SimpleSwipeConfig simpleSwipeConfig;

  /// Style for `TableCalendar`'s header.
  final HeaderStyle headerStyle;

  /// Style for days of week displayed between `TableCalendar`'s header and content.
  final DaysOfWeekStyle daysOfWeekStyle;

  /// Style for `TableCalendar`'s content.
  final CalendarStyle calendarStyle;

  /// Set of custom builders for `TableCalendar` to work with.
  /// Use those to fully tailor the UI.
  final CalendarBuilders<T> calendarBuilders;

  /// Current mode of range selection.
  ///
  /// * `RangeSelectionMode.disabled` - range selection is always off.
  /// * `RangeSelectionMode.toggledOff` - range selection is currently off, can be toggled by longpressing a day cell.
  /// * `RangeSelectionMode.toggledOn` - range selection is currently on, can be toggled by longpressing a day cell.
  /// * `RangeSelectionMode.enforced` - range selection is always on.
  final RangeSelectionMode rangeSelectionMode;

  /// Function that assigns a list of events to a specified day.
  final List<T> Function(DateTime day)? eventLoader;

  /// Function deciding whether given day should be enabled or not.
  /// If `false` is returned, this day will be disabled.
  final bool Function(DateTime day)? enabledDayPredicate;

  /// Function deciding whether given day should be marked as selected.
  final bool Function(DateTime day)? selectedDayPredicate;

  /// Function deciding whether given day is treated as a holiday.
  final bool Function(DateTime day)? holidayPredicate;

  /// Called whenever a day range gets selected.
  final OnRangeSelected? onRangeSelected;

  /// Called whenever any day gets tapped.
  final OnDaySelected? onDaySelected;

  /// Called whenever any day gets long pressed.
  final OnDaySelected? onDayLongPressed;

  /// Called whenever any disabled day gets tapped.
  final void Function(DateTime day)? onDisabledDayTapped;

  /// Called whenever any disabled day gets long pressed.
  final void Function(DateTime day)? onDisabledDayLongPressed;

  /// Called whenever header gets tapped.
  final void Function(DateTime focusedDay)? onHeaderTapped;

  /// Called whenever header gets long pressed.
  final void Function(DateTime focusedDay)? onHeaderLongPressed;

  /// Called whenever currently visible calendar page is changed.
  final void Function(DateTime focusedDay)? onPageChanged;

  /// Called whenever `calendarFormat` is changed.
  final void Function(CalendarFormat format)? onFormatChanged;

  /// Called when the calendar is created. Exposes its PageController.
  final void Function(PageController pageController)? onCalendarCreated;
  final double leftchevronsize;
  final double rightchevronsize;
  Image? LeftIcon;
   Image? RightIcon;
   final bool? isfuturedaydisable;
  /// Creates a `TableCalendar` widget.
  TableCalendar({
    Key? key,
    required DateTime focusedDay,
    required DateTime firstDay,
    required DateTime lastDay,
    DateTime? currentDay,
    this.locale,
    this.rangeStartDay,
    this.rangeEndDay,
    this.weekendDays = const [DateTime.saturday, DateTime.sunday],
    this.calendarFormat = CalendarFormat.month,
    this.availableCalendarFormats = const {
      CalendarFormat.month: 'Month',
      CalendarFormat.twoWeeks: '2 weeks',
      CalendarFormat.week: 'Week',
    },
    this.isfuturedaydisable=false,
    this.headerVisible = true,
    this.daysOfWeekVisible = true,
    this.pageJumpingEnabled = false,
    this.pageAnimationEnabled = true,
    this.sixWeekMonthsEnforced = false,
    this.shouldFillViewport = false,
    this.weekNumbersVisible = false,
    this.rowHeight = 52.0,
    this.daysOfWeekHeight = 16.0,
    this.formatAnimationDuration = const Duration(milliseconds: 200),
    this.formatAnimationCurve = Curves.linear,
    this.pageAnimationDuration = const Duration(milliseconds: 300),
    this.pageAnimationCurve = Curves.easeOut,
    this.startingDayOfWeek = StartingDayOfWeek.sunday,
    this.dayHitTestBehavior = HitTestBehavior.opaque,
    this.availableGestures = AvailableGestures.all,
    this.simpleSwipeConfig = const SimpleSwipeConfig(
      verticalThreshold: 25.0,
      swipeDetectionBehavior: SwipeDetectionBehavior.continuousDistinct,
    ),
    this.headerStyle = const HeaderStyle(),
    this.daysOfWeekStyle = const DaysOfWeekStyle(),
    this.calendarStyle = const CalendarStyle(),
    this.calendarBuilders = const CalendarBuilders(),
    this.rangeSelectionMode = RangeSelectionMode.toggledOff,
    this.eventLoader,
    this.enabledDayPredicate,
    this.selectedDayPredicate,
    this.holidayPredicate,
    this.onRangeSelected,
    this.onDaySelected,
    this.onDayLongPressed,
    this.onDisabledDayTapped,
    this.onDisabledDayLongPressed,
    this.onHeaderTapped,
    this.onHeaderLongPressed,
    this.onPageChanged,
    this.onFormatChanged,
    this.onCalendarCreated,
    required this.leftchevronsize,
    required this.rightchevronsize,  this.LeftIcon,  this.RightIcon
  })  : assert(availableCalendarFormats.keys.contains(calendarFormat)),
        assert(availableCalendarFormats.length <= CalendarFormat.values.length),
        assert(weekendDays.isNotEmpty
            ? weekendDays.every(
                (day) => day >= DateTime.monday && day <= DateTime.sunday)
            : true),
        focusedDay = normalizeDate(focusedDay),
        firstDay = normalizeDate(firstDay),
        lastDay = normalizeDate(lastDay),
        currentDay = currentDay ?? DateTime.now(),
        super(key: key);

  @override
  _TableCalendarState<T> createState() => _TableCalendarState<T>();
}

class _TableCalendarState<T> extends State<TableCalendar<T>> {
  late final PageController _pageController;
  ValueNotifier<DateTime>? _focusedDay;
  late RangeSelectionMode _rangeSelectionMode;
  int from = 2000;
  int to = 2100;
  DateTime? _firstSelectedDay;
  int? _previousIndex;
  DateTime? val;
  bool? _pageCallbackDisabled;
  @override
  void initState() {
    super.initState();
    if(widget.LeftIcon==null){
      widget.LeftIcon=Image(image: AssetImage("assets/left_chevron.png"));
     
    }
    if(widget.RightIcon==null){
       widget.RightIcon=Image(
                  image: AssetImage("assets/right_chevron.png"),
                 );
    }
    final initialPage = _calculateFocusedPage(
        widget.calendarFormat, widget.firstDay, widget.focusedDay);
      _previousIndex=initialPage;
    _focusedDay = ValueNotifier(widget.focusedDay);
  
    _rangeSelectionMode = widget.rangeSelectionMode;
  }
 
  
  
 

    DateTime _firstDayOfWeek(DateTime week) {
    final daysBefore = _getDaysBefore(week);
    return week.subtract(Duration(days: daysBefore));
  }

  DateTime _firstDayOfMonth(DateTime month) {
    return DateTime.utc(month.year, month.month, 1);
  }

  DateTime _lastDayOfMonth(DateTime month) {
    final date = month.month < 12
        ? DateTime.utc(month.year, month.month + 1, 1)
        : DateTime.utc(month.year + 1, 1, 1);
    return date.subtract(const Duration(days: 1));
  }
  int _getDaysBefore(DateTime firstDay) {
    return (firstDay.weekday + 7 - getWeekdayNumber(widget.startingDayOfWeek)) %
        7;
  }
  void _updatePage({bool shouldAnimate = false}) {
 
    final currentIndex = _calculateFocusedPage(
        widget.calendarFormat, widget.firstDay, val!);
    
    final endIndex = _calculateFocusedPage(
        widget.calendarFormat, widget.firstDay, widget.lastDay);
   
    if (currentIndex != _previousIndex ||
        currentIndex == 0 ||
        currentIndex == endIndex) {
      _pageCallbackDisabled = true;
    }

    // if (shouldAnimate && widget.pageAnimationEnabled) {
    
      
       if (shouldAnimate && widget.pageAnimationEnabled){
              if ((currentIndex - _previousIndex!).abs() > 1) {
      
        final jumpIndex =
            currentIndex > _previousIndex! ? currentIndex - 1 : currentIndex + 1;
           
        _pageController.jumpToPage(jumpIndex); 
      }
       _pageController.animateToPage(
        currentIndex,
        duration: widget.pageAnimationDuration,
        curve: widget.pageAnimationCurve,
      );
       }
     
      else{
        
          _pageController.jumpToPage(currentIndex+1);
      }
    
      
   

    _previousIndex = currentIndex;
    final rowCount = _getRowCount(widget.calendarFormat, val!);


    _pageCallbackDisabled = false;
  }
  updatedate(req) async{

        DValue[0]["Month"] = req["Month"];
        DValue[0]["Year"] = req["Year"];
         
        monthindex =await  DValue[0]["Month"] == "January"
            ? 1
            : DValue[0]["Month"] == "February"
                ? 2
                : DValue[0]["Month"] == "March"
                    ? 3
                    : DValue[0]["Month"] == "April"
                        ? 4
                        : DValue[0]["Month"] == "May"
                            ? 5
                            : DValue[0]["Month"] == "June"
                                ? 6
                                : DValue[0]["Month"] == "July"
                                    ? 7
                                    : DValue[0]["Month"] == "August"
                                        ? 8
                                        : DValue[0]["Month"] == "September"
                                            ? 9
                                            : DValue[0]["Month"] == "October"
                                                ? 10
                                                : DValue[0]["Month"] ==
                                                        "November"
                                                    ? 11
                                                    : 12;

      
            
             val= DateTime.utc(int.parse(DValue[0]["Year"]), monthindex!, 1);
              _focusedDay = ValueNotifier(
            DateTime.utc(int.parse(DValue[0]["Year"]), monthindex!, 1));
      
      
         _updatePage(shouldAnimate:false);
  }
  @override
  void didUpdateWidget(TableCalendar<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
   if (_focusedDay!.value != widget.focusedDay) {
     
      // _focusedDay!.value = widget.focusedDay;
      _focusedDay = ValueNotifier(
          DateTime.utc(int.parse(DValue[0]["Year"]), monthindex!, 1));
    }

    if (_rangeSelectionMode != widget.rangeSelectionMode) {
      
      _rangeSelectionMode = widget.rangeSelectionMode;
    }

    if (widget.rangeStartDay == null && widget.rangeEndDay == null) {
     
      _firstSelectedDay = null;
    }
  }
 int _calculateFocusedPage(
      CalendarFormat format, DateTime startDay, DateTime focusedDay) {
    switch (format) {
      case CalendarFormat.month:
     
        return _getMonthCount(startDay, focusedDay);
      case CalendarFormat.twoWeeks:

        return _getTwoWeekCount(startDay, focusedDay);
      case CalendarFormat.week:
         
        return _getWeekCount(startDay, focusedDay);
      default:
     
        return _getMonthCount(startDay, focusedDay);
    }
  }

  int _getMonthCount(DateTime first, DateTime last) {
    final yearDif = last.year - first.year;
    final monthDif = last.month - first.month;

    return yearDif * 12 + monthDif;
  }

  int _getWeekCount(DateTime first, DateTime last) {
    
    return last.difference(_firstDayOfWeek(first)).inDays ~/ 7;
  }

  int _getTwoWeekCount(DateTime first, DateTime last) {
    return last.difference(_firstDayOfWeek(first)).inDays ~/ 14;
  }

  int _getRowCount(CalendarFormat format, DateTime focusedDay) {
    if (format == CalendarFormat.twoWeeks) {
      return 2;
    } else if (format == CalendarFormat.week) {
      return 1;
    } else if (widget.sixWeekMonthsEnforced) {
      return 6;
    }

    final first = _firstDayOfMonth(focusedDay);
    final daysBefore = _getDaysBefore(first);
    final firstToDisplay = first.subtract(Duration(days: daysBefore));

    final last = _lastDayOfMonth(focusedDay);
    final daysAfter = _getDaysAfter(last);
    final lastToDisplay = last.add(Duration(days: daysAfter));

    return (lastToDisplay.difference(firstToDisplay).inDays + 1) ~/ 7;
  }
  int _getDaysAfter(DateTime lastDay) {
    int invertedStartingWeekday =
        8 - getWeekdayNumber(widget.startingDayOfWeek);

    int daysAfter = 7 - ((lastDay.weekday + invertedStartingWeekday) % 7);
    if (daysAfter == 7) {
      daysAfter = 0;
    }

    return daysAfter;
  }
  @override
  void dispose() {
    
    _focusedDay!.dispose();
    super.dispose();
  }

  bool get _isRangeSelectionToggleable =>
      _rangeSelectionMode == RangeSelectionMode.toggledOn ||
      _rangeSelectionMode == RangeSelectionMode.toggledOff;

  bool get _isRangeSelectionOn =>
      _rangeSelectionMode == RangeSelectionMode.toggledOn ||
      _rangeSelectionMode == RangeSelectionMode.enforced;

  bool get _shouldBlockOutsideDays =>
      !widget.calendarStyle.outsideDaysVisible &&
      widget.calendarFormat == CalendarFormat.month;

  void _swipeCalendarFormat(SwipeDirection direction) {
   
    if (widget.onFormatChanged != null) {
      final formats = widget.availableCalendarFormats.keys.toList();

      final isSwipeUp = direction == SwipeDirection.up;
      int id = formats.indexOf(widget.calendarFormat);

      // Order of CalendarFormats must be from biggest to smallest,
      // e.g.: [month, twoWeeks, week]
      if (isSwipeUp) {
        id = min(formats.length - 1, id + 1);
      } else {
        id = max(0, id - 1);
      }

      widget.onFormatChanged!(formats[id]);
    }
  }

  void _onDayTapped(DateTime day) {
    final isOutside = day.month != _focusedDay!.value.month;
    if (isOutside && _shouldBlockOutsideDays) {
      return;
    }

    if (_isDayDisabled(day)) {
  
      return widget.onDisabledDayTapped?.call(day);
    }

    _updateFocusOnTap(day);

    if (_isRangeSelectionOn && widget.onRangeSelected != null) {
      if (_firstSelectedDay == null) {
        _firstSelectedDay = day;
        widget.onRangeSelected!(_firstSelectedDay, null, _focusedDay!.value);
      } else {
        if (day.isAfter(_firstSelectedDay!)) {
          widget.onRangeSelected!(_firstSelectedDay, day, _focusedDay!.value);
          _firstSelectedDay = null;
        } else if (day.isBefore(_firstSelectedDay!)) {
          widget.onRangeSelected!(day, _firstSelectedDay, _focusedDay!.value);
          _firstSelectedDay = null;
        }
      }
    } else {
   
      widget.onDaySelected?.call(day, _focusedDay!.value);
    }
  }

  void _onDayLongPressed(DateTime day) {
    final isOutside = day.month != _focusedDay!.value.month;
    if (isOutside && _shouldBlockOutsideDays) {
      return;
    }

    if (_isDayDisabled(day)) {
      return widget.onDisabledDayLongPressed?.call(day);
    }

    if (widget.onDayLongPressed != null) {
      _updateFocusOnTap(day);
      return widget.onDayLongPressed!(day, _focusedDay!.value);
    }

    if (widget.onRangeSelected != null) {
      if (_isRangeSelectionToggleable) {
        _updateFocusOnTap(day);
        _toggleRangeSelection();

        if (_isRangeSelectionOn) {
          _firstSelectedDay = day;
          widget.onRangeSelected!(_firstSelectedDay, null, _focusedDay!.value);
        } else {
          _firstSelectedDay = null;
          widget.onDaySelected?.call(day, _focusedDay!.value);
        }
      }
    }
  }

  void _updateFocusOnTap(DateTime day) {
    if (widget.pageJumpingEnabled) {
      _focusedDay!.value = day;
      return;
    }

    if (widget.calendarFormat == CalendarFormat.month) {
   
      if (_isBeforeMonth(day, _focusedDay!.value)) {
        _focusedDay!.value = _firstDayOfMonth(_focusedDay!.value);
      } else if (_isAfterMonth(day, _focusedDay!.value)) {
        _focusedDay!.value = _lastDayOfMonth(_focusedDay!.value);
      } else {
        _focusedDay!.value = day;
      }
    } else {
      _focusedDay!.value = day;
    }
  }

  void _toggleRangeSelection() {
    if (_rangeSelectionMode == RangeSelectionMode.toggledOn) {
      _rangeSelectionMode = RangeSelectionMode.toggledOff;
    } else {
      _rangeSelectionMode = RangeSelectionMode.toggledOn;
    }
  }

  void _onLeftChevronTap() {
    _pageController.previousPage(
      duration: widget.pageAnimationDuration,
      curve: widget.pageAnimationCurve,
    );
  }

  void _onRightChevronTap() {
    _pageController.nextPage(
      duration: widget.pageAnimationDuration,
      curve: widget.pageAnimationCurve,
    );
  }

  void _showCustomPicker() {
    Picker(
      PassValues: DValue,
      height: 192,
      itemExtent: 40,
      textScaleFactor: 0,
      squeeze: 1,
      builderHeader: (_) => const SizedBox.shrink(),
      selectionOverlay: Container(
        padding: const EdgeInsets.all(5),
        decoration: const BoxDecoration(
          border: Border.symmetric(
            horizontal: BorderSide(
              color: Colors.black12,
              width: 1.0,
            ),
          ),
        ),
      ),
      onchanged: (req) {
        updatedate(req);
      
      },
      adapter: PickerDataAdapter(
        data: [
          for (int i = 0; i < months.length; i++)
            PickerItem(
              text: Center(
                child: Text(
                  months[i],
                  textAlign: TextAlign.right,
                ),
              ),
              value: i,
              children: [
                for (int i = 0; i < Generateyears.length; i++)
                  PickerItem(
                      text: Center(
                        child: Text(
                          Generateyears[i],
                          textAlign: TextAlign.left,
                        ),
                      ),
                      value: i),
              ],
            ),
        ],
      ),
    ).showModal(context);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.headerVisible)
          ValueListenableBuilder<DateTime>(
            valueListenable: _focusedDay!,
            builder: (context, value, _) {
              return CalendarHeader(
                LeftIcon: widget.LeftIcon,
                RightIcon: widget.RightIcon,
                headerTitleBuilder: widget.calendarBuilders.headerTitleBuilder,
                focusedMonth: value,
                onLeftChevronTap: _onLeftChevronTap,
                onRightChevronTap: _onRightChevronTap,
                leftchevronsize: widget.leftchevronsize,
                rightchevronsize: widget.rightchevronsize,
                // onHeaderTap: () => widget.onHeaderTapped?.call(value),
                onHeaderTap: () {
                  if (from != null && to != null) {
                    var start = from;
                    var end = to;
                    if (int.parse(start.toString()) <
                        int.parse(end.toString())) {
                      for (var i = start; i <= end; i++) {
                        Generateyears.add(i.toString());
                      }
                    } else {
                      for (var i = 1990; i <= 2050; i++) {
                        Generateyears.add(i.toString());
                      }
                    }
                  } else if (from != null && to == null) {
                    var start = from;

                    for (var i = start; i <= 2050; i++) {
                      Generateyears.add(i.toString());
                    }
                  } else {
                    for (var i = 1990; i <= 2050; i++) {
                      Generateyears.add(i.toString());
                    }
                  }
                  _showCustomPicker();
                  // widget.onHeaderTapped?.call(_focusedDay!.value);
                  DValue[0]["Month"] =
                      Jiffy(value, "yyyy-mm-dd mm:hh:ssZ").format("MMMM");
                  DValue[0]["Year"] = Jiffy(value, "yyyy-mm-dd mm:hh:ssZ")
                      .format("yyyy")
                      .toString();
              
                },
                onHeaderLongPress: () =>
                    widget.onHeaderLongPressed?.call(value),
                headerStyle: widget.headerStyle,
                availableCalendarFormats: widget.availableCalendarFormats,
                calendarFormat: widget.calendarFormat,
                locale: widget.locale,
                onFormatButtonTap: (format) {
                  assert(
                    widget.onFormatChanged != null,
                    'Using `FormatButton` without providing `onFormatChanged` will have no effect.',
                  );

                  widget.onFormatChanged?.call(format);
                },
              );
            },
          ),
        Flexible(
          flex: widget.shouldFillViewport ? 1 : 0,
          child: TableCalendarBase(
            onCalendarCreated: (pageController) {
              _pageController = pageController;
              widget.onCalendarCreated?.call(pageController);
            },
            focusedDay: _focusedDay!.value,
            calendarFormat: widget.calendarFormat,
            availableGestures: widget.availableGestures,
            firstDay: widget.firstDay,
            lastDay: widget.lastDay,
            startingDayOfWeek: widget.startingDayOfWeek,
            dowDecoration: widget.daysOfWeekStyle.decoration,
            rowDecoration: widget.calendarStyle.rowDecoration,
            tableBorder: widget.calendarStyle.tableBorder,
            dowVisible: widget.daysOfWeekVisible,
            dowHeight: widget.daysOfWeekHeight,
            rowHeight: widget.rowHeight,
            formatAnimationDuration: widget.formatAnimationDuration,
            formatAnimationCurve: widget.formatAnimationCurve,
            pageAnimationEnabled: widget.pageAnimationEnabled,
            pageAnimationDuration: widget.pageAnimationDuration,
            pageAnimationCurve: widget.pageAnimationCurve,
            availableCalendarFormats: widget.availableCalendarFormats,
            simpleSwipeConfig: widget.simpleSwipeConfig,
            sixWeekMonthsEnforced: widget.sixWeekMonthsEnforced,
            onVerticalSwipe: _swipeCalendarFormat,
            onPageChanged: (focusedDay) {
             
              _focusedDay!.value = focusedDay;
              widget.onPageChanged?.call(focusedDay);
            },
            weekNumbersVisible: widget.weekNumbersVisible,
            weekNumberBuilder: (BuildContext context, DateTime day) {
              final weekNumber = _calculateWeekNumber(day);
              Widget? cell = widget.calendarBuilders.weekNumberBuilder
                  ?.call(context, weekNumber);

              if (cell == null) {
                cell = Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Center(
                    child: Text(
                      weekNumber.toString(),
                      style: widget.calendarStyle.weekNumberTextStyle,
                    ),
                  ),
                );
              }

              return cell;
            },
            dowBuilder: (BuildContext context, DateTime day) {
              Widget? dowCell =
                  widget.calendarBuilders.dowBuilder?.call(context, day);

              if (dowCell == null) {
                final weekdayString = widget.daysOfWeekStyle.dowTextFormatter
                        ?.call(day, widget.locale) ??
                    DateFormat.E(widget.locale).format(day);

                final isWeekend =
                    _isWeekend(day, weekendDays: widget.weekendDays);

                dowCell = Center(
                  child: ExcludeSemantics(
                    child: Text(
                      weekdayString,
                      style: isWeekend
                          ? widget.daysOfWeekStyle.weekendStyle
                          : widget.daysOfWeekStyle.weekdayStyle,
                    ),
                  ),
                );
              }

              return dowCell;
            },
            dayBuilder: (context, day, focusedMonth) {
              return GestureDetector(
                behavior: widget.dayHitTestBehavior,
                onTap: ()  {
                  if(widget.isfuturedaydisable==true){
                    if(day.isBefore(DateTime.now())){
                      _onDayTapped(day);
                    }
                  }
                  else{
                    _onDayTapped(day);
                  }
                },
                onLongPress: () => _onDayLongPressed(day),
                child: _buildCell(day, focusedMonth,widget.isfuturedaydisable),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCell(DateTime day, DateTime focusedDay, value) {
    final isOutside = day.month != focusedDay.month;

    if (isOutside && _shouldBlockOutsideDays) {
      return Container();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final shorterSide = constraints.maxHeight > constraints.maxWidth
            ? constraints.maxWidth
            : constraints.maxHeight;

        final children = <Widget>[];

        final isWithinRange = widget.rangeStartDay != null &&
            widget.rangeEndDay != null &&
            _isWithinRange(day, widget.rangeStartDay!, widget.rangeEndDay!);

        final isRangeStart = isSameDay(day, widget.rangeStartDay);
        final isRangeEnd = isSameDay(day, widget.rangeEndDay);

        Widget? rangeHighlight = widget.calendarBuilders.rangeHighlightBuilder
            ?.call(context, day, isWithinRange);

        if (rangeHighlight == null) {
          if (isWithinRange) {
            rangeHighlight = Center(
              child: Container(
                margin: EdgeInsetsDirectional.only(
                  start: isRangeStart ? constraints.maxWidth * 0.5 : 0.0,
                  end: isRangeEnd ? constraints.maxWidth * 0.5 : 0.0,
                ),
                height:
                    (shorterSide - widget.calendarStyle.cellMargin.vertical) *
                        widget.calendarStyle.rangeHighlightScale,
                color: widget.calendarStyle.rangeHighlightColor,
              ),
            );
          }
        }

        if (rangeHighlight != null) {
          children.add(rangeHighlight);
        }

        final isToday = isSameDay(day, widget.currentDay);
        final isDisabled = _isDayDisabled(day);
        final isWeekend = _isWeekend(day, weekendDays: widget.weekendDays);

        Widget content = CellContent(
          isfuturedaydisable:widget.isfuturedaydisable,
          key: ValueKey('CellContent-${day.year}-${day.month}-${day.day}'),
          day: day,
          focusedDay: focusedDay,
          calendarStyle: widget.calendarStyle,
          calendarBuilders: widget.calendarBuilders,
          isTodayHighlighted: widget.calendarStyle.isTodayHighlighted,
          isToday: isToday,
          isSelected: widget.selectedDayPredicate?.call(day) ?? false,
          isRangeStart: isRangeStart,
          isRangeEnd: isRangeEnd,
          isWithinRange: isWithinRange,
          isOutside: isOutside,
          isDisabled: isDisabled,
          isWeekend: isWeekend,
          isHoliday: widget.holidayPredicate?.call(day) ?? false,
          locale: widget.locale,
        );

        children.add(content);

        if (!isDisabled) {
          final events = widget.eventLoader?.call(day) ?? [];
          Widget? markerWidget =
              widget.calendarBuilders.markerBuilder?.call(context, day, events);

          if (events.isNotEmpty && markerWidget == null) {
            final center = constraints.maxHeight / 2;

            final markerSize = widget.calendarStyle.markerSize ??
                (shorterSide - widget.calendarStyle.cellMargin.vertical) *
                    widget.calendarStyle.markerSizeScale;

            final markerAutoAlignmentTop = center +
                (shorterSide - widget.calendarStyle.cellMargin.vertical) / 2 -
                (markerSize * widget.calendarStyle.markersAnchor);

            markerWidget = PositionedDirectional(
              top: widget.calendarStyle.markersAutoAligned
                  ? markerAutoAlignmentTop
                  : widget.calendarStyle.markersOffset.top,
              bottom: widget.calendarStyle.markersAutoAligned
                  ? null
                  : widget.calendarStyle.markersOffset.bottom,
              start: widget.calendarStyle.markersAutoAligned
                  ? null
                  : widget.calendarStyle.markersOffset.start,
              end: widget.calendarStyle.markersAutoAligned
                  ? null
                  : widget.calendarStyle.markersOffset.end,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: events
                    .take(widget.calendarStyle.markersMaxCount)
                    .map((event) => _buildSingleMarker(day, event, markerSize))
                    .toList(),
              ),
            );
          }

          if (markerWidget != null) {
            children.add(markerWidget);
          }
        }

        return Stack(
          alignment: widget.calendarStyle.markersAlignment,
          children: children,
          clipBehavior: widget.calendarStyle.canMarkersOverflow
              ? Clip.none
              : Clip.hardEdge,
        );
      },
    );
  }

  Widget _buildSingleMarker(DateTime day, T event, double markerSize) {
    return widget.calendarBuilders.singleMarkerBuilder
            ?.call(context, day, event) ??
        Container(
          width: markerSize,
          height: markerSize,
          margin: widget.calendarStyle.markerMargin,
          decoration: widget.calendarStyle.markerDecoration,
        );
  }

  int _calculateWeekNumber(DateTime date) {
    final middleDay = date.add(const Duration(days: 3));
    final dayOfYear = _dayOfYear(middleDay);

    return 1 + ((dayOfYear - 1) / 7).floor();
  }

  int _dayOfYear(DateTime date) {
    return normalizeDate(date)
            .difference(DateTime.utc(date.year, 1, 1))
            .inDays +
        1;
  }

  bool _isWithinRange(DateTime day, DateTime start, DateTime end) {
    if (isSameDay(day, start) || isSameDay(day, end)) {
      return true;
    }

    if (day.isAfter(start) && day.isBefore(end)) {
      return true;
    }

    return false;
  }

  bool _isDayDisabled(DateTime day) {
    return day.isBefore(widget.firstDay) ||
        day.isAfter(widget.lastDay) ||
        !_isDayAvailable(day);
  }

  bool _isDayAvailable(DateTime day) {
    return widget.enabledDayPredicate == null
        ? true
        : widget.enabledDayPredicate!(day);
  }

  

  bool _isBeforeMonth(DateTime day, DateTime month) {
    if (day.year == month.year) {
      return day.month < month.month;
    } else {
      return day.isBefore(month);
    }
  }

  bool _isAfterMonth(DateTime day, DateTime month) {
    if (day.year == month.year) {
      return day.month > month.month;
    } else {
      return day.isAfter(month);
    }
  }

  bool _isWeekend(
    DateTime day, {
    List<int> weekendDays = const [DateTime.saturday, DateTime.sunday],
  }) {
    return weekendDays.contains(day.weekday);
  }
}

