import 'package:flutter/material.dart';
import 'package:scrollable_bottomsheet_datepicker/scrollable_bottomsheet_datepicker.dart';
import 'package:intl/intl.dart';
import "package:jiffy/jiffy.dart";

class BasicCalender extends StatefulWidget {
  @override
  _BasicCalenderState createState() => _BasicCalenderState();
}

class _BasicCalenderState extends State<BasicCalender> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool doff = true;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ValueNotifier(_focusedDay);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('TableCalendar - Basics'),
        ),
        body: TableCalendar(
          LeftIcon: Image(image: AssetImage("assets/left_chevron.png")),
          RightIcon: Image(
                  image: AssetImage("assets/right_chevron.png"),
                 ),

          firstDay: DateTime.utc(2000, 01, 01),
          lastDay: DateTime.utc(2100, 01, 01),
          focusedDay: _focusedDay,
          calendarFormat: _calendarFormat,
          leftchevronsize: 12,
          rightchevronsize: 12,
          calendarStyle: CalendarStyle(
              defaultTextStyle:
                  TextStyle(color: Color(0xff555555), fontSize: 14.0, fontFamily: "Gordita",fontWeight: FontWeight.w500),
              // defaultTextStyle: TextStyle(color: Color(0xffa5a5a5)),
              disabledTextStyle: const TextStyle(color: Color(0xff555555),fontSize: 14.0, fontFamily: "Gordita",fontWeight: FontWeight.w500),
              weekendTextStyle: TextStyle(color: Color(0xff555555),fontSize: 14.0, fontFamily: "Gordita",fontWeight: FontWeight.w500),
              selectedDecoration: BoxDecoration(
                  
                  color: Color(0xff007fbb), 
                  shape: BoxShape.circle
                  ),
              isTodayHighlighted: doff,
              todayDecoration: BoxDecoration(
                  color: Color(0xff007fbb), shape: BoxShape.circle)),
          headerStyle: HeaderStyle(
              headerMargin: EdgeInsets.only(left: 10),
              formatButtonVisible: false,
              // leftChevronMargin: EdgeInsets.only(left: 50),
              // rightChevronMargin: EdgeInsets.only(right: 10),
              leftChevronPadding: EdgeInsets.all(0),
              rightChevronPadding: EdgeInsets.all(0)),
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            
            if (!isSameDay(_selectedDay, selectedDay)) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
                doff = false;
              });
              
            }
          },
          daysOfWeekStyle: DaysOfWeekStyle(
              weekendStyle:
                  TextStyle(color: Color(0xffa5a5a5), fontFamily: "Gordita"),
              weekdayStyle:
                  TextStyle(color: Color(0xffa5a5a5), fontFamily: "Gordita"),
              dowTextFormatter: ((date, locale) {
                return "${(DateFormat('E').format(date).toUpperCase())}";
              })),
          onFormatChanged: (format) {
            
            if (_calendarFormat != format) {
              setState(() {
                _calendarFormat = format;
              });
            }
          },
          onHeaderTapped: (focusedDay) {
          
            setState(() {
              DValue[0]["Month"] =
                  Jiffy(focusedDay, "yyyy-mm-dd mm:hh:ssZ").format("MMMM");
              DValue[0]["Year"] = Jiffy(focusedDay, "yyyy-mm-dd mm:hh:ssZ")
                  .format("yyyy")
                  .toString();
            });
          },
          onPageChanged: (focusedDay) {
            setState(() {
              _focusedDay = focusedDay;
            });

            ValueNotifier(_focusedDay);
          },
        ),
      ),
    );
  }
}
