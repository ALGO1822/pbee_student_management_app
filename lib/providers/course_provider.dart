import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pbee_collate/models/courses.dart';
import 'package:pbee_collate/service/course_service.dart';

class CourseProvider with ChangeNotifier {
  final CourseService _courseService = CourseService();
  late StreamSubscription<List<Course>> _courseSubscription;

  List<Course> _courses = [];
  bool _isLoading = true; // Added back for initial load state
  String? _error;

  List<Course> get courses => _courses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  CourseProvider() {
    _listenToCourses();
  }

  void _listenToCourses() {
    _isLoading = true;
    notifyListeners();

    _courseSubscription = _courseService.getCourseStream().listen((coursesData) {
      _courses = coursesData;
      _isLoading = false;
      notifyListeners();
    }, onError: (error) {
      _error = error.toString();
      _isLoading = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _courseSubscription.cancel();
    super.dispose();
  }

  bool isCourseValid(String? title) {
    if (title == null || title.isEmpty) return false;
    return _courses.any((c) => c.title == title);
  }

  double getPriceForTitle(String? title) {
    if (!isCourseValid(title)) return 0.0;
    return _courses.firstWhere((c) => c.title == title).price;
  }

  // Admin Actions
  Future<bool> addCourse(String title, double price) async {
    try {
      await _courseService.addCourse(title, price);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCourse(String id, String title, double price) async {
    try {
      await _courseService.updateCourse(id, title, price);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCourse(String id) async {
    try {
      await _courseService.deleteCourse(id);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}