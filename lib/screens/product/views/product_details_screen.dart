import 'package:flutter/material.dart';
import 'package:shop/components/cart_button.dart';
import 'package:shop/components/product/product_card.dart';
import 'package:shop/constants.dart';
import 'package:shop/globals.dart';
import 'package:shop/models/book_model.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'components/product_images.dart';
import 'components/product_info.dart';
import 'package:intl/intl.dart';

class ProductDetailsScreen extends StatefulWidget {
  Book detail;

  ProductDetailsScreen({super.key, required this.detail});

  @override
  State<ProductDetailsScreen> createState() => _LocalState();
}

class _LocalState extends State<ProductDetailsScreen> {
  late Book _showingDetail;

  @override
  void initState() {
      super.initState();
  }

  String timestampToReadableDateString(int timestamp) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    DateFormat formatter = DateFormat('yyyy-MMMM-dd');
    return formatter.format(date);
  }

  //open link in Chrome
  void _launchURL(String ext_url) async {
    if (ext_url.isEmpty){
      return;
    }
    ext_url = AMAZON_URI + ext_url;
    if (global_affiliate_post_fix.isNotEmpty){
      if (!ext_url.contains('?')){
        ext_url += '?t=1';  //try to add dummy param
      }
      ext_url += global_affiliate_post_fix;
    }
    if (!await launchUrlString(ext_url, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $ext_url');
    }
}

  @override
  Widget build(BuildContext context) {
    final _showingDetail = widget.detail;

    return Scaffold(
      bottomNavigationBar:CartButton(
              press: () {
                _launchURL(_showingDetail.amazon!);
              },
            ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              floating: true,
            ),
            ProductImages(
              images: [DISNEY_IMG_URI + _showingDetail.image],
            ),
            ProductInfo(
              brand: _showingDetail.cat,
              title: _showingDetail.title,
              description: _showingDetail.description??''),
            if (_showingDetail.author != null) SliverPadding(
              //author info
              padding: const EdgeInsets.only(left:defaultPadding, right:defaultPadding),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Text("By", style: Theme.of(context).textTheme.titleSmall!),
                    const SizedBox(width: 8.0), // Add spacing between texts
                    Text("${_showingDetail.author}"),
                  ],
                )
              ),
            ),
            if (_showingDetail.format != null) SliverPadding(
              //format info
              padding: const EdgeInsets.only(left:defaultPadding, right:defaultPadding),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Text("Format", style: Theme.of(context).textTheme.titleSmall!),
                    const SizedBox(width: 8.0), // Add spacing between texts
                    Text("${_showingDetail.format}"),
                  ],
                )
              ),
            ),
            if (_showingDetail.release_time != null) SliverPadding(
              //Release info
              padding: const EdgeInsets.only(left:defaultPadding, right:defaultPadding),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Text("Release", style: Theme.of(context).textTheme.titleSmall!),
                    const SizedBox(width: 8.0), // Add spacing between texts
                    Text(timestampToReadableDateString(_showingDetail.release_time!)),
                  ],
                )
              ),
            ),
            if (_showingDetail.page_num != null) SliverPadding(
              //Page info
              padding: const EdgeInsets.only(left:defaultPadding, right:defaultPadding),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Text("Pages", style: Theme.of(context).textTheme.titleSmall!),
                    const SizedBox(width: 8.0), // Add spacing between texts
                    Text("${_showingDetail.page_num}"),
                  ],
                )
              ),
            ),
            if (_showingDetail.age_range != null) SliverPadding(
              //Age range info
              padding: const EdgeInsets.only(left:defaultPadding, right:defaultPadding),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Text("Age range", style: Theme.of(context).textTheme.titleSmall!),
                    const SizedBox(width: 8.0), // Add spacing between texts
                    Text("${_showingDetail.age_range}"),
                  ],
                )
              ),
            ),
            if (_showingDetail.isbn != null) SliverPadding(
              //ISBN info
              padding: const EdgeInsets.only(left:defaultPadding, right:defaultPadding),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Text("ISBN", style: Theme.of(context).textTheme.titleSmall!),
                    const SizedBox(width: 8.0), // Add spacing between texts
                    Text("${_showingDetail.isbn}"),
                  ],
                )
              ),
            ),
            if (_showingDetail.illustration != null && _showingDetail.illustration != '') SliverPadding(
              //illustration info
              padding: const EdgeInsets.only(left:defaultPadding, right:defaultPadding),
              sliver: SliverToBoxAdapter(
                child: Row(
                  children: [
                    Text("Illustration", style: Theme.of(context).textTheme.titleSmall!),
                    const SizedBox(width: 8.0), // Add spacing between texts
                    Text("${_showingDetail.illustration}"),
                  ],
                )
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(defaultPadding),
              sliver: SliverToBoxAdapter(
                child: Text(
                  "You may also like",
                  style: Theme.of(context).textTheme.titleSmall!,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 5,
                  itemBuilder: (context, index) => Padding(
                    padding: EdgeInsets.only(
                        left: defaultPadding,
                        right: index == 4 ? defaultPadding : 0),
                    child: ProductCard(
                      image: productDemoImg2,
                      title: "Sleeveless Tiered Dobby Swing Dress",
                      brandName: "LIPSY LONDON",
                      press: () {},
                    ),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: defaultPadding),
            )
          ],
        ),
      ),
    );
  }
}
