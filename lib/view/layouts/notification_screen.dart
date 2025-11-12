import 'package:LeLaundrette/helpers/utils/mixins/ui_mixin.dart';
import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> with UIMixin {
  double heightCon = 0;
  // Future<List<NotificationModel>> future = APIService.getNotifications(
  //     LocalStorage.getLoggedUserdata().id.toString());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        heightCon = 300;
      });
      // future = APIService.getNotifications(
      //     LocalStorage.getLoggedUserdata().id.toString());
      setState(() {});
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() {
        heightCon = 0;
      });
    });

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: contentTheme.cardBackground,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: contentTheme.cardBorder),
        ),
        width: 400,
        height: heightCon,
        // child: Column(
        //   crossAxisAlignment: CrossAxisAlignment.start,
        //   children: [
        //     Padding(
        //       padding: const EdgeInsets.all(10.0),
        //       child: MyText.bodyMedium(
        //         'Notifications',
        //         fontWeight: 800,
        //       ),
        //     ),
        //     Expanded(
        //       child: FutureBuilder<List<NotificationModel>>(
        //           future: future,
        //           builder: (_, snapshot) {
        //             if (snapshot.connectionState == ConnectionState.waiting) {
        //               return Center(
        //                 child: LoadingAnimationWidget.dotsTriangle(
        //                     color: contentTheme.primary, size: 40),
        //               );
        //             }
        //             final data = snapshot.data ?? [];
        //             print(data.map((e) => e.toJson()).toList());
        //             return snapshot.hasData
        //                 ? ListView.separated(
        //                     itemBuilder: (_, index) {
        //                       return Padding(
        //                         padding: const EdgeInsets.all(10.0),
        //                         child: SizedBox(
        //                             child: Row(
        //                           children: [
        //                             CircleAvatar(
        //                               radius: 14,
        //                               backgroundColor: contentTheme.onWarning,
        //                               child: Icon(
        //                                 LucideIcons.bellDot,
        //                                 color: contentTheme.warning,
        //                                 size: 14,
        //                               ),
        //                             ),
        //                             MySpacing.width(24),
        //                             Column(
        //                               crossAxisAlignment:
        //                                   CrossAxisAlignment.start,
        //                               children: [
        //                                 MyText.bodySmall(
        //                                   '[${data[index].functionName}] ${data[index].title}',
        //                                   fontWeight: 600,
        //                                 ),
        //                                 MyText.bodySmall(
        //                                   data[index].message,
        //                                 ),
        //                               ],
        //                             ),
        //                           ],
        //                         )),
        //                       );
        //                     },
        //                     itemCount: snapshot.data!.length,
        //                     separatorBuilder: (_, index) => const Padding(
        //                       padding: EdgeInsets.symmetric(horizontal: 40),
        //                       child: Divider(
        //                         height: 0,
        //                       ),
        //                     ),
        //                   )
        //                 : const SizedBox();
        //           }),
        //     ),
        //   ],
        // ),
      ),
    );
  }
}
