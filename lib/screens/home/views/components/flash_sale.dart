import 'package:flutter/material.dart';
import 'package:shop/models/book_model.dart';
import 'package:shop/route/route_constants.dart';

import '../../../../components/product/product_card.dart';
import '../../../../constants.dart';

class FlashSale extends StatelessWidget {
  List<Book> books = [];

  FlashSale({
    super.key, required this.books
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Text(
            "Disney",
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        // While loading show 👇
        // const ProductsSkelton(),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            // Find demoFlashSaleProducts on models/ProductModel.dart
            itemCount: books!.length,
            itemBuilder: (context, index) => Padding(
              padding: EdgeInsets.only(
                left: defaultPadding,
                right: index == books!.length - 1
                    ? defaultPadding
                    : 0,
              ),
              child: ProductCard(
                image: DISNEY_IMG_URI + books[index].image,
                brandName: books[index].cat,
                title: books[index].title,
                press: () {
                  Navigator.pushNamed(context, productDetailsScreenRoute,
                      arguments: index.isEven);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
