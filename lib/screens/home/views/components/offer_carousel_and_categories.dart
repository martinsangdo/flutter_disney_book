import 'package:flutter/material.dart';
import 'package:shop/models/database_helper.dart';

import '../../../../constants.dart';
import 'categories.dart';

class OffersCarouselAndCategories extends StatefulWidget {
  const OffersCarouselAndCategories({
    super.key,
  });

  @override
  State<OffersCarouselAndCategories> createState() => _PageState();
}

class _PageState extends State<OffersCarouselAndCategories> {
  @override
  void initState() {
      super.initState();
      _fetchSampleBooks();
  }

  Future<void> _fetchSampleBooks() async {
    final bookMap = await DatabaseHelper.instance.queryBySlug('say-please-stitch');
    print(bookMap[0]['title']);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: defaultPadding / 2),
        Padding(
          padding: const EdgeInsets.all(defaultPadding),
          child: Text(
            "Categories",
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        // While loading use 👇
        // const CategoriesSkelton(),
        const Categories(),
      ],
    );
  }
}
