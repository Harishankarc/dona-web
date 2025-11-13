import 'dart:async';

import 'package:LeLaundrette/backend/apiservice.dart';
import 'package:LeLaundrette/controller/my_controller.dart';
import 'package:LeLaundrette/helpers/theme/admin_theme.dart';
import 'package:LeLaundrette/helpers/utils/mixins/ui_mixin.dart';
import 'package:LeLaundrette/helpers/widgets/my_button.dart';
import 'package:LeLaundrette/helpers/widgets/my_container.dart';
import 'package:LeLaundrette/helpers/widgets/my_list_extension.dart';
import 'package:LeLaundrette/helpers/widgets/my_spacing.dart';
import 'package:LeLaundrette/helpers/widgets/my_text.dart';
import 'package:LeLaundrette/helpers/widgets/my_text_style.dart';
import 'package:LeLaundrette/view/layouts/image_builder.dart';
import 'package:LeLaundrette/view/ui/data_table_inbuild_changed.dart' as table;
import 'package:LeLaundrette/view/ui/mult_select_dialog.dart';
import 'package:LeLaundrette/view/ui/permission_handler.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:mime/mime.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:universal_html/html.dart' as html;
import 'package:url_launcher/url_launcher.dart';

class IOUtils {
  static ContentTheme contentTheme = ContextTheme().contentTheme;
  static final outlineInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(3),
      borderSide: const BorderSide(width: 0.3));

  static IconData editIcon = LucideIcons.edit;
  static IconData viewIcon = LucideIcons.view;
  static IconData deleteIcon = LucideIcons.delete;

  static Widget dataTable<T>(
      List<String> head,
      List<Object Function(T value)> valueFuntions,
      List<T>? data,
      BuildContext context,
      {bool Function(T value)? isdefault,
      Color Function(T? value)? isDefaultcolor,
      bool isaction = false,
      bool showHeader = true,
      List<double>? columnWidthRatio,
      List<TableAction<T>>? actionList,
      double? actionwidth,
      int fontweight = 600}) {
    List<T> safeData = data ?? [];
    return LayoutBuilder(builder: (context, constrains) {
      return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: constrains.maxWidth > 700 ? constrains.maxWidth : 900,
            ),
            child: table.DataTable(
              sortAscending: true,
              columnSpacing: 30,
              onSelectAll: (_) => {},
              headingRowColor:
                  WidgetStatePropertyAll(contentTheme.primary.withAlpha(40)),
              dataRowMaxHeight: 40,
              dataRowMinHeight: 30,
              columnWidthList: List.filled(head.length, 1000 / head.length) +
                  [if (isaction) (actionwidth ?? 110)],
              showBottomBorder: true,
              headingRowHeight: showHeader ? 40 : 0, // ✅ Hide header height
              clipBehavior: Clip.antiAliasWithSaveLayer,
              border: TableBorder.all(
                borderRadius: BorderRadius.circular(8),
                style: BorderStyle.solid,
                width: .4,
                color: Colors.grey,
              ),

              // ✅ Always give columns — even when showHeader is false
              columns: [
                ...(head.isNotEmpty
                    ? head.map(
                        (e) => table.DataColumn(
                          label: showHeader
                              ? MyText.labelLarge(
                                  e,
                                  fontSize: 12,
                                  color: contentTheme.primary,
                                )
                              : const SizedBox.shrink(), // invisible but valid
                        ),
                      )
                    : [
                        table.DataColumn(
                          label: const SizedBox.shrink(),
                        )
                      ]),
                if (isaction)
                  table.DataColumn(
                    label: showHeader
                        ? MyText.labelLarge(
                            "Action",
                            fontSize: 12,
                            color: contentTheme.primary,
                          )
                        : const SizedBox.shrink(),
                  ),
              ],

              rows: safeData
                  .mapIndexed((index, d) => table.DataRow(
                        color: isdefault == null
                            ? null
                            : isdefault(d)
                                ? WidgetStatePropertyAll(isDefaultcolor == null
                                    ? contentTheme.success.withAlpha(100)
                                    : isDefaultcolor(d).withAlpha(100))
                                : null,
                        cells: [
                          ...valueFuntions.map((e) {
                            final a = e(d);
                            if (a is String) {
                              return table.DataCell(
                                MyText.labelMedium(
                                  a,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  fontSize: 11,
                                  fontWeight:
                                      fontweight == 600 ? 600 : fontweight,
                                ),
                              );
                            } else {
                              return table.DataCell(a as Widget);
                            }
                          }),
                          if (isaction)
                            table.DataCell(Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: actionList == null
                                  ? []
                                  : actionList.isEmpty
                                      ? []
                                      : List.generate(
                                          actionList.length +
                                              actionList.length -
                                              1,
                                          (index) {
                                            if (index.isOdd) {
                                              return const SizedBox(width: 5);
                                            } else {
                                              return (actionList[index ~/ 2]
                                                              .hideFuntion !=
                                                          null &&
                                                      actionList[index ~/ 2]
                                                          .hideFuntion!(d))
                                                  ? const SizedBox()
                                                  : (actionList[index ~/ 2]
                                                              .permission !=
                                                          null
                                                      ? PermissionHandler(
                                                          permission:
                                                              actionList[
                                                                      index ~/
                                                                          2]
                                                                  .permission
                                                                  .toString(),
                                                          child: MyContainer(
                                                            onTap: () async {
                                                              actionList[
                                                                      index ~/
                                                                          2]
                                                                  .function(d);
                                                            },
                                                            padding:
                                                                MySpacing.xy(
                                                                    8, 8),
                                                            color: actionList[
                                                                    index ~/ 2]
                                                                .color
                                                                .withAlpha(36),
                                                            child: Icon(
                                                              actionList[
                                                                      index ~/
                                                                          2]
                                                                  .iconData,
                                                              size: 14,
                                                              color: actionList[
                                                                      index ~/
                                                                          2]
                                                                  .color,
                                                            ),
                                                          ),
                                                        )
                                                      : MyContainer(
                                                          onTap: () async {
                                                            actionList[
                                                                    index ~/ 2]
                                                                .function(d);
                                                          },
                                                          padding: MySpacing.xy(
                                                              8, 8),
                                                          color: actionList[
                                                                  index ~/ 2]
                                                              .color
                                                              .withAlpha(36),
                                                          child: Icon(
                                                            actionList[
                                                                    index ~/ 2]
                                                                .iconData,
                                                            size: 14,
                                                            color: actionList[
                                                                    index ~/ 2]
                                                                .color,
                                                          ),
                                                        ));
                                            }
                                          },
                                        ),
                            )),
                        ],
                      ))
                  .toList(),
            ),
          ),
        ),
      );
    });
  }

  static Widget dateField(
    String title,
    String hintText,
    BuildContext context,
    Function(DateTime? value) onChanged,
    String Function(DateTime? value) dateFormat,
    DateTime? currentvalue, {
    DateTime? firstDate,
    DateTime? lastDate,
    bool onlybox = false,
    String note = '',
    Function(String msg, Color cl)? errormsg,
    bool readOnly = false,
    bool emptyOption = false,
  }) {
    return onlybox
        ? TextField(
            readOnly: true,
            controller: TextEditingController(
                text: currentvalue == null ? '' : dateFormat(currentvalue)),
            style: MyTextStyle.bodyMedium(fontWeight: 600, fontSize: 14),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: MyTextStyle.bodySmall(
                fontWeight: 500,
                fontSize: 12,
              ),
              contentPadding: MySpacing.xy(5, 3),
              border: outlineInputBorder,
              focusedBorder: outlineInputBorder,
              disabledBorder: outlineInputBorder,
              enabledBorder: outlineInputBorder,
            ),
            onTap: readOnly
                ? null
                : (emptyOption && currentvalue != null)
                    ? () {
                        onChanged(null);
                      }
                    : () {
                        showDatePicker(
                          context: context,
                          initialDate: currentvalue,
                          firstDate: firstDate ?? DateTime(1900),
                          lastDate: lastDate ?? DateTime(2100),
                        ).then((value) {
                          if (value != null) {
                            onChanged(value);
                          }
                        });
                      },
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title.isNotEmpty) ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MyText.bodySmall(
                      title,
                      fontWeight: 600,
                      fontSize: 11,
                    ),
                    if (note.isNotEmpty)
                      MyText.bodySmall(
                        "($note)",
                        fontWeight: 600,
                        fontSize: 8,
                      ),
                  ],
                ),
                MySpacing.height(4)
              ],
              MyContainer(
                  height: 35,
                  width: 260,
                  padding: MySpacing.xy(0, 0),
                  child: TextField(
                    readOnly: true,
                    controller: TextEditingController(
                        text: currentvalue == null
                            ? ''
                            : dateFormat(currentvalue)),
                    style:
                        MyTextStyle.bodyMedium(fontWeight: 600, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: hintText,
                      hintStyle: MyTextStyle.bodySmall(
                        fontWeight: 500,
                        fontSize: 12,
                      ),
                      contentPadding: MySpacing.xy(5, 3),
                      border: outlineInputBorder,
                      focusedBorder: outlineInputBorder,
                      disabledBorder: outlineInputBorder,
                      enabledBorder: outlineInputBorder,
                    ),
                    onTap: readOnly
                        ? null
                        : (emptyOption && currentvalue != null)
                            ? () {
                                onChanged(null);
                              }
                            : () {
                                showDatePicker(
                                  context: context,
                                  initialDate: currentvalue,
                                  firstDate: firstDate ?? DateTime(1900),
                                  lastDate: lastDate ?? DateTime(2100),
                                ).then((value) {
                                  if (value != null) {
                                    onChanged(value);
                                  }
                                });
                              },
                  )),
            ],
          );
  }

  static Widget dataTable2<T>(List<String> header, List<T> data,
      List<Object Function(T value)> valueFuntions) {
    return Column(
      children: [
        MyContainer.bordered(
            paddingAll: 0,
            borderColor: const Color.fromARGB(255, 179, 179, 179),
            height: 45,
            child: Row(
                children: List.generate((header.length * 2) - 1, (index) {
              return index.isEven
                  ? Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: MyText.bodySmall(
                          header[index ~/ 2],
                          fontWeight: 700,
                          fontSize: 12,
                        ),
                      ),
                    )
                  : const SizedBox(
                      height: 40,
                      child: VerticalDivider(
                        color: Color.fromARGB(255, 179, 179, 179),
                      ));
            }))),
        ...List.generate(data.length, (ind) {
          return MyContainer.bordered(
            paddingAll: 0,
            borderColor: const Color.fromARGB(255, 179, 179, 179),
            child: Row(
              children: List.generate((valueFuntions.length * 2) - 1, (index) {
                dynamic d = '';
                if (index.isEven) {
                  d = valueFuntions[index ~/ 2](data[ind]);
                }
                return index.isEven
                    ? Expanded(
                        child: d is Widget
                            ? d
                            : Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: MyText.bodySmall(
                                  d.toString(),
                                  fontWeight: 500,
                                  fontSize: 12,
                                ),
                              ),
                      )
                    : const SizedBox(
                        height: 40,
                        child: VerticalDivider(
                          color: Color.fromARGB(255, 179, 179, 179),
                        ));
              }),
            ),
          );
        }),
      ],
    );
  }

  static Widget timeField(
      String title,
      String hintText,
      BuildContext context,
      Function(TimeOfDay? value) onChanged,
      String Function(TimeOfDay? value) timeFormat,
      TimeOfDay? currentvalue,
      {TimeOfDay? firstDate,
      TimeOfDay? lastDate,
      bool onlybox = false,
      bool borderless = false,
      String note = '',
      bool clearButton = false,
      bool readOnly = false}) {
    return onlybox
        ? TextField(
            readOnly: true,
            controller: TextEditingController(
                text: currentvalue == null ? '' : timeFormat(currentvalue)),
            style: MyTextStyle.bodyMedium(fontWeight: 600, fontSize: 14),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: MyTextStyle.bodySmall(
                fontWeight: 500,
                fontSize: 12,
              ),
              contentPadding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              border: borderless
                  ? const OutlineInputBorder(borderSide: BorderSide.none)
                  : outlineInputBorder,
              focusedBorder: borderless
                  ? const OutlineInputBorder(borderSide: BorderSide.none)
                  : outlineInputBorder,
              disabledBorder: borderless
                  ? const OutlineInputBorder(borderSide: BorderSide.none)
                  : outlineInputBorder,
              enabledBorder: borderless
                  ? const OutlineInputBorder(borderSide: BorderSide.none)
                  : outlineInputBorder,
            ),
            onTap: () {
              if (readOnly) {
                return;
              }
              if (clearButton && currentvalue != null) {
                onChanged(null);
                return;
              }
              showTimePicker(
                context: context,
                initialTime: currentvalue ?? TimeOfDay.now(),
              ).then((value) {
                if (value != null) {
                  onChanged(value);
                }
              });
            },
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title.isNotEmpty) ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MyText.bodySmall(
                      title,
                      fontWeight: 600,
                      fontSize: 11,
                    ),
                    if (note.isNotEmpty)
                      MyText.bodySmall(
                        "($note)",
                        fontWeight: 600,
                        fontSize: 8,
                      ),
                  ],
                ),
                MySpacing.height(4)
              ],
              MyContainer(
                  height: 35,
                  width: 260,
                  padding: MySpacing.xy(0, 0),
                  child: TextField(
                    readOnly: true,
                    controller: TextEditingController(
                        text: currentvalue == null
                            ? ''
                            : timeFormat(currentvalue)),
                    style:
                        MyTextStyle.bodyMedium(fontWeight: 600, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: hintText,
                      hintStyle: MyTextStyle.bodySmall(
                        fontWeight: 500,
                        fontSize: 12,
                      ),
                      contentPadding: MySpacing.xy(5, 3),
                      border: outlineInputBorder,
                      focusedBorder: outlineInputBorder,
                      disabledBorder: outlineInputBorder,
                      enabledBorder: outlineInputBorder,
                    ),
                    onTap: () {
                      if (readOnly) {
                        return;
                      }
                      if (clearButton && currentvalue != null) {
                        onChanged(null);
                        return;
                      }
                      showTimePicker(
                        context: context,
                        initialTime: currentvalue ?? TimeOfDay.now(),
                      ).then((value) {
                        if (value != null) {
                          onChanged(value);
                        }
                      });
                    },
                  )),
            ],
          );
  }

  static Widget fields(
      String title, String hintText, TextEditingController textcontroller,
      {List<TextInputFormatter>? inputFormatters,
      TextInputType? keyboardType,
      Function(String value)? onSubmitted,
      Function(String value)? onChanged,
      bool readOnly = false,
      bool onlybox = false,
      bool borderless = false,
      double? height,
      double? width,
      bool? filled,
      Color? fillcolor,
      int? minlines,
      int? maxlines,
      String note = ''}) {
    return onlybox
        ? MyContainer(
            height: height == -1 ? null : height ?? 35,
            width: width == -1 ? null : width ?? 260,
            padding: MySpacing.xy(0, 0),
            child: TextField(
              readOnly: readOnly,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              controller: textcontroller,
              minLines: minlines,
              maxLines: maxlines,
              style: MyTextStyle.bodyMedium(fontWeight: 600, fontSize: 14),
              decoration: InputDecoration(
                fillColor: fillcolor,
                hintText: hintText,
                filled: filled,
                hintStyle: MyTextStyle.bodySmall(
                  fontWeight: 500,
                  fontSize: 12,
                ),
                contentPadding: MySpacing.xy(5, 3),
                border: borderless
                    ? OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(0))
                    : outlineInputBorder,
                focusedBorder: borderless
                    ? OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(0))
                    : outlineInputBorder,
                disabledBorder: borderless
                    ? OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(0))
                    : outlineInputBorder,
                enabledBorder: borderless
                    ? OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(0))
                    : outlineInputBorder,
              ),
              onSubmitted: onSubmitted,
              onChanged: onChanged,
            ),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title.isNotEmpty) ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MyText.bodySmall(
                      title,
                      fontWeight: 600,
                      fontSize: 11,
                    ),
                    if (note.isNotEmpty)
                      MyText.bodySmall(
                        "($note)",
                        fontWeight: 600,
                        fontSize: 8,
                      ),
                  ],
                ),
                MySpacing.height(4)
              ],
              MyContainer(
                height: height == -1
                    ? null
                    : maxlines != null || minlines != null
                        ? null
                        : height ?? 35,
                width: width == -1 ? null : width ?? 260,
                padding: MySpacing.xy(0, 0),
                child: TextField(
                  keyboardType: keyboardType,
                  minLines: minlines,
                  maxLines: maxlines,
                  readOnly: readOnly,
                  inputFormatters: inputFormatters,
                  controller: textcontroller,
                  style: MyTextStyle.bodyMedium(fontWeight: 600, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: MyTextStyle.bodySmall(
                      fontWeight: 500,
                      fontSize: 12,
                    ),
                    contentPadding: maxlines != null || minlines != null
                        ? MySpacing.all(10)
                        : MySpacing.xy(5, 3),
                    border: borderless
                        ? OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(0))
                        : outlineInputBorder,
                    focusedBorder: borderless
                        ? OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(0))
                        : outlineInputBorder,
                    disabledBorder: borderless
                        ? OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(0))
                        : outlineInputBorder,
                    enabledBorder: borderless
                        ? OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(0))
                        : outlineInputBorder,
                  ),
                  onSubmitted: onSubmitted,
                  onChanged: onChanged,
                ),
              ),
            ],
          );
  }

  static Widget documetUploadField(
      String title,
      String hintText1,
      String hintText2,
      PlatformFile? currentvalue,
      void Function(PlatformFile? value) setValue,
      {bool isImage = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText.bodySmall(
          title,
          fontWeight: 600,
          fontSize: 11,
        ),
        MySpacing.height(4),
        SizedBox(
          width: 260,
          height: 35,
          child: Row(
            children: [
              SizedBox(
                width: currentvalue == null ? 260 : 160,
                height: 35,
                child: MyButton.block(
                    elevation: 0,
                    borderRadiusAll: 5,
                    onPressed: () async {
                      FilePickerResult? result = await FilePicker.platform
                          .pickFiles(
                              type: isImage ? FileType.image : FileType.any,
                              allowCompression: true);

                      if (result != null) {
                        PlatformFile file = result.files.first;
                        setValue(file);
                      } else {
                        setValue(null);
                      }
                    },
                    backgroundColor: contentTheme.primary,
                    child: MyText.bodySmall(
                      currentvalue != null ? hintText2 : hintText1,
                      fontWeight: 600,
                      color: contentTheme.onPrimary,
                    )),
              ),
              if (currentvalue != null) ...[
                MySpacing.width(5),
                SizedBox(
                  width: 40,
                  height: 30,
                  child: MyButton.block(
                      elevation: 0,
                      padding: MySpacing.all(5),
                      borderRadiusAll: 5,
                      onPressed: () async {
                        setValue(null);
                      },
                      backgroundColor: contentTheme.primary,
                      child: Center(
                        child: Icon(
                          LucideIcons.x,
                          color: contentTheme.onPrimary,
                          size: 14,
                        ),
                      )),
                ),
                MySpacing.width(5),
                SizedBox(
                  width: 50,
                  height: 30,
                  child: MyButton.block(
                      elevation: 0,
                      padding: MySpacing.all(5),
                      borderRadiusAll: 5,
                      onPressed: () async {
                        isImage
                            ? showDialog(
                                context: Get.context!,
                                builder: (context) {
                                  return SizedBox(
                                    width: 600,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 600,
                                          color: contentTheme.onPrimary,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  Get.back();
                                                },
                                                child: Icon(
                                                  LucideIcons.x,
                                                  color: contentTheme.primary,
                                                  weight: 50,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          width: 600,
                                          child: currentvalue.size != 0
                                              ? ImageBuilder(
                                                  bytes: currentvalue.bytes,
                                                  isPath: true,
                                                )
                                              : ImageBuilder(
                                                  imageuri: APIService.imageUrl(
                                                      currentvalue.name),
                                                ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              )
                            : currentvalue.size == 0
                                ? launchUrl(Uri.parse(
                                    APIService.imageUrl(currentvalue.name)))
                                : launchLocalFile(
                                    currentvalue.bytes!, currentvalue.name);
                      },
                      backgroundColor: contentTheme.primary,
                      child: Center(
                        child: Icon(
                          LucideIcons.eye,
                          color: contentTheme.onPrimary,
                        ),
                      )),
                ),
              ]
            ],
          ),
        ),
      ],
    );
  }

  static void launchLocalFile(Uint8List bytes, String filename) async {
    final mimtype = lookupMimeType(filename);
    final blob = html.Blob([bytes], mimtype);
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.WindowBase? newTab = html.window.open(url, '_blank');
    Future.delayed(const Duration(seconds: 5), () {
      html.Url.revokeObjectUrl(url);
    });
  }

  static Widget typeAheadField<T>(
      String title,
      String hinttext,
      FutureOr<List<T>> Function(String value) suggestionsCallback,
      Function(T? value) setValue,
      String Function(T? value) buildertext,
      T? currentvalue,
      {bool isautofocus = false,
      bool readOnly = false,
      bool onlybox = false,
      bool borderless = false,
      Widget Function(T? value)? searchSuffix,
      double? height,
      double? width,
      bool Function(T? value)? emptyFuntion,
      SuggestionsController<T>? suggestionsController}) {
    suggestionsController = suggestionsController ?? SuggestionsController();
    return onlybox
        ? SizedBox(
            height: height ?? 35,
            width: width ?? 260,
            child: ((emptyFuntion != null && emptyFuntion(currentvalue)) ||
                    currentvalue == null)
                ? TypeAheadField<T>(
                    onSelected: (value) {
                      setValue(value);
                    },
                    suggestionsController: suggestionsController,
                    controller: TextEditingController(),
                    hideOnEmpty: true,
                    builder: (context, controller, focusNode) {
                      return TextField(
                          expands: true,
                          readOnly: readOnly,
                          maxLines: null,
                          minLines: null,
                          controller: controller,
                          focusNode: focusNode,
                          autofocus: isautofocus,
                          style: MyTextStyle.bodyMedium(),
                          decoration: InputDecoration(
                            hintText: hinttext,
                            suffixIcon: searchSuffix == null
                                ? null
                                : searchSuffix(currentvalue),
                            hintStyle: MyTextStyle.bodySmall(
                              fontWeight: 500,
                              fontSize: 12,
                            ),
                            isDense: true,
                            contentPadding: MySpacing.xy(5, 3),
                            border: borderless
                                ? const OutlineInputBorder(
                                    borderSide: BorderSide.none)
                                : outlineInputBorder,
                            focusedBorder: borderless
                                ? const OutlineInputBorder(
                                    borderSide: BorderSide.none)
                                : outlineInputBorder,
                            disabledBorder: borderless
                                ? const OutlineInputBorder(
                                    borderSide: BorderSide.none)
                                : outlineInputBorder,
                            enabledBorder: borderless
                                ? const OutlineInputBorder(
                                    borderSide: BorderSide.none)
                                : outlineInputBorder,
                          ));
                    },
                    suggestionsCallback: readOnly
                        ? (String? value) {
                            suggestionsController!.refresh();
                            return [];
                          }
                        : suggestionsCallback,
                    itemBuilder: (context, data) {
                      return ListTile(
                        title: Text(
                          buildertext(data),
                          overflow: TextOverflow.ellipsis,
                          softWrap: false,
                          maxLines: 1,
                          style: MyTextStyle.bodyMedium(),
                        ),
                      );
                    },
                  )
                : GestureDetector(
                    onTap: () => readOnly ? null : setValue(null),
                    child: Container(
                      decoration: borderless
                          ? null
                          : BoxDecoration(
                              borderRadius: outlineInputBorder.borderRadius,
                              border: Border.all(
                                  width: 0.3,
                                  color: outlineInputBorder.borderSide.color)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              buildertext(currentvalue),
                              overflow: TextOverflow.ellipsis,
                              style: MyTextStyle.bodyMedium(
                                fontWeight: 600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ))
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyText.bodySmall(
                title,
                fontWeight: 600,
                fontSize: 11,
              ),
              MySpacing.height(4),
              SizedBox(
                  height: 35,
                  width: 260,
                  child: (emptyFuntion != null && emptyFuntion(currentvalue)) ||
                          currentvalue == null
                      ? TypeAheadField<T>(
                          onSelected: (value) {
                            setValue(value);
                          },
                          suggestionsController: suggestionsController,
                          controller: TextEditingController(),
                          hideOnEmpty: true,
                          builder: (context, controller, focusNode) {
                            return TextField(
                                expands: true,
                                readOnly: readOnly,
                                maxLines: null,
                                minLines: null,
                                controller: controller,
                                focusNode: focusNode,
                                autofocus: isautofocus,
                                style: MyTextStyle.bodyMedium(),
                                decoration: InputDecoration(
                                  hintText: hinttext,
                                  hintStyle: MyTextStyle.bodySmall(
                                    fontWeight: 500,
                                    fontSize: 12,
                                  ),
                                  isDense: true,
                                  contentPadding: MySpacing.xy(5, 3),
                                  border: outlineInputBorder,
                                  focusedBorder: outlineInputBorder,
                                  disabledBorder: outlineInputBorder,
                                  enabledBorder: outlineInputBorder,
                                ));
                          },
                          suggestionsCallback: readOnly
                              ? (String? value) => []
                              : suggestionsCallback,
                          itemBuilder: (context, data) {
                            return ListTile(
                              title: Text(
                                buildertext(data),
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                                maxLines: 1,
                                style: MyTextStyle.bodyMedium(),
                              ),
                            );
                          },
                        )
                      : GestureDetector(
                          onTap: () => readOnly ? null : setValue(null),
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: outlineInputBorder.borderRadius,
                                border: Border.all(
                                    width: 0.3,
                                    color:
                                        outlineInputBorder.borderSide.color)),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    buildertext(currentvalue),
                                    style: MyTextStyle.bodyMedium(
                                      fontWeight: 600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )),
            ],
          );
  }

  static Widget statusBox(
      String title, String hintText, String value, Color valuecolor,
      {bool borderless = false,
      double? height,
      double? width,
      bool? filled,
      Color? fillcolor,
      String note = ''}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty) ...[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              MyText.bodySmall(
                title,
                fontWeight: 600,
                fontSize: 11,
              ),
              if (note.isNotEmpty)
                MyText.bodySmall(
                  "($note)",
                  fontWeight: 600,
                  fontSize: 8,
                ),
            ],
          ),
          MySpacing.height(4)
        ],
        MyContainer(
            height: height == -1 ? null : height ?? 35,
            width: width == -1 ? null : width ?? 260,
            padding: MySpacing.xy(0, 0),
            child: InputDecorator(
              decoration: InputDecoration(
                fillColor: fillcolor,
                hintText: hintText,
                filled: filled,
                hintStyle: MyTextStyle.bodySmall(
                  fontWeight: 500,
                  fontSize: 12,
                ),
                contentPadding: MySpacing.xy(5, 3),
                border: borderless
                    ? OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(0))
                    : outlineInputBorder,
                focusedBorder: borderless
                    ? OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(0))
                    : outlineInputBorder,
                disabledBorder: borderless
                    ? OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(0))
                    : outlineInputBorder,
                enabledBorder: borderless
                    ? OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(0))
                    : outlineInputBorder,
              ),
              child: Text(
                value,
                style: MyTextStyle.bodyMedium(
                    fontWeight: 600, fontSize: 14, color: valuecolor),
              ),
            )),
      ],
    );
  }

  static void showPopForMultiSelect<T>(
      String title,
      FutureOr<List<T>> Function() items,
      List<T> initialvalue,
      void Function(List<T>) pressfunction,
      bool Function(T value1, List<T> value2) matchingFuntion,
      String Function(T value) labelFuntion,
      BuildContext context) async {
    await showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(0),
          child: SizedBox(
            child: PopUpMultiSelect(
              title: title,
              items: items,
              initialvalue: initialvalue,
              labelFuntion: labelFuntion,
              matchingFuntion: matchingFuntion,
              pressfunction: pressfunction,
            ),
          ),
        );
      },
    );
  }

  static Widget popupMultiSelect<T>(
      String title,
      String hinttext,
      String popuptitle,
      FutureOr<List<T>> Function() items,
      List<T> currentvalues,
      String Function(List<T> values) labelFuntion,
      void Function(List<T> values) setvalue,
      bool Function(T value, List<T> value2) filteringValuesFuntion,
      String Function(T value) popupItemLabelFuntion,
      BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      MyText.bodySmall(
        title,
        fontWeight: 600,
        fontSize: 11,
      ),
      MySpacing.height(4),
      MyContainer(
          height: 35,
          width: 260,
          padding: MySpacing.xy(0, 0),
          child: GestureDetector(
            onTap: () {
              showPopForMultiSelect<T>(
                  popuptitle,
                  items,
                  currentvalues,
                  setvalue,
                  filteringValuesFuntion,
                  popupItemLabelFuntion,
                  context);
            },
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: outlineInputBorder.borderRadius,
                  border: Border.all(
                      width: 0.3, color: outlineInputBorder.borderSide.color)),
              child: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 248,
                      child: Text(
                        currentvalues.isEmpty
                            ? hinttext
                            : labelFuntion(currentvalues),
                        overflow: TextOverflow.ellipsis,
                        style: currentvalues.isEmpty
                            ? MyTextStyle.bodySmall(
                                fontWeight: 500,
                                fontSize: 12,
                              )
                            : MyTextStyle.bodyMedium(
                                fontWeight: 600, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ))
    ]);
  }

  static Widget checkBoxfield(String title, String subtitle, bool value,
      Function(bool? value) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            MyText.bodySmall(
              title,
              fontWeight: 600,
              fontSize: 11,
            ),
          ],
        ),
        MySpacing.height(4),
        SizedBox(
            height: 35,
            width: 260,
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: outlineInputBorder.borderRadius,
                  border: Border.all(
                      width: 0.3, color: outlineInputBorder.borderSide.color)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Checkbox(
                        side: outlineInputBorder.borderSide,
                        fillColor: value
                            ? WidgetStatePropertyAll(contentTheme.success)
                            : WidgetStatePropertyAll(contentTheme.onSuccess),
                        checkColor: contentTheme.onSuccess,
                        value: value,
                        onChanged: onChanged),
                    MySpacing.width(5),
                    SizedBox(
                      width: 200,
                      child: AutoSizeText(
                        title,
                        style: MyTextStyle.bodySmall(),
                      ),
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  static Widget fileUploadfield(String title, PlatformFile? filecontroller,
      void Function(PlatformFile? vlaue) setValue, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title.isNotEmpty) ...[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              MyText.bodySmall(
                title,
                fontWeight: 600,
                fontSize: 11,
              ),
            ],
          ),
          MySpacing.height(4)
        ],
        Container(
          height: 35,
          width: 260,
          decoration: BoxDecoration(
              borderRadius: outlineInputBorder.borderRadius,
              border: Border.all(
                  width: 0.3, color: outlineInputBorder.borderSide.color)),
          child: filecontroller == null
              ? MyButton(
                  onPressed: () async {
                    FilePickerResult? result =
                        await FilePicker.platform.pickFiles();

                    if (result != null) {
                      setValue(result.files.first);
                    } else {
                      setValue(null);
                    }
                  },
                  elevation: 0,
                  borderRadiusAll: 4,
                  backgroundColor: contentTheme.primary,
                  child: Center(
                    child: MyText.labelMedium(
                      "Upload File",
                      fontWeight: 600,
                      color: contentTheme.onPrimary,
                    ),
                  ),
                )
              : GestureDetector(
                  onTap: () => setValue(null),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                            child: MyText.bodyMedium(
                          filecontroller.name,
                          overflow: TextOverflow.ellipsis,
                          style: MyTextStyle.bodyMedium(
                            fontWeight: 600,
                            fontSize: 14,
                          ),
                        )),
                        MyButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return SizedBox(
                                  width: 600,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 600,
                                        color: contentTheme.onPrimary,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                Get.back();
                                              },
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(20.0),
                                                child: Icon(
                                                  LucideIcons.x,
                                                  color: contentTheme.primary,
                                                  weight: 50,
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: 600,
                                        child: filecontroller.size == 0
                                            ? ImageBuilder(
                                                imageuri: APIService.imageUrl(
                                                    filecontroller.name),
                                              )
                                            : ImageBuilder(
                                                bytes: filecontroller.bytes,
                                                isPath: true,
                                              ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          elevation: 0,
                          borderRadiusAll: 8,
                          backgroundColor: contentTheme.primary,
                          child: Icon(
                            LucideIcons.eye,
                            color: contentTheme.onPrimary,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  static Widget loadingWidget() {
    return SizedBox(
      height: 100,
      width: 100,
      child: LoadingAnimationWidget.dotsTriangle(
          color: contentTheme.primary, size: 40),
    );
  }

  static void toastMessage(String text, Color color, BuildContext context,
      AnimationController animcontroller) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 0,
      shape: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: color)),
      width: 300,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(milliseconds: 1200),
      animation: Tween<double>(begin: 0, end: 300).animate(animcontroller),
      content: MyText.labelLarge(text, fontWeight: 600, color: color),
      backgroundColor: contentTheme.background,
    ));
  }
}

