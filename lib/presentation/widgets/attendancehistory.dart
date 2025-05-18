import 'package:employee_attendance_app/core/models/attendance_model.dart';
import 'package:employee_attendance_app/core/utils/app_colors.dart';
import 'package:employee_attendance_app/core/utils/app_style.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Attendancehistorycardstatus extends StatelessWidget {
  Size size;
  AttendanceModel? checkIn;
  IconData? icon;
  String cardname;
  String cardsubtitle;
  Attendancehistorycardstatus(
      this.size, this.checkIn, this.icon, this.cardname, this.cardsubtitle,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.width,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.all(size.width * .02),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              width: size.width * .1,
              height: size.width * .1,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: cardname == "Check In"
                    ? AppColors.subcardPrimary
                    : Color(0xffFE8B81),
              ),
              child: Icon(icon),
            ),
            SizedBox(
              width: 20,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cardname,
                    style: AppStyle.mediumtitle
                        .copyWith(fontSize: size.width * .03)),
                Text(
                    checkIn != null
                        ? DateFormat('MMM dd, yyyy ').format(checkIn!.timestamp)
                        : 'Not yet',
                    style: AppStyle.ligthtitle
                        .copyWith(fontSize: size.width * .03)),
              ],
            ),
            Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                    checkIn != null
                        ? DateFormat('hh:mm a').format(checkIn!.timestamp)
                        : 'Not yet',
                    style: AppStyle.mediumtitle
                        .copyWith(fontSize: size.width * .03)),
                Text(
                  "   $cardsubtitle",
                  style:
                      AppStyle.ligthtitle.copyWith(fontSize: size.width * .02),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
