// ignore_for_file: public_member_api_docs, always_specify_types, prefer_const_constructors, prefer_single_quotes, inference_failure_on_function_invocation, use_raw_strings

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

class ExtendedMarkdown extends StatelessWidget {
  const ExtendedMarkdown({super.key});

  @override
  Widget build(BuildContext context) {
    final md = MarkdownBody(
//       data: '''
// # Extended **Markdown** *Test*
// ## Extended **Markdown** *Test*
// ### Extended **Markdown** *Test*
// #### Extended **Markdown** *Test*
// ##### Extended **Markdown** *Test*

// **Why** *does* theirs work??

// ---

// Text here
// <br/>
// Text there

// Some text <style color="primary">with style</style> and some text without. **This** should
// keep on going and not break after the style

// Some text with a <tooltip value="This is a tooltip">tooltip</tooltip> and some text without. This should
// keep on going and not break after the tooltip
// ''',
      data: '''
  Some text with a <tooltip value="This is a tooltip">tooltip</tooltip> and some *text* without. When it wraps, we lose the text...
''',
      blockSyntaxes: const [
        _BrSyntax(),
      ],
      styleSheet: MarkdownStyleSheet(
        horizontalRulePadding: const EdgeInsets.symmetric(vertical: 24),
      ),
      builders: <String, MarkdownElementBuilder>{
        'br': _BrBuilder(),
        'tooltip': _TooltipBuilder(context: context),
        'style': _StyleBuilder(),
      },
      inlineSyntaxes: [
        _TagSyntax('style'),
        _TagSyntax('tooltip'),
      ],
      otherBlockTags: const {'br'},
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Extended Markdown Demo'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: md,
        ),
      ),
    );
  }
}

/// Matches <br/> or <br />.
class _BrSyntax extends md.BlockSyntax {
  const _BrSyntax();

  @override
  md.Node? parse(md.BlockParser parser) {
    parser.advance();
    return md.Element.empty('br');
  }

  @override
  RegExp get pattern => RegExp(r'^<br\s*/?>');
}

class _BrBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    return const SizedBox(height: 24);
  }
}

/// Builds a regex that matches a tag. Matches things like <b>hello</b> or
/// <b />.
@visibleForTesting
String buildTagRegex(String tag) {
  final regex = StringBuffer();
  regex.write('<$tag');
  regex.write('(?:\\s+[^>]*)?');
  regex.write('(?:>([^<]*)</$tag>|');
  regex.write(r'\s*/>)');
  return regex.toString();
}

@visibleForTesting
abstract class SyntaxReplacement {
  String apply(String target);
}

/// Extracts attributes from a tag. Returns a map of attribute name to value.
/// For example, <b color="red">hello</b> would return {'color': 'red'}.
@visibleForTesting
Map<String, String> extractAttributes(String data) {
  final attributes = <String, String>{};
  final regex = RegExp(r'(\w+)="([^"]*)"');
  final matches = regex.allMatches(data);
  for (final match in matches) {
    attributes[match.group(1)!] = match.group(2)!;
  }
  return attributes;
}

class _TooltipBuilder extends MarkdownElementBuilder {
  _TooltipBuilder({required this.context});

  final BuildContext context;

  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final attrs = element.attributes;
    final definition = attrs['value'] ?? "";
    //   return Builder(builder: (context) {
    //     final fallbackStyle = TextStyle(
    //       color: Colors.green,
    //       decoration: TextDecoration.underline,
    //       decorationStyle: TextDecorationStyle.dotted,
    //       fontWeight: FontWeight.bold,
    //     );
    //     final style = preferredStyle?.merge(fallbackStyle) ?? fallbackStyle;
    //     return GestureDetector(
    //       onTap: () {
    //         showDialog(
    //           context: context,
    //           builder: (context) {
    //             return AlertDialog(
    //               title: Text(element.textContent),
    //               content: Text(definition),
    //               actions: [
    //                 TextButton(
    //                   onPressed: () => Navigator.of(context).pop(),
    //                   child: const Text("Okay"),
    //                 ),
    //               ],
    //             );
    //           },
    //         );
    //       },
    //       child: Text(
    //         element.textContent,
    //         style: style,
    //       ),
    //     );
    //   });
    // }
    return RichText(
      text: TextSpan(
        text: element.textContent,
        style: TextStyle(
          color: Colors.green,
          decoration: TextDecoration.underline,
          decorationStyle: TextDecorationStyle.dotted,
          fontWeight: FontWeight.bold,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text(element.textContent),
                  content: Text(definition),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("Okay"),
                    ),
                  ],
                );
              },
            );
          },
      ),
    );
  }
}

class _StyleBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    return Builder(builder: (context) {
      final attrs = element.attributes;

      final colorKey = attrs['color'];
      Color? color;
      if (colorKey == "primary") {
        color = Colors.red;
      }

      // TODO(josiahsrc): This should support inherting styling
      final style = TextStyle(
        color: color,
      );

      return Text(
        element.textContent,
        style: style,
      );
    });
  }
}

class _TagSyntax extends md.InlineSyntax {
  _TagSyntax(this.tag) : super(buildTagRegex(tag));

  final String tag;

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final attrs = extractAttributes(match[0]!);

    md.Element elem;
    if (match[1] != null) {
      elem = md.Element.text(tag, match[1]!);
    } else {
      elem = md.Element.empty(tag);
    }

    elem.attributes.addAll(attrs);
    elem.attributes["tag"] = tag;
    parser.addNode(elem);
    return true;
  }
}
