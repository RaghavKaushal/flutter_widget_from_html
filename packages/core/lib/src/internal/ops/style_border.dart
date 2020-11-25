import 'package:flutter/widgets.dart';

import '../../core_data.dart';
import '../../core_helpers.dart';
import '../../core_widget_factory.dart';
import '../core_parser.dart';

const kCssBoxSizing = 'box-sizing';
const kCssBoxSizingContentBox = 'content-box';
const kCssBoxSizingBorderBox = 'border-box';

class StyleBorder {
  static const kPriorityBoxModel7k = 7000;

  final WidgetFactory wf;

  static final _skipBuilding = Expando<bool>();

  StyleBorder(this.wf);

  BuildOp get buildOp => BuildOp(
        onTree: (meta, tree) {
          if (meta.willBuildSubtree) return;
          final border = tryParseBorder(meta);
          if (border == null) return;

          _skipBuilding[meta] = true;
          final copied = tree.copyWith() as BuildTree;
          final built = wf
              .buildColumnPlaceholder(meta, copied.build())
              ?.wrapWith((context, child) =>
                  _buildBorder(meta, context, child, border));
          if (built == null) return;

          tree.replaceWith(WidgetBit.inline(tree, built));
        },
        onWidgets: (meta, widgets) {
          if (_skipBuilding[meta] == true || widgets?.isNotEmpty != true) {
            return widgets;
          }
          final border = tryParseBorder(meta);
          if (border == null) return widgets;

          _skipBuilding[meta] = true;
          return listOrNull(wf.buildColumnPlaceholder(meta, widgets)?.wrapWith(
              (context, child) => _buildBorder(meta, context, child, border)));
        },
        onWidgetsIsOptional: true,
        priority: kPriorityBoxModel7k,
      );

  Widget _buildBorder(
    BuildMetadata meta,
    BuildContext context,
    Widget child,
    CssBorder border,
  ) {
    final tsh = meta.tsb().build(context);
    return wf.buildBorder(
      meta,
      child,
      border.getValue(tsh),
      isBorderBox: meta[kCssBoxSizing] == kCssBoxSizingBorderBox,
    );
  }
}