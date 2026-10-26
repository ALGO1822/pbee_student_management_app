import 'package:flutter/material.dart';
import 'package:pbee_collate/main.dart';
import 'package:pbee_collate/models/courses.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CourseService {
  final SupabaseClient _supabase = supabase;

  // Get all courses
  Stream<List<Course>> getCourseStream() {
    return _supabase
        .from('courses')
        .stream(primaryKey: ['id']) // Identify records by their ID
        .order('title', ascending: true)
        .map((data) => data.map((e) => Course.fromMap(e)).toList());
  }

  //------------ADMIN-------------
  //Add a new course
  Future<void> addCourse(String title, double price) async {
    try {
      await _supabase.from('courses').insert({
        'title': title,
        'price': price,
      });
    } catch (e) {
      debugPrint('Error adding course: $e');
      throw 'Failed to add course. Please try again.';
    }
  }

  //Update/edit existing course
  Future<void> updateCourse(String id, String title, double price) async {
    try {
      await _supabase.from('courses').update({
        'title': title,
        'price': price,
      }).eq('id', id);
    } catch (e) {
      debugPrint('Error updating course: $e');
      throw 'Failed to update course.';
    }
  }

  //Delete course
  Future<void> deleteCourse(String id) async {
    try {
      await _supabase.from('courses').delete().eq('id', id);
    } catch (e) {
      debugPrint('Error deleting course: $e');
      throw 'Failed to delete course.';
    }
  }
}