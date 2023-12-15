import 'package:flutter/material.dart';
import 'package:food_hub_app/data/api/api_restaurant.dart';
import 'package:food_hub_app/data/models/restaurant_detail.dart';
import 'package:food_hub_app/screens/restaurant_review/widgets/list_review.dart';
import 'package:food_hub_app/utils/provider/preference_settings_provider.dart';
import 'package:food_hub_app/utils/utils.dart';
import 'package:food_hub_app/extensions/extension.dart';
import 'package:provider/provider.dart';

import '../../widgets/widgets.dart';

class RestaurantReviewScreen extends StatefulWidget {
  final String id;

  const RestaurantReviewScreen({
    super.key,
    required this.id,
  });

  @override
  State<RestaurantReviewScreen> createState() => _RestaurantReviewScreenState();
}

class _RestaurantReviewScreenState extends State<RestaurantReviewScreen> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final fav =
          Provider.of<RestaurantFavoriteProvider>(context, listen: false);

      if (await fav.isRestaurantFavorite(widget.id)) {
        setState(() {
          isFavorite = true;
        });
      } else {
        setState(() {
          isFavorite = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<RestaurantDetailProvider>(
      create: (context) => RestaurantDetailProvider(id: widget.id),
      child: Consumer<RestaurantDetailProvider>(
        builder: (context, restaurantDetailProvider, _) {
          if (restaurantDetailProvider.state == ResponseState.loading) {
            return const Scaffold(
              body: SafeArea(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            );
          } else if (restaurantDetailProvider.state == ResponseState.noData) {
            return _detailError(context, restaurantDetailProvider.message);
          } else if (restaurantDetailProvider.state == ResponseState.error) {
            return _detailError(context, restaurantDetailProvider.message);
          } else if (restaurantDetailProvider.state == ResponseState.hasData) {
            return _detailRestaurant(context,
                restaurantDetailProvider.restaurantDetail!.restaurantDetail);
          } else {
            return _detailError(context, restaurantDetailProvider.message);
          }
        },
      ),
    );
  }

  Widget _detailError(BuildContext context, String message) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/notfound.png',
                width: 200,
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  message != '' ? message : 'Empty Data',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width / 4,
                  vertical: 20,
                ),
                child: ButtonWidget(
                  onPress: () => Navigator.pop(context),
                  title: 'Back',
                  buttonColor: orangeColor,
                  titleColor: whiteColor,
                  borderColor: orangeColor,
                  paddingHorizontal: 0.0,
                  paddingVertical: 16.0,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRestaurant(BuildContext context, RestaurantDetail restaurant) {
    ThemeData theme = context.theme;
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: SizedBox(
            width: size.width,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 25,
                vertical: 25,
              ),
              child: Consumer<PreferenceSettingsProvider>(
                builder: (context, preferenceSettingsProvider, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          SizedBox(
                            width: size.width,
                            height: 200,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: FadeInImage.assetNetwork(
                                placeholder: 'assets/images/foodhub.png',
                                fit: BoxFit.cover,
                                image:
                                    '${ApiRestaurant.baseUrl}${ApiRestaurant.getImageUrl}${restaurant.pictureId}',
                                imageErrorBuilder: (context, error,
                                        stackTrace) =>
                                    Image.asset('assets/images/foodhub.png'),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  enableFeedback: false,
                                  child: Container(
                                    padding: const EdgeInsets.all(8.0),
                                    decoration: BoxDecoration(
                                        color: whiteColor,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            spreadRadius: 1,
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          ),
                                        ]),
                                    child: Padding(
                                      padding: const EdgeInsets.all(1.0),
                                      child: Icon(
                                        Icons.arrow_back_ios_new,
                                        size: 18,
                                        color: blackColor80,
                                      ),
                                    ),
                                  ),
                                ),
                                Consumer<RestaurantFavoriteProvider>(
                                  builder:
                                      (context, restaurantFavoriteProvider, _) {
                                    return InkWell(
                                      borderRadius: BorderRadius.circular(20),
                                      splashColor: orangeColor,
                                      onTap: () async {
                                        final favoriteCheck =
                                            await restaurantFavoriteProvider
                                                .isRestaurantFavorite(
                                                    widget.id);

                                        if (favoriteCheck) {
                                          restaurantFavoriteProvider
                                              .removeRestaurantFavorite(
                                                  restaurant.id);

                                          context.showCustomFlashMessage(
                                            status: 'success',
                                            title: 'Remove Favorite',
                                            positionBottom: false,
                                            message:
                                                'Remove ${restaurant.name} from Favorite',
                                          );
                                        } else {
                                          restaurantFavoriteProvider
                                              .addResturantFavorite(restaurant);

                                          context.showCustomFlashMessage(
                                            status: 'success',
                                            title: 'Success Add Favorite',
                                            positionBottom: false,
                                            message:
                                                'Add ${restaurant.name} to your Favorite',
                                          );
                                        }
                                        setState(() {
                                          isFavorite = !isFavorite;
                                        });
                                      },
                                      child: isFavorite
                                          ? Card(
                                              color: orangeColor,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: const Padding(
                                                padding: EdgeInsets.all(6),
                                                child: Icon(
                                                  Icons.favorite,
                                                  color: whiteColor,
                                                  size: 20,
                                                ),
                                              ),
                                            )
                                          : Card(
                                              color:
                                                  Colors.grey.withOpacity(0.5),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              child: const Padding(
                                                padding: EdgeInsets.all(6),
                                                child: Icon(
                                                  Icons.favorite,
                                                  color: whiteColor,
                                                  size: 20,
                                                ),
                                              ),
                                            ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 28.0),
                      Text(
                        restaurant.name,
                        style:
                            theme.textTheme.headline4!.copyWith(fontSize: 22),
                      ),
                      const SizedBox(height: 12.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.star,
                            color: yellowColor,
                            size: 20,
                            shadows: [
                              BoxShadow(
                                blurRadius: 10,
                                spreadRadius: 5,
                                color: preferenceSettingsProvider.isDarkTheme
                                    ? blackColor50
                                    : yellowColor50,
                                offset: const Offset(0, 3),
                              )
                            ],
                          ),
                          const SizedBox(width: 6.0),
                          Padding(
                            padding: const EdgeInsets.only(top: 2.0),
                            child: Text(
                              restaurant.rating.toString(),
                              style: theme.textTheme.headline4!
                                  .copyWith(fontSize: 16),
                            ),
                          ),
                          const SizedBox(width: 6.0),
                          Padding(
                            padding: const EdgeInsets.only(top: 2.0),
                            child: Text(
                              '(${restaurant.customerReviews!.length} Review)',
                              style: theme.textTheme.headline4!.copyWith(
                                fontSize: 15,
                                color: grayColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            color: orangeColor,
                            size: 20,
                            shadows: [
                              BoxShadow(
                                blurRadius: 5,
                                spreadRadius: 5,
                                color: preferenceSettingsProvider.isDarkTheme
                                    ? blackColor50
                                    : yellowColor50,
                                offset: const Offset(0, 3),
                              )
                            ],
                          ),
                          const SizedBox(width: 6.0),
                          Flexible(
                            child: Text(
                              '${restaurant.address}, ${restaurant.city}',
                              style: theme.textTheme.headline4!.copyWith(
                                fontSize: 14,
                                color: orangeColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20.0),
                      Container(
                        margin: const EdgeInsets.only(
                          left: 5,
                          right: 5,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.comment,
                                  color: Colors.blue[600],
                                  size: 18,
                                ),
                                const SizedBox(width: 8.0),
                                Consumer<PreferenceSettingsProvider>(
                                  builder:
                                      (context, preferenceSettingsProvider, _) {
                                    return Text(
                                      'Review',
                                      style:
                                          theme.textTheme.headline4!.copyWith(
                                        fontSize: 18,
                                        color: preferenceSettingsProvider
                                                .isDarkTheme
                                            ? whiteColor
                                            : blackColor.withOpacity(0.85),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14.0),
                      ListView.builder(
                        itemCount: restaurant.customerReviews!.length,
                        scrollDirection: Axis.vertical,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemBuilder: (_, index) {
                          return ReviewCardWidget(
                            name: restaurant.customerReviews![index].name,
                            review: restaurant.customerReviews![index].review,
                            date: restaurant.customerReviews![index].date,
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
