import 'dart:io';

import 'package:employee_attendance_app/core/models/attendance_model.dart';
import 'package:employee_attendance_app/core/utils/app_colors.dart';
import 'package:employee_attendance_app/core/utils/app_style.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Attendancecardstatus extends StatelessWidget {
  Size size;
  AttendanceModel? checkIn;
  IconData? icon;
  String cardname;
  String cardsubtitle;
  String address;
  Attendancecardstatus(this.size, this.checkIn, this.icon, this.cardname,
      this.cardsubtitle, this.address,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.width * .40,
      height: size.width * .54,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.all(size.width * .02),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              children: [
                if (checkIn != null)
                  Container(
                    width: size.width * .15,
                    height: size.width * .15,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            fit: BoxFit.fill,
                            image: FileImage(File(checkIn!.imagePath)))),
                  ),
                Text(
                  "   $cardname",
                  style:
                      AppStyle.ligthtitle.copyWith(fontSize: size.width * .03),
                )
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Text(
                checkIn != null
                    ? DateFormat('hh:mm a').format(checkIn!.timestamp)
                    : 'Not yet',
                style:
                    AppStyle.mediumtitle.copyWith(fontSize: size.width * .06)),
            Text(
              address,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              style: AppStyle.ligthtitle.copyWith(fontSize: size.width * .03),
            ),
            Row(
              children: [
                Container(
                  width: size.width * .08,
                  height: size.width * .08,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: cardname == "Check In"
                        ? AppColors.subcardPrimary
                        : Color(0xffFE8B81),
                  ),
                  child: Icon(icon),
                ),
                Spacer(),
                Text(
                  cardsubtitle,
                  style:
                      AppStyle.ligthtitle.copyWith(fontSize: size.width * .03),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
