import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shop/components/cart_button.dart';
import 'package:shop/components/custom_modal_bottom_sheet.dart';
import 'package:shop/components/product/product_card.dart';
import 'package:shop/constants.dart';
import 'package:shop/globals.dart';
import 'package:shop/models/book_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'components/product_images.dart';
import 'components/product_info.dart';
import 'product_buy_now_screen.dart';

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
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: SvgPicture.asset("assets/icons/Bookmark.svg",
                      color: Theme.of(context).textTheme.bodyLarge!.color),
                ),
              ],
            ),
            ProductImages(
              images: [DISNEY_IMG_URI + _showingDetail.image],
            ),
            ProductInfo(
              brand: _showingDetail.cat,
              title: _showingDetail.title,
              description: _showingDetail.description??''),
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
