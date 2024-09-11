import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internhub/view/home_screen/widget/intern_card.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../view_model/utils/app_colors.dart';
import '../../view_model/cubits/Internships/internships_cubit.dart';
import '../../view_model/cubits/Internships/internships_state.dart';

class InternshipsPage extends StatelessWidget {
  const InternshipsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => InternshipsCubit()..fetchInternships(),
      child: Scaffold(
        backgroundColor: AppColors.lightGrayBackground,
        appBar: AppBar(
          title: const Text(
            'Internships',
            style: TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.w400,
            ),
          ),
          backgroundColor: AppColors.primaryBlue,
        ),
        body: BlocBuilder<InternshipsCubit, InternshipsState>(
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: () async {
                // Refresh the internships when pulled
                context.read<InternshipsCubit>().fetchInternships();
              },
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      onChanged: (query) {
                        context.read<InternshipsCubit>().filterInternships(query);
                      },
                      decoration: InputDecoration(
                        hintText: 'Search by job title or company',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ),
                      onTapOutside: (_) {
                        FocusManager.instance.primaryFocus!.unfocus();
                      },
                    ),
                  ),
                  Expanded(
                    child: BlocBuilder<InternshipsCubit, InternshipsState>(
                      builder: (context, state) {
                        if (state is InternshipsLoading) {
                          return Skeletonizer(
                            enableSwitchAnimation: true,
                            enabled: true, // Show skeleton when loading
                            child: ListView.builder(
                              itemCount: 8, // Show a fixed number of skeleton items
                              itemBuilder: (context, index) {
                                return SkeletonItem(); // Use concrete implementation
                              },
                            ),
                          );
                        } else if (state is InternshipsLoaded) {
                          return ListView.builder(
                            itemCount: state.internships.length,
                            itemBuilder: (context, index) {
                              return InternshipCard(
                                internship: state.internships[index],
                              );
                            },
                          );
                        } else if (state is InternshipsEmpty) {
                          return const Center(
                            child: Text(
                              'There are no internships available.',
                              style: TextStyle(color: AppColors.primaryTextColor),
                            ),
                          );
                        } else if (state is InternshipsError) {
                          return Center(
                            child: Text(
                              state.message,
                              style: const TextStyle(color: AppColors.primaryTextColor),
                            ),
                          );
                        } else {
                          return Container();
                        }
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class SkeletonItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Replace with your actual skeleton loading design
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: ListTile(
          title: Container(
            color: Colors.grey.shade300,
            height: 16.0,
            width: double.infinity,
          ),
          subtitle: Container(
            color: Colors.grey.shade300,
            height: 14.0,
            width: double.infinity,
          ),
        ),
      ),
    );
  }
}