class ContextTheme with UIMixin {}

class PopUpMultiSelectController<T> extends MyController {
  bool loading = false;
  List<T> dataitems = [];
  void changeLoading(bool value) {
    loading = value;
    update();
  }

  Future<void> fetchdata(FutureOr<List<T>> Function() items) async {
    changeLoading(true);
    dataitems = await items();
    changeLoading(false);
  }
}

// ignore: must_be_immutable
class PopUpMultiSelect<T> extends StatefulWidget {
  String title;
  FutureOr<List<T>> Function() items;
  List<T> initialvalue;
  void Function(List<T>) pressfunction;
  bool Function(T value1, List<T> value2) matchingFuntion;
  String Function(T value) labelFuntion;
  PopUpMultiSelect({
    super.key,
    required this.title,
    required this.items,
    required this.initialvalue,
    required this.pressfunction,
    required this.matchingFuntion,
    required this.labelFuntion,
  });

  @override
  State<PopUpMultiSelect> createState() => _PopUpMultiSelectState<T>();
}

class _PopUpMultiSelectState<T> extends State<PopUpMultiSelect<T>>
    with TickerProviderStateMixin, UIMixin {
  PopUpMultiSelectController<T> controller = PopUpMultiSelectController<T>();

  @override
  Widget build(BuildContext context) {
    controller.fetchdata(widget.items);
    return GetBuilder(
        init: controller,
        tag: 'popup_controller',
        builder: (controller) {
          return controller.loading
              ? Container(
                  decoration: BoxDecoration(color: contentTheme.cardBackground),
                  width: 100,
                  height: 100,
                  child: IOUtils.loadingWidget())
              : MultiSelectDialog<T>(
                  checkingFunction: widget.matchingFuntion,
                  height: 400,
                  width: MediaQuery.of(context).size.width * 0.20,
                  selectedColor: contentTheme.checkbox,
                  title: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          MyText.titleMedium(widget.title, fontWeight: 600),
                        ],
                      ),
                      MySpacing.height(5),
                      const Divider(),
                      MySpacing.height(5),
                    ],
                  ),
                  cancelText: Text(
                    "Close",
                    style: MyTextStyle.titleSmall(color: contentTheme.danger),
                  ),
                  confirmText: Text(
                    "Done",
                    style: MyTextStyle.titleSmall(color: contentTheme.success),
                  ),
                  itemsTextStyle: MyTextStyle.titleSmall(),
                  selectedItemsTextStyle: MyTextStyle.titleSmall(),
                  items: controller.dataitems
                      .map((e) => MultiSelectItem(e, widget.labelFuntion(e)))
                      .toList(),
                  initialValue: widget.initialvalue,
                  onConfirm: widget.pressfunction);
        });
  }
}

class TableAction<T> {
  final String? permission;
  final Function(T data) function;
  final Color color;
  final IconData iconData;
  final bool Function(T data)? hideFuntion;

  TableAction(
      {required this.function,
      required this.iconData,
      required this.color,
      this.permission,
      this.hideFuntion});
}
