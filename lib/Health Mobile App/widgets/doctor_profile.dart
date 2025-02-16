import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

class MedicalNewsSlider extends StatefulWidget {
  const MedicalNewsSlider({super.key});

  @override
  _MedicalNewsSliderState createState() => _MedicalNewsSliderState();
}

class _MedicalNewsSliderState extends State<MedicalNewsSlider>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  List<dynamic> _newsArticles = [];
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _fetchMedicalNews();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _animationController.forward();

    Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_currentPage < _newsArticles.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
      );
    });
  }

  Future<void> _fetchMedicalNews() async {
    final url = Uri.parse(
        'https://newsapi.org/v2/top-headlines?category=health&apiKey=3165683e9929477aabe7a11b179a1f25');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        _newsArticles = json.decode(response.body)['articles'];
      });
    }
  }

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return _newsArticles.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              const SizedBox(height: 10),
              SizedBox(
                height: 250,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _newsArticles.length,
                  itemBuilder: (context, index) {
                    var article = _newsArticles[index];
                    return AnimatedOpacity(
                      duration: const Duration(milliseconds: 800),
                      opacity: _currentPage == index ? 1.0 : 0.5,
                      child: GestureDetector(
                        onTap: () => _launchURL(article['url']),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.blueAccent,
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                  offset: Offset(0, 4),
                                )
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    article['title'] ?? 'No Title',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    article['source']['name'] ??
                                        'Unknown Source',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
  }
}
