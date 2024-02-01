// ignore_for_file: public_member_api_docs, always_specify_types, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;

class ExtendedMarkdown extends StatelessWidget {
  const ExtendedMarkdown({super.key});

  @override
  Widget build(BuildContext context) {
    final md = MarkdownBody(
      data: '''
# Extended **Markdown** *Test*
## Extended **Markdown** *Test*
### Extended **Markdown** *Test*
#### Extended **Markdown** *Test*
##### Extended **Markdown** *Test*

**Why** *does* theirs work??

Text here
<br/>
Text there

''',
      blockSyntaxes: const [
        _BrSyntax(),
      ],
      builders: <String, MarkdownElementBuilder>{
        'br': _BrBuilder(),
      },
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
