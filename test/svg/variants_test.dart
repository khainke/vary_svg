import 'package:test/test.dart';
import 'package:vary_svg/model/placeholder.dart';
import 'package:vary_svg/svg/variants.dart';
import 'package:xml/xml.dart';
import 'package:xml/xpath.dart';

final _testSvg = '''
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<svg
   width="50mm"
   height="50mm"
   viewBox="0 0 50 50"
   version="1.1"
   id="svg1"
   xml:space="preserve"
   xmlns:xlink="http://www.w3.org/1999/xlink"
   xmlns="http://www.w3.org/2000/svg"
   xmlns:svg="http://www.w3.org/2000/svg"><defs
     id="defs1" /><g
     id="layer1"><text
       xml:space="preserve"
       style="font-size:4.23333333px;line-height:1.25;font-family:'Open Sans';-inkscape-font-specification:'Open Sans, Normal';font-variant-ligatures:none;white-space:pre;inline-size:40.9288;stroke-width:0.264583;font-weight:normal;font-style:normal;font-stretch:normal;font-variant:normal;font-variant-caps:normal;font-variant-numeric:normal;font-variant-east-asian:normal"
       x="7.0254478"
       y="11.792717"
       id="text1"
       transform="translate(-1.8818164,-2.4463614)"><tspan
         x="7.0254478"
         y="11.792717"
         id="tspan2">lorem ipsum dolor </tspan><tspan
         x="7.0254478"
         y="17.084379"
         id="tspan3">sit amet</tspan></text><image
       width="15"
       height="15"
       preserveAspectRatio="none"
       xlink:href="../Pictures/example.jpg"
       id="image1"
       x="5"
       y="20" /></g></svg>
''';

void main() {
  group('Fill-in placeholders in template', () {
    test('Text node by id should be replaced correctly', () {
      final value = 'replacement';
      final res = fillPlaceholders(
        template: _testSvg,
        placeholders: [Placeholder.text(id: 'tspan2', column: 'text')],
        values: {'text': value},
      );
      final actual =
          XmlDocument.parse(res).xpath('//*[@id="tspan2"]').first.innerText;
      expect(actual, value);
    });

    test('Text node by value should be replaced correctly', () {
      final value = 'replacement';
      final res = fillPlaceholders(
        template: _testSvg,
        placeholders: [
          Placeholder.text(value: 'lorem ipsum dolor ', column: 'text')
        ],
        values: {'text': value},
      );
      final actual =
          XmlDocument.parse(res).xpath('//*[@id="tspan2"]').first.innerText;
      expect(actual, value);
    });

    test('Text node by id should be replaced correctly', () {
      final value = 'replacement';
      final res = fillPlaceholders(
        template: _testSvg,
        placeholders: [Placeholder.text(id: 'tspan2', column: 'text')],
        values: {'text': value},
      );
      final actual =
          XmlDocument.parse(res).xpath('//*[@id="tspan2"]').first.innerText;
      expect(actual, value);
    });

    test('Path node by id should be replaced correctly', () {
      final value = '/c/replacement/dir/path.jpg';
      final res = fillPlaceholders(
        template: _testSvg,
        placeholders: [Placeholder.path(id: 'image1', column: 'path')],
        values: {'path': value},
      );
      final actual = XmlDocument.parse(res)
          .xpath('//*[@id="image1"]')
          .first
          .getAttribute('href');
      expect(actual, value);
    });

    test('Path node by value should be replaced correctly', () {
      final value = '/c/replacement/dir/path.jpg';
      final res = fillPlaceholders(
        template: _testSvg,
        placeholders: [
          Placeholder.path(value: '../Pictures/example.jpg', column: 'path')
        ],
        values: {'path': value},
      );
      final actual = XmlDocument.parse(res)
          .xpath('//*[@id="image1"]')
          .first
          .getAttribute('href');
      expect(actual, value);
    });
  });
}
