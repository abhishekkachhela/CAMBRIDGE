import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:cambridge_customer/models/sellers.dart';
import 'package:cambridge_customer/widgets/text_delegate_header_widget.dart';
import '../models/brands.dart';
import '../widgets/my_drawer.dart';
import 'brands_ui_design_widget.dart';

class BrandsScreen extends StatefulWidget {
  final Sellers? model;

  BrandsScreen({this.model});

  @override
  State<BrandsScreen> createState() => _BrandsScreenState();
}

class _BrandsScreenState extends State<BrandsScreen> {
  @override
  Widget build(BuildContext context) {
    if (widget.model == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: MyDrawer(),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.redAccent,
                Colors.white54,
              ],
              begin: FractionalOffset(0.0, 0.0),
              end: FractionalOffset(1.0, 0.0),
              stops: [0.0, 1.0],
              tileMode: TileMode.clamp,
            ),
          ),
        ),
        title: const Text(
          "Cambridge",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      body: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: TextDelegateHeaderWidget(
              title: "${widget.model!.name} - Category",
            ),
          ),
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection("sellers")
                .doc(widget.model!.uid.toString())
                .collection("brands")
                .orderBy("publishedDate", descending: true)
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> dataSnapshot) {
              if (dataSnapshot.connectionState == ConnectionState.waiting) {
                return SliverToBoxAdapter(
                  child: buildLoadingIndicator(),
                );
              }

              if (dataSnapshot.hasError) {
                return SliverToBoxAdapter(
                  child: buildErrorWidget("Error loading brands. Please try again later."),
                );
              }

              if (dataSnapshot.hasData) {
                if (dataSnapshot.data!.docs.isEmpty) {
                  return SliverToBoxAdapter(
                    child: buildErrorWidget("No brands exist."),
                  );
                }

                final int crossAxisCount = MediaQuery.of(context).size.width > 600 ? 3 : 2;

                return SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                    childAspectRatio: 0.7,
                  ),
                  delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                      final Map<String, dynamic> brandData =
                      dataSnapshot.data!.docs[index].data() as Map<String, dynamic>;
                      final brandsModel = Brands.fromJson(brandData);
                      return BrandsUiDesignWidget(model: brandsModel);
                    },
                    childCount: dataSnapshot.data!.docs.length,
                  ),
                );
              } else {
                return SliverToBoxAdapter(
                  child: buildErrorWidget("No brands available."),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.redAccent),
      ),
    );
  }

  Widget buildErrorWidget(String message) {
    return Center(
      child: Text(
        message,
        style: const TextStyle(color: Colors.red, fontSize: 16),
      ),
    );
  }
}
