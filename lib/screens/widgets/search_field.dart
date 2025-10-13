import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';


import '../../constant/app_colors.dart';


class SearchAndFilterComponent extends StatefulWidget {
  final VoidCallback onTap;
  final Icon? prefix;
  final bool isFilter;
  const SearchAndFilterComponent({super.key, required this.onTap, this.prefix, this.isFilter = false});

  @override
  State<SearchAndFilterComponent> createState() => _SearchAndFilterComponentState();
}

class _SearchAndFilterComponentState extends State<SearchAndFilterComponent> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),

      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 50.0,
              decoration: BoxDecoration(
                color:Colors.white,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Row(
                children: [
                  widget.isFilter ? const SizedBox(width: 16.0) :const SizedBox(width: 8.0),
                  widget.isFilter ? Icon(IconlyLight.search,color: AppColors.primary,) :SizedBox.shrink() ,
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: TextField(
                      style: TextStyle(color: Colors.black),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelStyle: TextStyle(color: Colors.grey),
                        hintText: 'Search',
                        fillColor:Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder:  OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        hintStyle: TextStyle(color: Colors.grey), // Change the color here
                      ),
                    ),

                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 6,),
          GestureDetector(
            onTap: widget.onTap,
            child: Container(
              height: 50.0,
              width: 50.0,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: widget.isFilter ? Icon(IconlyLight.filter, color: Colors.white):Icon(IconlyLight.search,color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}